import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/reminder_service_body.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_state.dart';

abstract class CustomerDetailEvent extends Equatable {
  const CustomerDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerDetail extends CustomerDetailEvent {
  final String customerId;
  final String organizationId;
  final bool isCustomer;

  const LoadCustomerDetail({
    required this.customerId,
    required this.organizationId,
    this.isCustomer = false,
  });

  @override
  List<Object?> get props => [customerId, organizationId];
}

class LoadCustomerDetailValue extends CustomerDetailEvent {
  final CustomerServiceModel? customerService;
  final String organizationId;
  final String? type;
  final bool isChat;
  const LoadCustomerDetailValue({
    this.customerService,
    required this.organizationId,
    this.type,
    this.isChat = false,
  });

  @override
  List<Object?> get props => [customerService, organizationId, type];
}

class LoadMoreServiceDetails extends CustomerDetailEvent {
  final String organizationId;
  final int limit;
  final int offset;
  final String? type;

  const LoadMoreServiceDetails({
    required this.organizationId,
    required this.limit,
    required this.offset,
    this.type,
  });

  @override
  List<Object?> get props => [organizationId, limit, offset, type];
}

class PostCustomerNote extends CustomerDetailEvent {
  final String customerId;
  final String customerName;
  final String note;
  final String organizationId;

  const PostCustomerNote({
    required this.customerId,
    required this.customerName,
    required this.note,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [customerId, customerName, note, organizationId];
}

class UpdateNoteMark extends CustomerDetailEvent {
  final String ScheduleId;
  final bool isDone;
  final String Notes;

  const UpdateNoteMark({
    required this.ScheduleId,
    required this.isDone,
    required this.Notes,
  });

  @override
  List<Object?> get props => [ScheduleId, isDone, Notes];
}

class CreateReminder extends CustomerDetailEvent {
  final String organizationId;
  final ReminderServiceBody body;

  const CreateReminder({
    required this.organizationId,
    required this.body,
  });

  @override
  List<Object?> get props => [organizationId, body];
}

class UpdateReminder extends CustomerDetailEvent {
  final String organizationId;
  final ReminderServiceBody body;

  const UpdateReminder({
    required this.organizationId,
    required this.body,
  });

  @override
  List<Object?> get props => [organizationId, body];
}

class DeleteReminder extends CustomerDetailEvent {
  final String organizationId;
  final String reminderId;

  const DeleteReminder({
    required this.organizationId,
    required this.reminderId,
  });

  @override
  List<Object?> get props => [organizationId, reminderId];
}

class LoadPaginges extends CustomerDetailEvent {
  final String organizationId;

  const LoadPaginges({
    required this.organizationId,
  });

  @override
  List<Object?> get props => [organizationId];
}

class ShowError extends CustomerDetailEvent {
  final String error;
  final CustomerDetailStatus status;

  const ShowError({
    required this.error,
    required this.status,
  });

  @override
  List<Object?> get props => [error, status];
}

class DisposeCustomerDetail extends CustomerDetailEvent {
  const DisposeCustomerDetail();

  @override
  List<Object?> get props => [];
}

class LinkToLeadEvent extends CustomerDetailEvent {
  final String organizationId;
  final String conversationId;
  final String leadId;

  const LinkToLeadEvent({
    required this.organizationId,
    required this.conversationId,
    required this.leadId,
  });

  @override
  List<Object?> get props => [organizationId, conversationId, leadId];
}

class SearchCustomerEvent extends CustomerDetailEvent {
  final String organizationId;
  final String name;

  const SearchCustomerEvent({
    required this.organizationId,
    required this.name,
  });

  @override
  List<Object?> get props => [organizationId, name];
}

class SearchCustomerPagingesEvent extends CustomerDetailEvent {
  final String organizationId;
  final String name;

  const SearchCustomerPagingesEvent({
    required this.organizationId,
    required this.name,
  });
}

class CancelSearch extends CustomerDetailEvent {}

class LoadFacebookChat extends CustomerDetailEvent {
  final String organizationId;
  final String conversationId;
  final CustomerServiceModel? facebookChat;
  final bool isChat;
  const LoadFacebookChat({
    required this.organizationId,
    required this.conversationId,
    this.facebookChat,
    this.isChat = false,
  });

  @override
  List<Object?> get props => [organizationId, conversationId, facebookChat];
}

class CancelSearchCustomer extends CustomerDetailEvent {}
