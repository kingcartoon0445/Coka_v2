import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';

class MessageRepository {
  final DioClient _dioClient;

  MessageRepository(this._dioClient);
  Future<Map<String, dynamic>> connectFacebook(
      String organizationId, dynamic data) async {
    final response = await _dioClient.post(
      ApiEndpoints.fbConnect,
      data: data,
      options: Options(headers: {'organizationid': organizationId}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getConversationList(
    String organizationId, {
    int page = 0,
    String? provider,
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/organizations/$organizationId/conversations',
        queryParameters: {
          'page': page,
          'limit': 20,
          if (provider != null) 'provider': provider,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load conversations: $e');
    }
  }

  Future<void> updateStatusReadRepos(
    String organizationId, {
    required String conversationId,
  }) async {
    try {
      await _dioClient.put(
        '/api/organizations/$organizationId/conversations/$conversationId/read',
      );
    } catch (e) {
      throw Exception('Failed to update read status: $e');
    }
  }

  Future<void> assignConversation(
    String organizationId,
    String conversationId,
    String userId,
  ) async {
    try {
      await _dioClient.put(
        '/api/organizations/$organizationId/conversations/$conversationId/assign',
        data: {
          'userId': userId,
        },
      );
    } catch (e) {
      throw Exception('Failed to assign conversation: $e');
    }
  }

  Future<Map<String, dynamic>> getOData() async {
    try {
      final response =
          await _dioClient.get('/api/v1/organization/getlistpaging');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get organization data: $e');
    }
  }
}
