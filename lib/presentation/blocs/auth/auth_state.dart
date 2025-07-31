// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/user_profile.dart';

enum AuthStatus {
  initial,
  loading,
  emailDone,
  otpDone,
  sentOTPDone,
  confirmAccount,
  loadUserData,
  success,
  error,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile? user;
  final String? email;
  final String? otpId;
  final String? error;
  final String? organizationId;
  final String? initialLocation;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.user,
    this.otpId,
    this.error,
    this.organizationId,
    this.initialLocation,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? email,
    String? otpId,
    String? error,
    String? organizationId,
    String? initialLocation,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      email: email ?? this.email,
      otpId: otpId ?? this.otpId,
      error: error ?? this.error,
      organizationId: organizationId ?? this.organizationId,
      initialLocation: initialLocation ?? this.initialLocation,
    );
  }

  @override
  List<Object?> get props =>
      [status, email, user, otpId, error, organizationId];
}
