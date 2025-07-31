import 'package:dio/dio.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/dio/service_locator.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Lấy token từ bộ nhớ cục bộ và thêm vào header
    final token =
        getIt<SharedPreferencesService>().getString(PrefKey.accessToken) ?? '';

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Xử lý khi token hết hạn (401 Unauthorized)
    if (err.response?.statusCode == 401) {
      // Xóa token cũ và chuyển hướng về trang đăng nhập
      getIt<SharedPreferencesService>().remove(PrefKey.accessToken);

      // Tại đây có thể điều hướng người dùng về màn hình đăng nhập
      // Ví dụ: NavigationService.navigateToLogin();
    }

    return super.onError(err, handler);
  }
}
