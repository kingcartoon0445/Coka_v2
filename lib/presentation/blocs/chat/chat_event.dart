import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:source_base/data/models/facebook_chat_response.dart';
import 'package:source_base/data/models/user_profile.dart';
import 'package:source_base/presentation/screens/chat_detail_page/model/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái xác thực
class CheckChatStatus extends ChatEvent {}

class LoadChats extends ChatEvent {
  final String limit;
  final String offset;
  final String searchText;

  const LoadChats({
    required this.limit,
    required this.offset,
    required this.searchText,
  });
}

 
class LoadChat extends ChatEvent {
  final String organizationId;
  final String conversationId;
  final int limit;
  final int offset;

  const LoadChat({
    required this.organizationId,
    required this.conversationId,
    required this.limit,
    required this.offset,
  });
}

class LoadMessage extends ChatEvent {
  final Message data;

  const LoadMessage({required this.data});

  @override
  List<Object?> get props => [data];
}

// Sự kiện gửi tin nhắn
class SendMessage extends ChatEvent {
  final String organizationId;
  final String conversationId;
  final String message;
  final String? messageId;
  final List<Attachment>? attachments;
  final UserProfile? user;
  final File? attachment;
  final String? attachmentName;

  const SendMessage({
    required this.organizationId,
    required this.conversationId,
    required this.message,
    this.messageId,
    this.attachments,
    this.attachment,
    this.attachmentName,
    this.user,
  });

  @override
  List<Object?> get props => [
        organizationId,
        conversationId,
        message,
        messageId,
        attachments,
        attachment,
        attachmentName,
        user,
      ];
}

class ToolListenFirebase extends ChatEvent {
  final String organizationId;
  final String conversationId;

  const ToolListenFirebase({
    required this.organizationId,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [organizationId, conversationId];
}

class AddMessage extends ChatEvent {
  final Message message;
  const AddMessage({required this.message});
}

class SendImageMessage extends ChatEvent {
  final String organizationId;
  final String conversationId;
  final XFile imageFile;
  final String? textMessage;

  const SendImageMessage({
    required this.organizationId,
    required this.conversationId,
    required this.imageFile,
    this.textMessage,
  });
}

class DisableFirebaseListener extends ChatEvent {}
