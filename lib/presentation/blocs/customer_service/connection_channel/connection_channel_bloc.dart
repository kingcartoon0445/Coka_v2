import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/model/tiktok_configuration_response.dart';
import 'connection_channel_action.dart';
import 'model/account_tiktok_model.dart';
import 'model/form_account_tiktok_reponse.dart';

class ConnectionChannelBloc
    extends Bloc<ConnectionChannelEvent, ConnectionChannelState> {
  final OrganizationRepository organizationRepository;

  ConnectionChannelBloc({required this.organizationRepository})
      : super(const ConnectionChannelState()) {
    // Đăng ký handler là method trong class

    on<GetChannelListEvent>(_onGetChannelListEvent);
    on<CreateWebFormEvent>(_onCreateWebFormEvent);
    on<VerifyWebFormEvent>(_onVerifyWebFormEvent);
    on<ConnectChannelEvent>(_onConnectChannelEvent);
    on<DisconnectChannelEvent>(_onDisconnectChannelEvent);
    on<CreateIntegrationEvent>(_onCreateIntegrationEvent);
    on<GetTiktokLeadConnectionsEvent>(_onGetTiktokLeadConnectionsEvent);
    on<GetTiktokItemListEvent>(_onGetTiktokItemListEvent);
    on<GetTiktokConfigurationEvent>(_onGetTiktokConfigurationEvent);
    on<CancelBloc>(_onCancelBloc);
  }

  // <-- Đưa handler vào trong class để dùng được `state` & `organizationRepository`
  Future<void> _onGetChannelListEvent(
    GetChannelListEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(status: ConnectionChannelStatus.loading));
    try {
      final response =
          await organizationRepository.getChannelList(event.organizationId);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final channelsResponse =
            ConnectionChannelResponse.fromJson(response.data);
        emit(state.copyWith(
          organizationId: event.organizationId,
          status: ConnectionChannelStatus.success,
          channels: channelsResponse.content,
        ));
      } else {
        emit(state.copyWith(
          status: ConnectionChannelStatus.error,
          errorMessage: response.data['message'],
        ));
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(
        status: ConnectionChannelStatus.error,
        // errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateWebFormEvent(
    CreateWebFormEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(status: ConnectionChannelStatus.createWebFormLoading));

    try {
      final data = {"url": "https://${event.url}", "type": "DOMAIN"};
      final response = await organizationRepository.createWebForm(
          state.organizationId ?? "", data);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        emit(state.copyWith(
            status: ConnectionChannelStatus.createWebFormSuccess));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.createWebFormError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(
        status: ConnectionChannelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onVerifyWebFormEvent(
    VerifyWebFormEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(status: ConnectionChannelStatus.verifyWebFormLoading));
    try {
      final response = await organizationRepository.verifyWebForm(
          state.organizationId ?? "", event.id);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final channelResponse = response.data;
        emit(state.copyWith(
          status: ConnectionChannelStatus.verifyWebFormSuccess,
          idChannel: channelResponse["content"]["id"],
        ));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.verifyWebFormError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(
        status: ConnectionChannelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onConnectChannelEvent(
    ConnectChannelEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(status: ConnectionChannelStatus.connectChannelLoading));
    try {
      final response = await organizationRepository.connectChannel(
          state.organizationId ?? "", event.id, event.status, event.provider);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        emit(state.copyWith(
            status: ConnectionChannelStatus.connectChannelSuccess));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.connectChannelError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ConnectionChannelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDisconnectChannelEvent(
    DisconnectChannelEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(
        status: ConnectionChannelStatus.disconnectChannelLoading));
    try {
      final response = await organizationRepository.disconnectChannel(
          state.organizationId ?? "", event.id, event.provider);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        emit(state.copyWith(
            status: ConnectionChannelStatus.disconnectChannelSuccess));
        add(GetChannelListEvent(organizationId: state.organizationId ?? ""));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.disconnectChannelError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ConnectionChannelStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetTiktokLeadConnectionsEvent(
    GetTiktokLeadConnectionsEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(
        status: ConnectionChannelStatus.getTiktokLeadConnectionsLoading));
    try {
      final response = await organizationRepository
          .getTiktokLeadConnections(state.organizationId ?? "");
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final accountTiktokResponse =
            AccountTiktokResponse.fromJson(response.data);
        emit(state.copyWith(
            status: ConnectionChannelStatus.getTiktokLeadConnectionsSuccess,
            accountTiktok: accountTiktokResponse.content));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.getTiktokLeadConnectionsError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ConnectionChannelStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateIntegrationEvent(
    CreateIntegrationEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(
        status: ConnectionChannelStatus.createIntegrationLoading));
    try {
      final response = await organizationRepository.createIntegration(
          event.organizationId, event.source, event.expiryDate);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final formAccountTiktokResponse =
            FormAccountTiktokResponse.fromJson(response.data);
        emit(state.copyWith(
            status: ConnectionChannelStatus.createIntegrationSuccess,
            url: response.data['content']['url'],
            formAccountTiktok: formAccountTiktokResponse.content));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.createIntegrationError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ConnectionChannelStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetTiktokItemListEvent(
    GetTiktokItemListEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(
        status: ConnectionChannelStatus.getTiktokItemListLoading));
    try {
      final response = await organizationRepository.getTiktokItemList(
          event.organizationId, event.subscribedId, event.isConnect);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final tiktokItemList =
            FormAccountTiktokResponse.fromJson(response.data);
        emit(state.copyWith(
            status: ConnectionChannelStatus.getTiktokItemListSuccess,
            formAccountTiktok: tiktokItemList.content));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.getTiktokItemListError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ConnectionChannelStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetTiktokConfigurationEvent(
    GetTiktokConfigurationEvent event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(
        status: ConnectionChannelStatus.getTiktokConfigurationLoading));
    try {
      final response = await organizationRepository.getTiktokConfiguration(
          event.organizationId, event.connectionId, event.pageId);
      final isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final tiktokConfiguration =
            TiktokConfigurationResponse.fromJson(response.data);
        emit(state.copyWith(
            status: ConnectionChannelStatus.getTiktokConfigurationSuccess,
            tiktokConfiguration: tiktokConfiguration.content));
      } else {
        emit(state.copyWith(
            status: ConnectionChannelStatus.getTiktokConfigurationError,
            errorMessage: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ConnectionChannelStatus.getTiktokConfigurationError,
          errorMessage: e.toString()));
    }
  }

  Future<void> _onCancelBloc(
    CancelBloc event,
    Emitter<ConnectionChannelState> emit,
  ) async {
    emit(state.copyWith(isCancel: true));
  }
}
