import 'package:equatable/equatable.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

import 'model/workspace_response.dart';

abstract class FinalDealEvent extends Equatable {
  const FinalDealEvent();

  @override
  List<Object?> get props => [];
}

class Initialized extends FinalDealEvent {
  const Initialized();
}

class GetAllWorkspace extends FinalDealEvent {
  final String organizationId;
  const GetAllWorkspace({required this.organizationId});
}

class SelectWorkspace extends FinalDealEvent {
  final WorkspaceModel workspace;
  final String organizationId;
  const SelectWorkspace(
      {required this.workspace, required this.organizationId});
}

class GetBusinessProcess extends FinalDealEvent {
  final String organizationId;
  final String workspaceId;
  const GetBusinessProcess(
      {required this.organizationId, required this.workspaceId});
}

class GetBusinessProcessTask extends FinalDealEvent {
  final String organizationId;
  final String? processId;
  final BusinessProcessModel? stage;
  final String? customerId;
  final String? assignedTo;
  final String? status;
  final bool includeHistory;
  final int page;
  final int pageSize;
  const GetBusinessProcessTask(
      {required this.organizationId,
      this.processId,
      this.stage,
      this.customerId,
      this.assignedTo,
      this.status,
      required this.includeHistory,
      required this.page,
      required this.pageSize});
}

class SelectBusinessProcess extends FinalDealEvent {
  final BusinessProcessModel businessProcess;
  final String organizationId;
  const SelectBusinessProcess(
      {required this.businessProcess, required this.organizationId});
}

 class GetDetailTask extends FinalDealEvent {
  final String organizationId;
  final String taskId;
  const GetDetailTask(
      {required this.organizationId, required this.taskId});
}
