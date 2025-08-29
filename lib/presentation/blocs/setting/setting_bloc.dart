import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'package:source_base/presentation/blocs/setting/model/Invitation_list_response.dart';
import 'package:source_base/presentation/blocs/setting/model/organization_search_repsonse.dart';
import 'package:source_base/presentation/blocs/setting/setting_event.dart';
import 'package:source_base/presentation/blocs/setting/setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final OrganizationRepository organizationRepository;
  SettingBloc({required this.organizationRepository})
      : super(const SettingState()) {
    on<SettingInitialized>(_onSettingInitialized);
    on<OffBlocSetting>(_onOffBlocSetting);
    on<SearchOrganization>(_onSearchOrganization);
    on<JoinOrganization>(_onJoinOrganization);
    on<GetInvitationList>(_onGetInvitationList);
    on<ConfirmInvitation>(_onConfirmInvitation);
  }

  Future<void> _onSettingInitialized(
      SettingInitialized event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.loading));
  }

  Future<void> _onOffBlocSetting(
      OffBlocSetting event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.initial, isDelete: true));
  }

  Future<void> _onSearchOrganization(
      SearchOrganization event, Emitter<SettingState> emit) async {
    emit(state.copyWith(
        status: SettingStatus.loading, organizationId: event.organizationId));

    final response = await organizationRepository.searchOrganization(
        event.searchText, event.organizationId);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      final OrganizationSearchRepsonse organizationSearchRepsonse =
          OrganizationSearchRepsonse.fromJson(response.data);
      emit(state.copyWith(
          status: SettingStatus.success,
          organizations: organizationSearchRepsonse.content,
          organizationName: event.searchText));
    } else {
      emit(state.copyWith(
          status: SettingStatus.error, error: response.data['message']));
    }
  }

  Future<void> _onJoinOrganization(
      JoinOrganization event, Emitter<SettingState> emit) async {
    try {
      emit(state.copyWith(status: SettingStatus.loading));
      final response = await organizationRepository.joinOrganization(
        event.organizationId,
      );
      bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        add(SearchOrganization(
            searchText: state.organizationName ?? '',
            organizationId: state.organizationId ?? ''));
        emit(state.copyWith(
            status: SettingStatus.successJoin,
            organizationName: event.organizationName));
      } else {
        emit(state.copyWith(
            status: SettingStatus.errorJoin, error: response.data['message']));
      }
    } catch (e) {
      emit(
          state.copyWith(status: SettingStatus.errorJoin, error: e.toString()));
    }
  }

  Future<void> _onGetInvitationList(
      GetInvitationList event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.loading));
    final response = await organizationRepository.getInvitationList(
        event.organizationId, event.type);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      final InvitationListResponse invitationListResponse =
          InvitationListResponse.fromJson(response.data);
      emit(state.copyWith(
          status: SettingStatus.successGetInvitationList,
          invitations: invitationListResponse.content));
    } else {
      emit(state.copyWith(
          status: SettingStatus.errorGetInvitationList,
          error: response.data['message']));
    }
  }

  Future<void> _onConfirmInvitation(
      ConfirmInvitation event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.loading));
    final response;
    if (event.isAccept) {
      response = await organizationRepository.acceptInvitation(
          event.organizationId, event.id);
    } else {
      response = await organizationRepository.rejectInvitation(
          event.organizationId, event.id);
    }

    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      add(GetInvitationList(
          organizationId: event.organizationId, type: "INVITE"));
      emit(state.copyWith(status: SettingStatus.successConfirmInvitation));
    } else {
      emit(state.copyWith(
          status: SettingStatus.errorConfirmInvitation,
          error: response.data['message']));
    }
  }
}
