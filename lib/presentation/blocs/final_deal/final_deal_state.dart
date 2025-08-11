import 'package:equatable/equatable.dart';

import 'model/business_process_response.dart';
import 'model/business_process_task_response.dart';
import 'model/workspace_response.dart';

enum FinalDealStatus {
  initial,
  loading,
  loadingBusinessProcess,
  successBusinessProcessTask,
  success,
  error
}

class FinalDealState extends Equatable {
  final FinalDealStatus status;
  final List<WorkspaceModel> workspaces;
  final WorkspaceModel? selectedWorkspace;
  final List<BusinessProcessModel> businessProcesses;
  final List<BusinessProcessTaskModel> businessProcessTasks;
  final BusinessProcessModel? selectedBusinessProcess;
  final String? error;
  const FinalDealState({
    this.status = FinalDealStatus.initial,
    this.workspaces = const [],
    this.selectedWorkspace,
    this.businessProcesses = const [],
    this.businessProcessTasks = const [],
    this.selectedBusinessProcess,
    this.error,
  });

  FinalDealState copyWith({
    bool? isDelete,
    FinalDealStatus? status,
    List<WorkspaceModel>? workspaces,
    WorkspaceModel? selectedWorkspace,
    List<BusinessProcessModel>? businessProcesses,
    List<BusinessProcessTaskModel>? businessProcessTasks,
    BusinessProcessModel? selectedBusinessProcess,
    String? error,
  }) {
    return FinalDealState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspace: selectedWorkspace ?? this.selectedWorkspace,
      businessProcesses: businessProcesses ?? this.businessProcesses,
      businessProcessTasks: isDelete == true
          ? []
          : businessProcessTasks ?? this.businessProcessTasks,
      selectedBusinessProcess: isDelete == true
          ? null
          : selectedBusinessProcess ?? this.selectedBusinessProcess,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        workspaces,
        selectedWorkspace,
        businessProcesses,
        businessProcessTasks,
        selectedBusinessProcess,
        error,
      ];
}
