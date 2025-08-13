import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/reminder_service_body.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

abstract class DealActivityEvent extends Equatable {
  const DealActivityEvent();

  @override
  List<Object> get props => [];
}

class LoadDealActivity extends DealActivityEvent {
  final String organizationId;
  final List<BusinessProcessModel>? businessProcesses;

  final BusinessProcessTaskModel? businessProcessTask;
  final String? workspaceId;

  const LoadDealActivity({
    required this.organizationId,
    this.businessProcesses,
    this.businessProcessTask,
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

  class RemoveState extends DealActivityEvent {}
