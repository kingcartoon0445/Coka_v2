import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:source_base/data/models/conversation_model.dart';
import 'package:source_base/presentation/screens/chat_detail_page/model/message_model.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends MessageEvent {
  final String organizationId;
  final String? provider;
  final bool forceRefresh;

  const LoadConversations({
    required this.organizationId,
    this.provider,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [organizationId, provider, forceRefresh];
}

class LoadMoreConversations extends MessageEvent {
  final String organizationId;
  final String? provider;

  const LoadMoreConversations({
    required this.organizationId,
    this.provider,
  });

  @override
  List<Object?> get props => [organizationId, provider];
}

class SelectConversation extends MessageEvent {
  final String conversationId;

  const SelectConversation({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class UpdateStatusRead extends MessageEvent {
  final String organizationId;
  final String conversationId;

  const UpdateStatusRead({
    required this.organizationId,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [organizationId, conversationId];
}

class AssignConversation extends MessageEvent {
  final String organizationId;
  final String conversationId;
  final String userId;
  final String assignName;
  final String? assignAvatar;

  const AssignConversation({
    required this.organizationId,
    required this.conversationId,
    required this.userId,
    required this.assignName,
    this.assignAvatar,
  });

  @override
  List<Object?> get props =>
      [organizationId, conversationId, userId, assignName, assignAvatar];
}

class UpdateConversation extends MessageEvent {
  final Conversation updatedConversation;
  final bool moveToTop;

  const UpdateConversation({
    required this.updatedConversation,
    this.moveToTop = false,
  });

  @override
  List<Object?> get props => [updatedConversation, moveToTop];
}

class AddConversation extends MessageEvent {
  final Conversation newConversation;

  const AddConversation({required this.newConversation});

  @override
  List<Object?> get props => [newConversation];
}

class ClearConversations extends MessageEvent {}

class SetupFirebaseListener extends MessageEvent {
  final String organizationId;
  final BuildContext context;

  const SetupFirebaseListener({
    required this.organizationId,
    required this.context,
  });

  @override
  List<Object?> get props => [organizationId, context];
}

class DissTabRequested extends MessageEvent {}
