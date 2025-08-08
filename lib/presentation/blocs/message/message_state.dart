import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/conversation_model.dart';

enum MessageStatus { initial, loading, loadingMore, success, error }

class MessageState extends Equatable {
  final MessageStatus status;
  final List<Conversation> conversations;
  final Conversation? selectedConversation;
  final int page;
  final bool hasMore;
  final String? searchText;
  final String? provider;
  final String? error;

  const MessageState({
    this.status = MessageStatus.initial,
    this.conversations = const [],
    this.selectedConversation,
    this.page = 0,
    this.hasMore = true,
    this.searchText,
    this.provider,
    this.error,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<Conversation>? conversations,
    Conversation? selectedConversation,
    int? page,
    bool? hasMore,
    String? searchText,
    String? provider,
    String? error,
  }) {
    return MessageState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      searchText: searchText ?? this.searchText,
      provider: provider ?? this.provider,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        conversations,
        selectedConversation,
        page,
        hasMore,
        searchText,
        provider,
        error,
      ];
}
