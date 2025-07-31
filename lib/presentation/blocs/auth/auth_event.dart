import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái xác thực
class CheckAuthStatus extends AuthEvent {}

// Sự kiện yêu cầu đăng nhập
class LoginRequested extends AuthEvent {
  final String email;

  const LoginRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

class ReSendOtpRequested extends AuthEvent {
  final String otpId;

  const ReSendOtpRequested({
    required this.otpId,
  });

  @override
  List<Object?> get props => [otpId];
}

class SendVerifyOtpRequested extends AuthEvent {
  final String otpId;
  final String otpCode;

  const SendVerifyOtpRequested({
    required this.otpId,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [otpId];
}

class LoadUserInfoRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

// ignore: must_be_immutable
class UpdateUserProfileRequested extends AuthEvent {
  String fullName;
  String email;
  String phone;
  String dob;
  String gender;
  String address;
  File? avatar;
  UpdateUserProfileRequested(
      {required this.fullName,
      required this.email,
      required this.phone,
      required this.dob,
      required this.gender,
      required this.address,
      required this.avatar});
  @override
  List<Object?> get props =>
      [fullName, email, phone, dob, gender, address, avatar];
}

// Sự kiện yêu cầu đăng ký
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class LoginWithGoogleRequested extends AuthEvent {
  // final String
}

class LoginWithFacebookRequested extends AuthEvent {
  // final String
}

// Sự kiện yêu cầu đăng xuất
class LogoutRequested extends AuthEvent {}
