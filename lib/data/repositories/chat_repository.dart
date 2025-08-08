import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';

import 'package:http_parser/http_parser.dart';

class ChatRepository {
  final ApiService apiService;

  ChatRepository({required this.apiService});

  Future<Response> getChatList(String organizationId, String conversationId,
      int limit, int offset) async {
    return await apiService.getChatListService(
        organizationId, conversationId, limit, offset);
  }

  Future<Response> sendMessage(
    String organizationId,
    String conversationId,
    String message, {
    String? messageId,
    List<Map<String, dynamic>>? attachments,
    File? attachment,
    String? attachmentName,
  }) async {
    final formData = FormData.fromMap({
      'conversationId': conversationId,
      'messageId': messageId ?? 'undefined',
      'message': message,
    });

    // ✅ Đính kèm 1 file đơn (ví dụ ảnh)
    if (attachment != null) {
      formData.files.add(MapEntry(
        'Attachment',
        await MultipartFile.fromFile(
          attachment.path,
          filename: attachmentName ?? attachment.path.split('/').last,
        ),
      ));
    }

    // ✅ Đính kèm nhiều file dạng Map (custom attachments nếu bạn xử lý dạng này)
    if (attachments != null && attachments.isNotEmpty) {
      for (final item in attachments) {
        final file = item['file'] as File?;
        final name = item['name'] as String?;
        if (file != null) {
          formData.files.add(MapEntry(
            'Attachment',
            await MultipartFile.fromFile(
              file.path,
              filename: name ?? file.path.split('/').last,
            ),
          ));
        }
      }
    }
    return await apiService.sendMessageService(
        organizationId, conversationId, formData);
  }

  Future<Response> sendImageMessage(
    String organizationId,
    String conversationId,
    XFile imageFile, {
    String? textMessage,
  }) async {
    final formData = FormData.fromMap({
      'conversationId': conversationId,
      'messageId': 'undefined',
      'message': textMessage ?? '',
      'Attachment': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.name,
        contentType: MediaType('image', imageFile.path.split('.').last),
      ),
    });

    return await apiService.sendImageMessageService(organizationId, formData);
  }
}
