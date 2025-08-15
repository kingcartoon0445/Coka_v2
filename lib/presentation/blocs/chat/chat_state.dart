// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/chat_detail_response.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/facebook_chat_response.dart';
import 'package:source_base/presentation/screens/chat_detail_page/model/message_model.dart';

enum ChatStatus { initial, loading, success, error, sending }

class ChatState extends Equatable {
  final ChatStatus status;
  // final List<ChatModel> customerServices;

  final String? organizationId;
  final List<Message> chats;
  final bool isSending;
  final String? error;
  const ChatState({
    this.status = ChatStatus.initial,
    // this.customerServices = const [],
    this.isSending = false,
    this.error,
    this.organizationId,
    this.chats = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    // List<ChatDetail>? chats,
    bool? isSending,
    String? error,
    String? organizationId,
    CustomerServiceModel? facebookChat,
    List<Message>? chats,
  }) {
    return ChatState(
      status: status ?? this.status,
      // customerServices: customerServices ?? this.customerServices,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
      organizationId: organizationId ?? this.organizationId,
      chats: chats ?? this.chats,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isSending,
        error,
        organizationId,
        chats,
      ];
}
