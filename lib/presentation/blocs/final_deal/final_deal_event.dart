import 'package:equatable/equatable.dart';

import 'model/workspace_response.dart';

abstract class FinalDealEvent extends Equatable {
  const FinalDealEvent();

  @override
  List<Object?> get props => [];
}

class FinalDealInitialized extends FinalDealEvent {
  const FinalDealInitialized();
}

class FinalDealGetAllWorkspace extends FinalDealEvent {
  final String organizationId;
  const FinalDealGetAllWorkspace({required this.organizationId});
}

class FinalDealSelectWorkspace extends FinalDealEvent {
  final WorkspaceModel workspace;
  final String organizationId;
  const FinalDealSelectWorkspace(
      {required this.workspace, required this.organizationId});
}

class FinalDealGetBusinessProcess extends FinalDealEvent {
  final String organizationId;
  final String workspaceId;
  const FinalDealGetBusinessProcess(
      {required this.organizationId, required this.workspaceId});
}

class FinalDealGetBusinessProcessTask extends FinalDealEvent {
  final String organizationId;
  final String workspaceId;
  final String processId;
  final String stageId;
  final String customerId;
  final String assignedTo;
  final String status;
  final bool includeHistory;
  final int page;
  final int pageSize;
  const FinalDealGetBusinessProcessTask(
      {required this.organizationId,
      required this.workspaceId,
      required this.processId,
      required this.stageId,
      required this.customerId,
      required this.assignedTo,
      required this.status, required this.includeHistory, required this.page, required this.pageSize});
}