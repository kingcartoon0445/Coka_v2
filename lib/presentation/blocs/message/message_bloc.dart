import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/data/models/conversation_model.dart';
import 'package:source_base/data/repositories/message_repository.dart';

import 'package:firebase_database/firebase_database.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _repository;
  final String? _defaultProvider;
  StreamSubscription? _onChangedListener;

  MessageBloc({
    required MessageRepository repository,
    String? defaultProvider,
  })  : _repository = repository,
        _defaultProvider = defaultProvider,
        super(MessageState(provider: defaultProvider)) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMoreConversations>(_onLoadMoreConversations);
    on<SelectConversation>(_onSelectConversation);
    on<UpdateStatusRead>(_onUpdateStatusRead);
    on<AssignConversation>(_onAssignConversation);
    on<UpdateConversation>(_onUpdateConversation);
    on<AddConversation>(_onAddConversation);
    on<ClearConversations>(_onClearConversations);
    on<SetupFirebaseListener>(_onSetupFirebaseListener);
    on<DissTabRequested>(_onDissTabRequested);
  }

  @override
  Future<void> close() {
    _onChangedListener?.cancel();
    return super.close();
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<MessageState> emit,
  ) async {
    if (state.status == MessageStatus.loading) return;

    final currentProvider = event.provider ?? _defaultProvider;

    // Reset state nếu là lần fetch đầu tiên hoặc forceRefresh
    if (state.page == 0 || event.forceRefresh) {
      emit(state.copyWith(
        status: MessageStatus.loading,
        provider: currentProvider,
        error: null,
      ));
    } else {
      emit(state.copyWith(status: MessageStatus.loading));
    }

    try {
      final response = await _repository.getConversationList(
        event.organizationId,
        page: event.forceRefresh ? 0 : state.page,
        provider: currentProvider,
      );

      final List<Conversation> conversations = (response['content'] as List)
          .map((item) => Conversation.fromJson(item))
          .toList();

      if (event.forceRefresh || state.page == 0) {
        emit(state.copyWith(
          conversations: conversations,
          status: MessageStatus.success,
          hasMore: conversations.length >= 20,
          page: 1,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          conversations: [...state.conversations, ...conversations],
          status: MessageStatus.success,
          hasMore: conversations.length >= 20,
          page: state.page + 1,
          error: null,
        ));
      }
    } catch (e) {
      print('Error loading conversations: $e');
      emit(state.copyWith(
        status: MessageStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreConversations(
    LoadMoreConversations event,
    Emitter<MessageState> emit,
  ) async {
    if (state.status == MessageStatus.loadingMore || !state.hasMore) return;

    emit(state.copyWith(status: MessageStatus.loadingMore));

    try {
      final response = await _repository.getConversationList(
        event.organizationId,
        page: state.page,
        provider: event.provider ?? _defaultProvider,
      );

      final List<Conversation> conversations = (response['content'] as List)
          .map((item) => Conversation.fromJson(item))
          .toList();

      emit(state.copyWith(
        conversations: [...state.conversations, ...conversations],
        status: MessageStatus.success,
        hasMore: conversations.length >= 20,
        page: state.page + 1,
        error: null,
      ));
    } catch (e) {
      print('Error loading more conversations: $e');
      emit(state.copyWith(
        status: MessageStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onSelectConversation(
    SelectConversation event,
    Emitter<MessageState> emit,
  ) {
    try {
      final conversation = state.conversations.firstWhere(
        (conv) => conv.id == event.conversationId,
      );
      emit(state.copyWith(selectedConversation: conversation));
    } catch (_) {
      // Không làm gì nếu không tìm thấy conversation
    }
  }

  Future<void> _onUpdateStatusRead(
    UpdateStatusRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      // Cập nhật trạng thái đã đọc cho conversation
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(isRead: true);
        }
        return conv;
      }).toList();

      emit(state.copyWith(
        conversations: updatedConversations,
        selectedConversation:
            state.selectedConversation?.id == event.conversationId
                ? state.selectedConversation!.copyWith(isRead: true)
                : state.selectedConversation,
      ));

      // Gọi API để cập nhật trạng thái
      await _repository.updateStatusReadRepos(
        event.organizationId,
        conversationId: event.conversationId,
      );
    } catch (e) {
      print('Error updating status read: $e');
    }
  }

  Future<void> _onAssignConversation(
    AssignConversation event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _repository.assignConversation(
        event.organizationId,
        event.conversationId,
        event.userId,
      );

      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(
            assignName: event.assignName,
            assignAvatar: event.assignAvatar,
          );
        }
        return conv;
      }).toList();

      emit(state.copyWith(
        conversations: updatedConversations,
        selectedConversation:
            state.selectedConversation?.id == event.conversationId
                ? state.selectedConversation!.copyWith(
                    assignName: event.assignName,
                    assignAvatar: event.assignAvatar,
                  )
                : state.selectedConversation,
      ));
    } catch (e) {
      print('Error assigning conversation: $e');
      emit(state.copyWith(
        status: MessageStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onUpdateConversation(
    UpdateConversation event,
    Emitter<MessageState> emit,
  ) {
    List<Conversation> updatedList;

    if (event.moveToTop) {
      // Xoá bản cũ & đưa updated lên đầu
      updatedList = [
        event.updatedConversation,
        ...state.conversations
            .where((c) => c.id != event.updatedConversation.id),
      ];
    } else {
      // Cập nhật tại đúng vị trí cũ
      updatedList = state.conversations.map((c) {
        return c.id == event.updatedConversation.id
            ? event.updatedConversation
            : c;
      }).toList();
    }

    final isSelected =
        state.selectedConversation?.id == event.updatedConversation.id;

    emit(state.copyWith(
      conversations: updatedList,
      selectedConversation:
          isSelected ? event.updatedConversation : state.selectedConversation,
    ));
  }

  void _onAddConversation(
    AddConversation event,
    Emitter<MessageState> emit,
  ) {
    emit(state.copyWith(
      conversations: [event.newConversation, ...state.conversations],
    ));
  }

  void _onClearConversations(
    ClearConversations event,
    Emitter<MessageState> emit,
  ) {
    emit(state.copyWith(
      conversations: [],
      page: 0,
      hasMore: true,
      selectedConversation: null,
    ));
  }

  Future<void> _onSetupFirebaseListener(
    SetupFirebaseListener event,
    Emitter<MessageState> emit,
  ) async {
    final oData = await _repository.getOData();
    final oId = oData['content'][0]["id"];

    // Cancel listener cũ nếu có
    await _onChangedListener?.cancel();

    final ref = FirebaseDatabase.instance.ref(
      'root/OrganizationId: $oId',
    );

    _onChangedListener = ref.onValue.listen((eventLis) {
      final snapshot = eventLis.snapshot;
      final data = (snapshot.value ?? {}) as Map;
      bool isDetailUpdate = false;
      final matchedLocation = GoRouter.of(event.context).state.matchedLocation;
      final fullLocation = GoRouter.of(event.context).state.fullPath;
      log("Matched location: $matchedLocation");
      log("Data changed: ${data.toString()}");
      if (data.containsKey("CreateOrUpdateConversation")) {
        try {
          final outerKey = data["CreateOrUpdateConversation"]
              .keys
              .first; // "ConversationId: 368f9f83-7015-4306-a50b-7fe27db8c813"
          final key = outerKey
              .split(': ')
              .first; // "368f9f83-7015-4306-a50b-7fe27db8c813"
          if (key == "ConversationId") {
            final conversationId = outerKey
                .split(': ')
                .last; // "368f9f83-7015-4306-a50b-7fe27db8c813"
            if (fullLocation ==
                "/organization/:organizationId/messages/detail/:conversationId") {
              final Id = matchedLocation.split('/').last;
              if (Id == conversationId) {
                // Nếu đang ở trang chi tiết, cập nhật trạng thái là đã đọc
                isDetailUpdate = true;
              }
            }

            Conversation? roomData;
            try {
              roomData =
                  state.conversations.firstWhere((e) => e.id == conversationId);
            } catch (e) {
              roomData = null;
            }

            // ignore: unnecessary_null_comparison
            if (roomData != null) {
              Conversation updatedConversation = roomData;
              if (data["CreateOrUpdateConversation"][outerKey]
                  .containsKey("Message")) {
                updatedConversation = roomData.copyWith(
                    snippet: data["CreateOrUpdateConversation"][outerKey]
                        ["Message"],
                    isRead: isDetailUpdate);
                // Cập nhật conversation đã có
              }
              if (data["CreateOrUpdateConversation"][outerKey]
                  .containsKey("Attachments")) {
                updatedConversation = updatedConversation.copyWith(
                  isFileMessage: true,
                  isRead: isDetailUpdate,
                );
                // Nếu có file đính kèm, parse nó
                // if (dataMess.containsKey("Attachments")) {
                //   final outerKeys = dataMess["Attachments"];
                //   final List<dynamic> decodedList = jsonDecode(outerKeys);

                //   for (final outerKey in decodedList) {
                //     fileAttachment = Attachment.fromJson(outerKey as Map<String, dynamic>);
                //   }
                // }
              }

              // ignore: use_build_context_synchronously
              final currentLocation =
                  GoRouter.of(event.context).state.matchedLocation;
              print('Current route: $currentLocation');

              // Update the conversation in the state
              add(UpdateConversation(
                  updatedConversation: updatedConversation, moveToTop: true));
            } else {
              final decoded = jsonDecode(
                  data["CreateOrUpdateConversation"][outerKey].toString());

              // Thêm mới conversation
              final newConversation = Conversation.fromJson(decoded);
              add(AddConversation(newConversation: newConversation));
            }
            print(data["Message"]);
          }
// Tách ConversationId
        } catch (e) {
          log("message: $e");
          return;
        }
      }

      // final dataMess = data["ConversationId: $conversationId"];
      // if (dataMess is Map && dataMess["ConversationId"] == conversationId) {
      //   // final conversation = Conversation.fromJson(dataMess);
      //   // addConversation(conversation);
      // }
    });

    // Placeholder implementation - remove this when Firebase is implemented
    log("Firebase listener setup - Firebase not yet implemented");
  }

  void disableFirebaseListener() {
    _onChangedListener?.cancel();
    _onChangedListener = null;
  }

  void _onDissTabRequested(
    DissTabRequested event,
    Emitter<MessageState> emit,
  ) {
    emit(state.copyWith(status: MessageStatus.initial));
    disableFirebaseListener();
  }
}
