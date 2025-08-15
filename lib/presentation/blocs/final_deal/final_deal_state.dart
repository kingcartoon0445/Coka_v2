import 'package:equatable/equatable.dart';

import 'model/business_process_response.dart';
import 'model/business_process_task_response.dart';
import 'model/workspace_response.dart';

enum FinalDealStatus {
  initial,
  loading,
  loadingListTask,
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
  final List<TaskModel> taskes;
  final BusinessProcessModel? selectedBusinessProcess;
  final TaskModel? taskModel;
  final String? error;
  const FinalDealState({
    this.status = FinalDealStatus.initial,
    this.workspaces = const [],
    this.selectedWorkspace,
    this.businessProcesses = const [],
    this.taskes = const [],
    this.selectedBusinessProcess,
    this.taskModel,
    this.error,
  });

  FinalDealState copyWith({
    bool? isDelete,
    FinalDealStatus? status,
    List<WorkspaceModel>? workspaces,
    WorkspaceModel? selectedWorkspace,
    List<BusinessProcessModel>? businessProcesses,
    List<TaskModel>? taskes,
    BusinessProcessModel? selectedBusinessProcess,
    TaskModel? taskModel,
    String? error,
  }) {
    return FinalDealState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspace: selectedWorkspace ?? this.selectedWorkspace,
      businessProcesses: businessProcesses ?? this.businessProcesses,
      taskes: isDelete == true ? [] : taskes ?? this.taskes,
      selectedBusinessProcess: isDelete == true
          ? null
          : selectedBusinessProcess ?? this.selectedBusinessProcess,
      taskModel: taskModel ?? this.taskModel,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        workspaces,
        selectedWorkspace,
        businessProcesses,
        taskes,
        selectedBusinessProcess,
        taskModel,
        error,
      ];
}
