import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/models/user_profile.dart';
import 'package:source_base/data/repositories/user_repository.dart';
import 'package:source_base/presentation/blocs/auth/auth_event.dart';
import 'package:source_base/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<ReSendOtpRequested>(_onReSendOTPId);
    on<SendVerifyOtpRequested>(_onSendVerifyOtpRequested);
    on<LoadUserInfoRequested>(_onLoadUserInfoRequested);
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<LoginWithGoogleRequested>(_onLoginWithGoogleReqrested);
    on<LoginWithFacebookRequested>(_onLoginWithFacebookReqrested);
    // on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // Xử lý sự kiện kiểm tra trạng thái xác thực
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();
    final String? orgId =
        sharedPreferencesService.getString(PrefKey.defaultOrganizationId);
    print('defaultOrganizationId: $orgId');
    final String? token =
        sharedPreferencesService.getString(PrefKey.accessToken);
    print('accessToken: $token');
    final initialLocation =
        token != null ? '/organization/${orgId ?? 'default'}' : '/';
    if (token != null && orgId != null) {
      emit(state.copyWith(
          status: AuthStatus.authenticated,
          initialLocation: initialLocation,
          organizationId: orgId));
    }
    // } else {
    //   emit(state.copyWith(status: AuthStatus.unauthenticated));
    // }
    // // Kiểm tra nếu đã đăng nhập
    // final isLoggedIn = userRepository.isLoggedIn();

    // if (isLoggedIn) {
    //   try {
    //     // Lấy thông tin người dùng từ API
    //     final user = await userRepository.getUserProfile();
    //     emit(Authenticated(user: user));
    //   } catch (e) {
    //     // Nếu có lỗi, đăng xuất và chuyển về trạng thái chưa xác thực
    //     await userRepository.logout();
    //     emit(Unauthenticated());
    //   }
    // } else {
    //   emit(Unauthenticated());
    // }
  }

  // Xử lý sự kiện đăng nhập
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final otpId = await userRepository.loginRepository(
        event.email,
      );
      emit(state.copyWith(
          otpId: otpId, email: event.email, status: AuthStatus.emailDone));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }

  Future<void> _onReSendOTPId(
    ReSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await userRepository.reSendOtpRepository(
        event.otpId,
      );
      bool stastus = Helpers.isResponseSuccess(response);
      if (stastus == true) {
        emit(state.copyWith(status: AuthStatus.sentOTPDone));
      } else {
        emit(state.copyWith(
            status: AuthStatus.error, error: response?["message"]));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }

  Future<void> _onSendVerifyOtpRequested(
    SendVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await userRepository.verifyOTPRepository(
        otpID: event.otpId,
        otpCode: event.otpCode,
      );
      bool stastus = Helpers.isResponseSuccess(response.data);
      if (stastus == true) {
        await SharedPreferencesService().setString(
          PrefKey.accessToken,
          response.data['metadata']['accessToken'],
        );
        await SharedPreferencesService().setString(
          PrefKey.refreshToken,
          response.data['metadata']['refreshToken'],
        );
        // Kiểm tra nếu fullName trùng với email thì chuyển đến trang hoàn tất đăng ký
        if (response.data['metadata']['fullName'] ==
            response.data['metadata']['email']) {
          emit(state.copyWith(status: AuthStatus.confirmAccount));
        } else {
          emit(state.copyWith(status: AuthStatus.success));
          // Chuyển đến trang chủ và xóa stack điều hướng
        }
      } else {
        emit(state.copyWith(
            status: AuthStatus.error, error: response.data["message"]));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }

  Future<void> _onLoadUserInfoRequested(
    LoadUserInfoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await userRepository.getUserProfileRepository();
      if (response.data != null) {
        UserProfile user = UserProfile.fromJson(response.data["content"]);
        emit(state.copyWith(user: user, status: AuthStatus.loadUserData));
      } else {
        emit(state.copyWith(
            status: AuthStatus.error, error: response.data["message"]));
      }
      // emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }

  Future<void> _onUpdateUserProfileRequested(
    UpdateUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await userRepository.updateProfileRepository({
        'fullName': event.fullName,
        'email': event.email,
        'phone': event.phone,
        'dob': Helpers.convertToISOString(event.dob.toString()),
        'gender': event.gender == "Nam"
            ? 1
            : event.gender == "Nữ"
                ? 0
                : 2,
        'address': event.address,
      }, avatar: event.avatar);
      if (response.data != null) {
        // UserProfile user = UserProfile.fromJson(response.data["content"]);
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(
            status: AuthStatus.error, error: response.data["message"]));
      }
      // emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }

  Future<void> _onLoginWithGoogleReqrested(
      LoginWithGoogleRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await userRepository.loginWithGoogleRepository(
        forceNewAccount: true,
      );
      if (Helpers.isResponseSuccess(response.data)) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(
            status: AuthStatus.error, error: response.data["message"]));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }

  Future<void> _onLoginWithFacebookReqrested(
      LoginWithFacebookRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await userRepository.loginWithFacebookRepository(
        forceNewAccount: true,
      );
      if (Helpers.isResponseSuccess(response.data)) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(
            status: AuthStatus.error, error: response.data["message"]));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AuthStatus.error));
    }
  }
  // Xử lý sự kiện đăng ký
  // Future<void> _onRegisterRequested(
  //   RegisterRequested event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());

  //   try {
  //     final user = await userRepository.register(
  //       event.name,
  //       event.email,
  //       event.password,
  //     );
  //     emit(Authenticated(user: user));
  //   } catch (e) {
  //     emit(AuthError(message: e.toString()));
  //   }
  // }

  // // Xử lý sự kiện đăng xuất
  // Future<void> _onLogoutRequested(
  //   LogoutRequested event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());

  //   try {
  //     await userRepository.logout();
  //     emit(Unauthenticated());
  //   } catch (e) {
  //     emit(AuthError(message: e.toString()));
  //   }
  // }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await userRepository.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
