import 'package:equatable/equatable.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

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
  final String? processId;
  final BusinessProcessModel? stage;
  final String? customerId;
  final String? assignedTo;
  final String? status;
  final bool includeHistory;
  final int page;
  final int pageSize;
  const FinalDealGetBusinessProcessTask(
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

class FinalDealSelectBusinessProcess extends FinalDealEvent {
  final BusinessProcessModel businessProcess;
  final String organizationId;
  const FinalDealSelectBusinessProcess(
      {required this.businessProcess, required this.organizationId});
}
