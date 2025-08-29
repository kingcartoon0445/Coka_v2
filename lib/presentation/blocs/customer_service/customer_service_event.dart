import 'package:equatable/equatable.dart';
import 'package:source_base/config/enum_platform.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/reminder_service_body.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_state.dart';

abstract class CustomerServiceEvent extends Equatable {
  const CustomerServiceEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái xác thực
class CheckCustomerServiceStatus extends CustomerServiceEvent {
  const CheckCustomerServiceStatus();

  @override
  List<Object?> get props => [];
}

class LoadCustomerServices extends CustomerServiceEvent {
  final String limit;
  final String offset;
  final String searchText;

  const LoadCustomerServices({
    required this.limit,
    required this.offset,
    required this.searchText,
  });

  @override
  List<Object?> get props => [limit, offset, searchText];
}

class LoadCustomerService extends CustomerServiceEvent {
  final String organizationId;
  final LeadPagingRequest? pagingRequest;
  const LoadCustomerService({
    required this.organizationId,
    this.pagingRequest,
  });

  @override
  List<Object?> get props => [organizationId, pagingRequest];
}

class LoadJourneyPaging extends CustomerServiceEvent {
  final CustomerServiceModel? customerService;
  final String organizationId;
  final String? type;
  const LoadJourneyPaging({
    this.customerService,
    required this.organizationId,
    this.type,
  });

  @override
  List<Object?> get props => [customerService, organizationId, type];
}

class PostCustomerNote extends CustomerServiceEvent {
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

class UpdateNoteMark extends CustomerServiceEvent {
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

class LoadMoreServiceDetails extends CustomerServiceEvent {
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

class LoadMoreCustomers extends CustomerServiceEvent {
  final String organizationId;
  final LeadPagingRequest? pagingRequest;

  const LoadMoreCustomers({
    required this.organizationId,
    this.pagingRequest,
  });

  @override
  List<Object?> get props => [organizationId, pagingRequest];
}

class CreateReminder extends CustomerServiceEvent {
  final String organizationId;
  final ReminderServiceBody body;

  const CreateReminder({
    required this.organizationId,
    required this.body,
  });

  @override
  List<Object?> get props => [organizationId, body];
}

class PostArchiveCustomer extends CustomerServiceEvent {
  final String customerId;
  final String organizationId;

  const PostArchiveCustomer({
    required this.customerId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [customerId, organizationId];
}

class LoadFirstProviderChat extends CustomerServiceEvent {
  final String organizationId;
  final String provider;

  const LoadFirstProviderChat({
    required this.organizationId,
    required this.provider,
  });

  @override
  List<Object?> get props => [organizationId, provider];
}

class LoadZaloChat extends CustomerServiceEvent {
  final String organizationId;

  const LoadZaloChat({
    required this.organizationId,
  });

  @override
  List<Object?> get props => [organizationId];
}

class LoadMoreProviderChats extends CustomerServiceEvent {
  final String organizationId;
  final String provider;
  final int limit;
  final int offset;

  const LoadMoreProviderChats({
    required this.organizationId,
    required this.provider,
    required this.limit,
    required this.offset,
  });

  @override
  List<Object?> get props => [organizationId, provider, limit, offset];
}

class StorageConvertToCustomer extends CustomerServiceEvent {
  final String customerId;
  final String organizationId;

  const StorageConvertToCustomer({
    required this.customerId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [customerId, organizationId];
}

class StorageUnArchiveCustomer extends CustomerServiceEvent {
  final String customerId;
  final String organizationId;

  const StorageUnArchiveCustomer({
    required this.customerId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [customerId, organizationId];
}

class ChangeStatusRead extends CustomerServiceEvent {
  final String organizationId;
  final String conversationId;
  const ChangeStatusRead({
    required this.organizationId,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [organizationId, conversationId];
}

class FirebaseConversationUpdated extends CustomerServiceEvent {
  final CustomerServiceModel conversation;
  final String organizationId;
  final bool isUpdate;
  final bool isRead;

  const FirebaseConversationUpdated({
    required this.conversation,
    required this.organizationId,
    this.isUpdate = false,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [conversation, organizationId, isUpdate];
}

class UpdateReminder extends CustomerServiceEvent {
  final String organizationId;
  final ReminderServiceBody body;

  const UpdateReminder({
    required this.organizationId,
    required this.body,
  });

  @override
  List<Object?> get props => [organizationId, body];
}

class DeleteReminder extends CustomerServiceEvent {
  final String organizationId;
  final String reminderId;

  const DeleteReminder({
    required this.organizationId,
    required this.reminderId,
  });

  @override
  List<Object?> get props => [organizationId, reminderId];
}

class ToggleFirebaseListenerRequested extends CustomerServiceEvent {
  final String organizationId;
  final bool isEnabled;
  final String userId;
  final PlatformSocial platform;

  const ToggleFirebaseListenerRequested({
    required this.organizationId,
    required this.isEnabled,
    required this.platform,
    required this.userId,
  });

  @override
  List<Object?> get props => [organizationId, isEnabled, platform, userId];
}

class DisableFirebaseListenerRequested extends CustomerServiceEvent {
  final String organizationId;

  const DisableFirebaseListenerRequested({
    required this.organizationId,
  });

  @override
  List<Object?> get props => [organizationId];
}

class LoadFacebookChat extends CustomerServiceEvent {
  final String conversationId;
  final CustomerServiceModel? facebookChat;

  const LoadFacebookChat({
    required this.conversationId,
    this.facebookChat,
  });

  @override
  List<Object?> get props => [facebookChat];
}

class DeleteCustomer extends CustomerServiceEvent {
  final String customerId;
  final String organizationId;

  const DeleteCustomer({
    required this.customerId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [customerId, organizationId];
}

class LoadCustomerDetail extends CustomerServiceEvent {
  final String customerId;
  final String organizationId;

  const LoadCustomerDetail({
    required this.customerId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [customerId, organizationId];
}

class ShowError extends CustomerServiceEvent {
  final String error;
  final CustomerServiceStatus status;

  const ShowError({
    required this.error,
    required this.status,
  });

  @override
  List<Object?> get props => [error, status];
}
