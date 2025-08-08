import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/data/models/chat_detail_response.dart';
import 'package:source_base/data/repositories/chat_repository.dart';
import 'package:source_base/presentation/screens/chat_detail_page/model/message_model.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription? _onChangedListener;

  ChatBloc({required this.chatRepository}) : super(const ChatState()) {
    on<LoadChat>(_onLoadChat); 
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<ToolListenFirebase>(onToolListenFirebase);
    on<DisableFirebaseListener>(onDisableFirebaseListener);
    on<AddMessage>(_onAddMessage);
  }

  void _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    // Nếu offset = 0, là load mới, còn lại là loadmore
    final isLoadMore = event.offset > 0;
    if (!isLoadMore) {
      emit(state.copyWith(status: ChatStatus.loading, error: null));
    }

    try {
      final response = await chatRepository.getChatList(
        event.organizationId,
        event.conversationId,
        event.limit,
        event.offset,
      );
      final chatDetailResponse = ChatDetailResponse.fromJson(response.data);
      final chats = chatDetailResponse.content ?? [];

      if (isLoadMore) {
        // Nối thêm vào danh sách cũ
        emit(state.copyWith(
          status: ChatStatus.success,
          chats: List<Message>.from(state.chats)..addAll(chats),
          error: null,
        ));
      } else {
        // Load mới
        emit(state.copyWith(
          status: ChatStatus.success,
          chats: chats,
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: e.toString(),
      ));
    }
  }
 

  // Event: ToolListenFirebase
  Future<void> onToolListenFirebase(
    ToolListenFirebase event,
    Emitter<ChatState> emit,
  ) async {
    await _onChangedListener?.cancel();

    final ref = FirebaseDatabase.instance.ref(
      'root/OrganizationId: ${event.organizationId}/CreateOrUpdateConversation',
    );

    _onChangedListener = ref.onValue.listen((eventListen) {
      final snapshot = eventListen.snapshot;
      final data = (snapshot.value ?? {}) as Map;
      log("Data changed: ${data.toString()}");

      final dataMess = data["ConversationId: ${event.conversationId}"];
      if (dataMess is Map &&
          dataMess["ConversationId"] == event.conversationId) {
        Attachment? fileAttachment;

        if (dataMess.containsKey("Attachments")) {
          final outerKeys = dataMess["Attachments"];
          final List<dynamic> decodedList = jsonDecode(outerKeys);

          for (final outerKey in decodedList) {
            fileAttachment =
                Attachment.fromJson(outerKey as Map<String, dynamic>);
          }
        }

        final message = Message(
          id: dataMess["Id"] ?? '',
          message: dataMess["Message"] ?? "",
          to: dataMess["To"],
          toName: dataMess["ToName"],
          from: dataMess["From"],
          isFromMe: dataMess["IsPageReply"] ?? true,
          fromName: dataMess["FromName"],
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          isGpt: false,
          type: dataMess["Type"] ?? "MESSAGE",
          fullName: dataMess["FullName"],
          status: 0,
          sending: false,
          attachments: fileAttachment != null ? [fileAttachment] : [],
          conversationId: event.conversationId,
        );
        add(AddMessage(
          message: message,
        ));
        // emit(state.copyWith(chats: [message, ...state.chats]));
      }
    });
  }

  void _onAddMessage(AddMessage event, Emitter<ChatState> emit) {
    List<Message> chats =
        state.chats.where((element) => element.localId == null).toList();
    emit(state.copyWith(chats: [event.message, ...chats]));
  }

  void onDisableFirebaseListener(
      DisableFirebaseListener event, Emitter<ChatState> emit) async {
    await _onChangedListener?.cancel();
  }

  // void addMessage(Message message) {
  //   final updatedChats = List<Message>.from(state.chats);
  //   updatedChats.add(message);
  //   emit(state.copyWith(chats: updatedChats));
  //   // add(LoadFacebookChat(facebookChat: message)); // hoặc emit state mới nếu cần
  // }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    // Bắt đầu gửi tin nhắn
    emit(state.copyWith(isSending: true, error: null));
    Message localMessage = Message(
      id: event.messageId ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      localId:
          event.messageId ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: event.conversationId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isFromMe: true,
      fromName: event.user?.fullName ?? '',
      toName: 'Customer',
      message: event.message,
      fullName: event.user?.fullName ?? '',
      type: 'text',
      status: 0,
      isPageReply: false,
      sending: true,
      attachments: event.attachments,
      fileAttachment: null,
      avatar: event.user?.avatar,
      // Thêm các trường khác nếu cần thiết
    );
    emit(state.copyWith(
      chats: [localMessage, ...state.chats],
      isSending: true,
      error: null,
    ));
    try {
      final response = await chatRepository.sendMessage(
        event.organizationId,
        event.conversationId,
        event.message,
        messageId: event.messageId,
        attachments: event.attachments?.map((e) => e.toJson()).toList(),
        attachment: event.attachment,
        attachmentName: event.attachmentName,
      );

      // Gửi tin nhắn thành công
      emit(state.copyWith(isSending: false, error: null));

      // Tùy chọn: Reload chat để hiển thị tin nhắn mới
      // add(LoadChat(
      //   organizationId: event.organizationId,
      //   conversationId: event.conversationId,
      //   limit: 20,
      //   offset: 0,
      // ));
    } catch (e) {
      // Gửi tin nhắn thất bại
      emit(state.copyWith(
        isSending: false,
        error: e.toString(),
      ));
    }
  }

  void _onSendImageMessage(
      SendImageMessage event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isSending: true, error: null));
    try {
      final response = await chatRepository.sendImageMessage(
        event.organizationId,
        event.conversationId,
        event.imageFile,
        textMessage: event.textMessage,
      );
      emit(state.copyWith(isSending: false, error: null));
      // Tùy chọn: Reload chat để hiển thị tin nhắn mới
      // add(LoadChat(
      //   organizationId: event.organizationId,
      //   conversationId: event.conversationId,
      //   limit: 20,
      //   offset: 0,
      // ));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _onChangedListener?.cancel();
    return super.close();
  }
}
