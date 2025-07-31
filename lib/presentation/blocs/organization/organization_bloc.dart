import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/organization_model.dart';
import 'package:source_base/data/models/user_profile.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';

import 'organization_event.dart';
import 'organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final OrganizationRepository organizationRepository;

  OrganizationBloc({required this.organizationRepository})
      : super(const OrganizationState()) {
    on<CheckOrganizationStatus>(_onCheckOrganizationStatus);
    on<LoadOrganizations>(_onLoadOrganizations);
    on<LoadUserInfo>(_onLoadUserInfo);
    on<ChangeOrganization>(_onChangeOrganization);
    // on<ReSendOtpRequested>(_onReSendOTPId);
    // on<SendVerifyOtpRequested>(_onSendVerifyOtpRequested);
    // on<LoadUserInfoRequested>(_onLoadUserInfoRequested);
    // on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    // on<LoginWithGoogleRequested>(_onLoginWithGoogleReqrested);
    // on<LoginWithFacebookRequested>(_onLoginWithFacebookReqrested);
    // on<RegisterRequested>(_onRegisterRequested);
    // on<LogoutRequested>(_onLogoutRequested);
  }

  // Xử lý sự kiện kiểm tra trạng thái xác thực
  Future<void> _onCheckOrganizationStatus(
    CheckOrganizationStatus event,
    Emitter<OrganizationState> emit,
  ) async {
    // // Kiểm tra nếu đã đăng nhập
    // final isLoggedIn = organizationRepository.isLoggedIn();

    // if (isLoggedIn) {
    //   try {
    //     // Lấy thông tin người dùng từ API
    //     final user = await organizationRepository.getUserProfile();
    //     emit(Organizationenticated(user: user));
    //   } catch (e) {
    //     // Nếu có lỗi, đăng xuất và chuyển về trạng thái chưa xác thực
    //     await organizationRepository.logout();
    //     emit(Unauthenticated());
    //   }
    // } else {
    //   emit(Unauthenticated());
    // }
  }

  Future<void> _onLoadOrganizations(
    LoadOrganizations event,
    Emitter<OrganizationState> emit,
  ) async {
    // 1) Chuyển sang trạng thái loading
    emit(state.copyWith(status: OrganizationStatus.loading));

    try {
      // 2) Gọi repository lấy data
      final response = await organizationRepository.getOrganizations(
        limit: event.limit,
        offset: event.offset,
        searchText: event.searchText,
      );

      // 3) Kiểm tra success flag từ backend
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        // 4) Parse content thành list Organization
        // final rawList = response.data['content'] as List<dynamic>? ?? [];
        final OrganizationResponse dataOrganization =
            OrganizationResponse.fromJson(response.data);

        // 5) Emit success kèm payload
        emit(state.copyWith(
          status: OrganizationStatus.loadOrganizationsSuccess,
          organizations: dataOrganization.content,
          error: null,
        ));
      } else {
        // 6) Backend trả về lỗi business
        emit(state.copyWith(
          status: OrganizationStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error',
        ));
      }
    } on DioError catch (dioErr) {
      // 7) Lỗi từ HTTP client, có thể parse message từ body
      final errMsg =
          dioErr.response?.data?['message'] as String? ?? dioErr.message;
      emit(state.copyWith(
        status: OrganizationStatus.error,
        error: errMsg,
      ));
    } catch (e) {
      // 8) Lỗi bất ngờ
      emit(state.copyWith(
        status: OrganizationStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadUserInfo(
    LoadUserInfo event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(state.copyWith(status: OrganizationStatus.loading));
    try {
      final response = await organizationRepository
          .getOrganizationDetail(event.organizationId);
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final UserProfile user = UserProfile.fromJson(response.data['content']);
        emit(state.copyWith(
            status: OrganizationStatus.loadUserInfoSuccess, user: user));
      } else {
        emit(state.copyWith(
            status: OrganizationStatus.error,
            error: response.data['message'] as String? ?? 'Unknown error'));
      }
      emit(state.copyWith(status: OrganizationStatus.loadUserInfoSuccess));
    } catch (e) {
      emit(state.copyWith(
          status: OrganizationStatus.error, error: e.toString()));
    }
  }

  Future<void> _onChangeOrganization(
    ChangeOrganization event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(state.copyWith(organizationId: event.organizationId));
  }
}
