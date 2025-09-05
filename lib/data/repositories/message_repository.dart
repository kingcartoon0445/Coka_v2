import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';

class MessageRepository {
  final DioClient _dioClient;

  MessageRepository(this._dioClient);

  // ------------------------------
  // Helpers
  // ------------------------------

  Options _org(String organizationId) =>
      Options(headers: {'organizationId': organizationId});

  Response<Map<String, dynamic>> _error(String path, Object e,
      {int status = 500, String code = 'unknown_error'}) {
    return Response<Map<String, dynamic>>(
      data: {'success': false, 'error': code, 'message': e.toString()},
      statusCode: status,
      statusMessage: code,
      requestOptions: RequestOptions(path: path),
    );
  }

  Future<Response> _safe(String path, Future<Response> Function() call) async {
    try {
      return await call();
    } catch (e) {
      return _error(path, e);
    }
  }

  // ------------------------------
  // Facebook / Omni
  // ------------------------------

  /// Kết nối Facebook Lead (v2)
  Future<Map<String, dynamic>> connectFacebook(
      String organizationId, dynamic data) async {
    final path = ApiEndpoints.fbConnectLead();
    final res = await _safe(
      path,
      () => _dioClient.post(path, data: data, options: _org(organizationId)),
    );
    return (res.data as Map<String, dynamic>);
  }

  /// Danh sách hội thoại omni
  /// NOTE: API mới là `/api/v1/omni/conversation/getlistpaging`.
  /// Giữ tham số quen dùng (page, limit, provider) → map vào query.
  Future<Map<String, dynamic>> getConversationList(
    String organizationId, {
    int page = 0,
    int limit = 20,
    String? provider,
  }) async {
    final path = ApiEndpoints.conversationList();
    final res = await _safe(
      path,
      () => _dioClient.get(
        path,
        options: _org(organizationId),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (provider != null) 'provider': provider,
        },
      ),
    );
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load conversations: ${res.statusMessage}');
    }
    return (res.data as Map<String, dynamic>);
  }

  /// Đánh dấu đã đọc hội thoại
  Future<void> updateStatusReadRepos(
    String organizationId, {
    required String conversationId,
  }) async {
    final path = ApiEndpoints.updateStatusRead(conversationId);
    final res = await _safe(
      path,
      () => _dioClient.patch(path, options: _org(organizationId)),
    );
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to update read status: ${res.statusMessage}');
    }
  }

  /// Gán hội thoại cho user
  /// API gợi ý: dùng omni/conversation, convention endpoint `/{id}/assign`
  /// (Nếu BE yêu cầu body khác, cập nhật tại đây.)
  Future<void> assignConversation(
    String organizationId,
    String conversationId,
    String userId,
  ) async {
    final path = '${ApiEndpoints.assignConversation()}/$conversationId/assign';
    final res = await _safe(
      path,
      () => _dioClient.put(
        path,
        options: _org(organizationId),
        data: {'userId': userId},
      ),
    );
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to assign conversation: ${res.statusMessage}');
    }
  }

  /// Lấy OData tổ chức (paging)
  Future<Map<String, dynamic>> getOData() async {
    final path = ApiEndpoints.organizationPaging();
    final res = await _safe(path, () => _dioClient.get(path));
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to get organization data: ${res.statusMessage}');
    }
    return (res.data as Map<String, dynamic>);
  }
}
