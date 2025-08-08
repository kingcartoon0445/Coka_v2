import 'package:equatable/equatable.dart';

import 'model/business_process_response.dart';
import 'model/business_process_task_response.dart';
import 'model/workspace_response.dart';

enum FinalDealStatus { initial, loading, success, error }

class FinalDealState extends Equatable {
  final FinalDealStatus status;
  final List<WorkspaceModel> workspaces;
  final WorkspaceModel? selectedWorkspace;
  final List<BusinessProcessModel> businessProcesses;
  final List<BusinessProcessTaskModel> businessProcessTasks;
  final String? error;
  const FinalDealState({
    this.status = FinalDealStatus.initial,
    this.workspaces = const [],
    this.selectedWorkspace,
    this.businessProcesses = const [],
    this.businessProcessTasks = const [],
    this.error,
  });

  FinalDealState copyWith({
    FinalDealStatus? status,
    List<WorkspaceModel>? workspaces,
    WorkspaceModel? selectedWorkspace,
    List<BusinessProcessModel>? businessProcesses,
    List<BusinessProcessTaskModel>? businessProcessTasks,
    String? error,
  }) {
    return FinalDealState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspace: selectedWorkspace ?? this.selectedWorkspace,
      businessProcesses: businessProcesses ?? this.businessProcesses,
      error: error ?? this.error,
      businessProcessTasks: businessProcessTasks ?? this.businessProcessTasks,
    );
  }

  @override
  List<Object?> get props => [
        status,
        workspaces,
        selectedWorkspace,
        businessProcesses,
        businessProcessTasks,
        error,
      ];
}
