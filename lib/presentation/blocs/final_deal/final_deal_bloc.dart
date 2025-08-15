import 'package:source_base/config/helper.dart';
import 'package:source_base/data/repositories/final_deal_repository.dart';
import 'final_deal_action.dart';
import 'model/business_process_response.dart';
import 'model/business_process_task_response.dart';
import 'model/workspace_response.dart';

class FinalDealBloc extends Bloc<FinalDealEvent, FinalDealState> {
  final FinalDealRepository repository;

  FinalDealBloc({required this.repository}) : super(const FinalDealState()) {
    on<Initialized>(_onInitialized);
    on<GetAllWorkspace>(_onGetAllWorkspace);
    on<SelectWorkspace>(_onSelectWorkspace);
    on<GetBusinessProcess>(_onGetBusinessProcess);
    on<GetBusinessProcessTask>(_onGetBusinessProcessTask);
    on<SelectBusinessProcess>(_onSelectBusinessProcess);
    on<GetDetailTask>(_onGetDetailTask);
  }

  void _onInitialized(Initialized event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.initial));
  }

  void _onGetAllWorkspace(
      GetAllWorkspace event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.loadingBusinessProcess));
    final response = await repository.getAllWorkspace(event.organizationId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      WorkspaceResponse workspaceResponse =
          WorkspaceResponse.fromJson(response.data);
      final workspace = workspaceResponse.content?.first;
      if (workspace != null) {
        add(SelectWorkspace(
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
      SelectWorkspace event, Emitter<FinalDealState> emit) async {
    add(GetBusinessProcess(
      organizationId: event.organizationId,
      workspaceId: event.workspace.id ?? '',
    ));
    emit(state.copyWith(selectedWorkspace: event.workspace));
  }

  void _onGetBusinessProcess(
      GetBusinessProcess event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.loadingBusinessProcess));
    final response = await repository.getBusinessProcess(
        event.organizationId, event.workspaceId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      BusinessProcessResponse businessProcessResponse =
          BusinessProcessResponse.fromJson(response.data);

      if (businessProcessResponse.data?.isNotEmpty ?? false) {
        add(GetBusinessProcessTask(
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

  void _onGetBusinessProcessTask(
      GetBusinessProcessTask event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(status: FinalDealStatus.loadingListTask));
    final response = await repository.getBusinessProcessTask(
        event.organizationId,
        event.processId ?? '',
        event.stage?.id ?? '',
        event.customerId ?? '',
        event.assignedTo ?? '',
        event.status ?? '',
        event.includeHistory,
        event.page,
        event.pageSize,
        taskId: null);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      TaskResponse businessProcessTaskResponse =
          TaskResponse.fromJson(response.data);
      emit(state.copyWith(isDelete: true));
      emit(state.copyWith(
          status: FinalDealStatus.success,
          selectedBusinessProcess: event.stage,
          taskes: businessProcessTaskResponse.data ?? []));
    } else {
      emit(state.copyWith(status: FinalDealStatus.error));
    }
  }

  void _onSelectBusinessProcess(
      SelectBusinessProcess event, Emitter<FinalDealState> emit) async {
    emit(state.copyWith(
        selectedBusinessProcess: event.businessProcess,
        status: FinalDealStatus.loadingListTask));
    Future.delayed(const Duration(seconds: 2), () {
      add(GetBusinessProcessTask(
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
    });
  }

  void _onGetDetailTask(
      GetDetailTask event, Emitter<FinalDealState> emit) async {
    // emit(state.copyWith(status: FinalDealStatus.loading));
    // final response = await repository.getBusinessProcessTask(
    //     event.organizationId, '', '', '', '', '', false, 1, 10,
    //     taskId: event.taskId);
    // final bool isSuccess = Helpers.isResponseSuccess(response.data);
    // if (isSuccess) {
    //   emit(state.copyWith(

    //       status: FinalDealStatus.success, detailTask: response.data));
    // } else {
    //   emit(state.copyWith(status: FinalDealStatus.error));
    // }
  }
}
