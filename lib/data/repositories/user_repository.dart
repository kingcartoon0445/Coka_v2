import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:source_base/core/error/exceptions.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository({
    required this.apiService,
  });

  // Phương thức đăng nhập
  Future<String?> loginRepository(String email) async {
    try {
      // Gọi API đăng nhập
      final response = await apiService.loginService(email);

      // Lưu token vào bộ nhớ cục bộ
      // final token = response.data['token'];
      // await storageService.setToken(token);

      // Lưu user ID vào bộ nhớ cục bộ
      // final user = UserModel.fromJson(response.data['user']);
      // await storageService.setUserId(user.id);
      final otpId = response.data['content']['otpId'];
      return otpId;
    } on DioException catch (e) {
      return null;
      // throw ServerException(
      //   message: e.response?.data['message'] ?? 'Lỗi đăng nhập',
      //   statusCode: e.response?.statusCode ?? 0,
      // );
    }
  }

  Future<Map<String, dynamic>?> reSendOtpRepository(String otpId) async {
    try {
      final response = await apiService.reSendOtpService(otpId);

      return response.data;
    } on DioException catch (e) {
      log("message: $e");
      return null;
    }
  }

  Future<Response> verifyOTPRepository(
      {required String otpID, required String otpCode}) async {
    try {
      final response = await apiService.verifyOTPService(
        otpId: otpID, // Replace with actual OTP ID
        otpCode: otpCode, // Replace with actual OTP code
      );
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi xác thực OTP',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> getUserProfileRepository() async {
    try {
      final response = await apiService.getUserInfoService();
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi lấy thông tin người dùng',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> updateProfileRepository(
    Map<String, dynamic> data, {
    File? avatar,
  }) async {
    try {
      final response =
          await apiService.updateProfileService(data, avatar: avatar);

      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ??
            'Lỗi khi thay đổi thông tin người dùng',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> loginWithGoogleRepository(
      {bool forceNewAccount = false}) async {
    try {
      final response =
          await apiService.loginWithGoogle(forceNewAccount: forceNewAccount);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi đăng nhập Google',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> loginWithFacebookRepository(
      {bool forceNewAccount = false}) async {
    try {
      final response =
          await apiService.loginWithFacebook(forceNewAccount: forceNewAccount);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi đăng nhập Facebook',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  // Phương thức đăng ký
  // Future<UserModel> register(String name, String email, String password) async {
  //   try {
  //     // Gọi API đăng ký
  //     final response = await apiService.register(name, email, password);

  //     // Lưu token vào bộ nhớ cục bộ
  //     final token = response.data['token'];
  //     await storageService.setToken(token);

  //     // Lưu user ID vào bộ nhớ cục bộ
  //     final user = UserModel.fromJson(response.data['user']);
  //     await storageService.setUserId(user.id);

  //     return user;
  //   } on DioException catch (e) {
  //     throw ServerException(
  //       message: e.response?.data['message'] ?? 'Lỗi đăng ký',
  //       statusCode: e.response?.statusCode ?? 0,
  //     );
  //   }
  // }

  // // Phương thức lấy thông tin người dùng
  // Future<UserModel> getUserProfile() async {
  //   try {
  //     final response = await apiService.getUserProfile();
  //     return UserModel.fromJson(response.data['user']);
  //   } on DioException catch (e) {
  //     throw ServerException(
  //       message: e.response?.data['message'] ?? 'Lỗi lấy thông tin',
  //       statusCode: e.response?.statusCode ?? 0,
  //     );
  //   }
  // }


  // Phương thức đăng xuất
  Future<void> logout() async {
    // await storageService.removeToken();
    // await storageService.removeUserId();
    SharedPreferencesService().remove(PrefKey.accessToken);
    SharedPreferencesService().remove(PrefKey.defaultOrganizationId);
    SharedPreferencesService().remove(PrefKey.refreshToken);
  }

  // Kiểm tra xem người dùng đã đăng nhập chưa
  // bool isLoggedIn() {
  //   // final token = storageService.getToken();
  //   // return token != null && token.isNotEmpty;
  // }
}
