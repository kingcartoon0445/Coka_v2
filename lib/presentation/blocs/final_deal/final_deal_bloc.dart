import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/repositories/final_deal_repository.dart';
import 'final_deal_action.dart';
import 'model/business_process_response.dart';
import 'model/business_process_task_response.dart';
import 'model/workspace_response.dart';

class FinalDealBloc extends Bloc<FinalDealEvent, FinalDealState> {
  final FinalDealRepository repository;

  FinalDealBloc({required this.repository}) : super(const FinalDealState()) {
    on<FinalDealInitialized>(_onInitialized);
    on<FinalDealGetAllWorkspace>(_onGetAllWorkspace);
    on<FinalDealSelectWorkspace>(_onSelectWorkspace);
    on<FinalDealGetBusinessProcess>(_onGetBusinessProcess);
    on<FinalDealGetBusinessProcessTask>(_onGetBusinessProcessTask);
    on<FinalDealSelectBusinessProcess>(_onSelectBusinessProcess);
  }

  void _onInitialized(
      FinalDealInitialized event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.initial));
  }

  void _onGetAllWorkspace(
      FinalDealGetAllWorkspace event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.loadingBusinessProcess));
    final response = await repository.getAllWorkspace(event.organizationId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      WorkspaceResponse workspaceResponse =
          WorkspaceResponse.fromJson(response.data);
      final workspace = workspaceResponse.content?.first;
      if (workspace != null) {
        add(FinalDealSelectWorkspace(
          organizationId: event.organizationId,
          workspace: workspace,
        ));
      }
      emit(state.copyWith(
          // status: FinalDealStatus.success,
          workspaces: workspaceResponse.content ?? [],
          selectedWorkspace: workspace));
    } else {
      emit(state.copyWith(status: FinalDealStatus.error));
    }
  }

  void _onSelectWorkspace(
      FinalDealSelectWorkspace event, Emitter<FinalDealState> emit) async {
    add(FinalDealGetBusinessProcess(
      organizationId: event.organizationId,
      workspaceId: event.workspace.id ?? '',
    ));
    emit(state.copyWith(selectedWorkspace: event.workspace));
  }

  void _onGetBusinessProcess(
      FinalDealGetBusinessProcess event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.loadingBusinessProcess));
    final response = await repository.getBusinessProcess(
        event.organizationId, event.workspaceId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      BusinessProcessResponse businessProcessResponse =
          BusinessProcessResponse.fromJson(response.data);

      if (businessProcessResponse.data?.isNotEmpty ?? false) {
        add(FinalDealGetBusinessProcessTask(
          organizationId: event.organizationId,
          processId: '',
          stage: businessProcessResponse.data?.first,
          customerId: '',
          assignedTo: '',
          status: '',
          includeHistory: false,
          page: 1,
          pageSize: 10,
        ));
        emit(state.copyWith(
            status: FinalDealStatus.successBusinessProcessTask,
            businessProcesses: businessProcessResponse.data ?? []));
      } else {
        emit(state.copyWith(
            status: FinalDealStatus.successBusinessProcessTask,
            businessProcesses: []));
      }
    } else {
      emit(state.copyWith(status: FinalDealStatus.error));
    }
  }

  void _onGetBusinessProcessTask(FinalDealGetBusinessProcessTask event,
      Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.loading));
    final response = await repository.getBusinessProcessTask(
        event.organizationId,
        event.processId ?? '',
        event.stage?.id ?? '',
        event.customerId ?? '',
        event.assignedTo ?? '',
        event.status ?? '',
        event.includeHistory,
        event.page,
        event.pageSize);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      BusinessProcessTaskResponse businessProcessTaskResponse =
          BusinessProcessTaskResponse.fromJson(response.data);
      emit(state.copyWith(isDelete: true));
      emit(state.copyWith(
          status: FinalDealStatus.success,
          selectedBusinessProcess: event.stage,
          businessProcessTasks: businessProcessTaskResponse.data ?? []));
    } else {
      emit(state.copyWith(status: FinalDealStatus.error));
    }
  }

  void _onSelectBusinessProcess(FinalDealSelectBusinessProcess event,
      Emitter<FinalDealState> emit) async {
    emit(state.copyWith(selectedBusinessProcess: event.businessProcess));

    add(FinalDealGetBusinessProcessTask(
      organizationId: event.organizationId,
      processId: '',
      stage: event.businessProcess,
      customerId: '',
      assignedTo: '',
      status: '',
      includeHistory: false,
      page: 1,
      pageSize: 10,
    ));
  }
}
