import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/reminder_service_body.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/product_selection_bottom_sheet.dart';

abstract class DealActivityEvent extends Equatable {
  const DealActivityEvent();

  @override
  List<Object> get props => [];
}

class LoadDealActivity extends DealActivityEvent {
  final String organizationId;
  final List<BusinessProcessModel>? businessProcesses;

  final TaskModel? task;
  final String? workspaceId;

  const LoadDealActivity({
    required this.organizationId,
    this.businessProcesses,
    this.task,
    this.workspaceId,
  });
}

class ChangeStage extends DealActivityEvent {
  final BusinessProcessModel? businessProcess;

  const ChangeStage({required this.businessProcess});
}

class UpdateStatus extends DealActivityEvent {
  final bool isSuccess;

  const UpdateStatus({required this.isSuccess});
}

class CreateReminderWorkspace extends DealActivityEvent {
  final ReminderServiceBody reminder;

  const CreateReminderWorkspace({required this.reminder});
}

class UpdateReminderWorkspace extends DealActivityEvent {
  final ReminderServiceBody reminder;

  const UpdateReminderWorkspace({required this.reminder});
}

class DeleteReminderWorkspace extends DealActivityEvent {
  final String reminderId;

  const DeleteReminderWorkspace({required this.reminderId});
}

class LoadDetailTask extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  final String? orderId;

  const LoadDetailTask({
    required this.organizationId,
    required this.taskId,
    this.orderId,
  });
}

class RemoveState extends DealActivityEvent {}

class UpdateCustomer extends DealActivityEvent {
  final String organizationId;
  final String id;
  final String fieldName;
  final String value;
  final bool isCustomer;
  final Completer<bool>? completer;

  const UpdateCustomer(
      {required this.organizationId,
      required this.id,
      required this.fieldName,
      required this.value,
      required this.isCustomer,
      this.completer});
}

class GetAllProduct extends DealActivityEvent {
  final String organizationId;
  const GetAllProduct({required this.organizationId});
}

class UpdateNoteMark extends DealActivityEvent {
  final String scheduleId;
  final bool isDone;

  const UpdateNoteMark({required this.scheduleId, required this.isDone});
}

class UpdateOrderList extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  final List<SelectedProduct> products;
  const UpdateOrderList(
      {required this.organizationId,
      required this.taskId,
      required this.products});
}

enum EditOrderType {
  duplicate,
  archive,
  delete,
}

class EditOrder extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  final EditOrderType type;
  const EditOrder({
    required this.organizationId,
    required this.taskId,
    required this.type,
  });
}

class DeleteOrder extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  const DeleteOrder({required this.organizationId, required this.taskId});
}

class ArchiveOrder extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  const ArchiveOrder({required this.organizationId, required this.taskId});
}

class DuplicateOrder extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  const DuplicateOrder({required this.organizationId, required this.taskId});
}

class SendNote extends DealActivityEvent {
  final String organizationId;
  final String taskId;
  final String note;
  const SendNote(
      {required this.organizationId, required this.taskId, required this.note});
}

class LoadCustomerDetail extends DealActivityEvent {
  final String organizationId;
  final String id;
  const LoadCustomerDetail({required this.organizationId, required this.id});
}
