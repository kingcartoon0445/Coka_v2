import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/deal_activity_repository.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_event.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_state.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/order_detail_responese.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

class DealActivityBloc extends Bloc<DealActivityEvent, DealActivityState> {
  final DealActivityRepository dealActivityRepository;

  final CalendarRepository calendarRepository;
  DealActivityBloc(
      {required this.dealActivityRepository, required this.calendarRepository})
      : super(DealActivityState()) {
    on<LoadDealActivity>(_onLoadDealActivity);
    on<LoadDetailTask>(_onLoadDetailTask);
    on<ChangeStage>(_onChangeStage);
    on<UpdateStatus>(_onUpdateStatus);
    on<RemoveState>(_onRemoveState);
    on<CreateReminderWorkspace>(_onCreateReminderWorkspace);
    on<UpdateReminderWorkspace>(_onUpdateReminderWorkspace);
    on<DeleteReminderWorkspace>(_onDeleteReminderWorkspace);
  }

  Future<void> _onLoadDealActivity(
      LoadDealActivity event, Emitter<DealActivityState> emit) async {
    emit(state.copyWith(
        organizationId: event.organizationId,
        status: DealActivityStatus.loading,
        businessProcesses: event.businessProcesses,
        task: event.task,
        selectedBusinessProcess: event.businessProcesses
            ?.firstWhere((element) => element.id == event.task?.stageId),
        workspaceId: event.workspaceId));
    // final response = await dealActivityRepository.getDealActivity(
    //     event.organizationId, event.stageId);
    // bool isSuccess = Helpers.isResponseSuccess(response.data);
    // if (isSuccess) {
    //   DealActivityResponse dealActivityResponse =
    //       DealActivityResponse.fromJson(response.data);
    //   emit(state.copyWith(
    //       status: DealActivityStatus.success,
    //       dealActivityModels: dealActivityResponse.data));
    // }

    final historyResponse = await dealActivityRepository.getHistory(
        event.organizationId, event.task?.id ?? state.task?.id ?? '');
    bool isSuccessHistory = Helpers.isResponseSuccess(historyResponse.data);
    if (isSuccessHistory) {
      ServiceDetailResponse noteSimpleResponse =
          ServiceDetailResponse.fromJson(historyResponse.data);
      emit(state.copyWith(
          status: DealActivityStatus.success,
          noteSimpleModels: noteSimpleResponse.content ?? []));
    }

    final activityResponse = await dealActivityRepository.getActivity(
        event.organizationId, event.workspaceId ?? state.workspaceId ?? '');
    bool isSuccessActivity = Helpers.isResponseSuccess(activityResponse.data);
    if (isSuccessActivity) {
      ScheduleResponse schedulesResponse =
          ScheduleResponse.fromJson(activityResponse.data);
      emit(state.copyWith(
          status: DealActivityStatus.success,
          scheduleModels: schedulesResponse.data ?? []));
    }
  }

  Future<void> _onLoadDetailTask(
      LoadDetailTask event, Emitter<DealActivityState> emit) async {
    final response = await dealActivityRepository.getDetailTask(
        event.organizationId, event.taskId);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      TaskResponse taskResponse = TaskResponse.fromJson(response.data);
      emit(state.copyWith(
          status: DealActivityStatus.success, task: taskResponse.data?.first));
    }
    final orderDetailResponse = await dealActivityRepository
        .getOrderDetailWithProduct(event.organizationId, event.orderId!);
    bool isSuccessOrderDetail =
        Helpers.isResponseSuccess(orderDetailResponse.data);
    if (isSuccessOrderDetail) {
      CustomerOrderApiResponse orderResponse =
          CustomerOrderApiResponse.fromJson(orderDetailResponse.data);
      emit(state.copyWith(customerOrderDataModel: orderResponse.data));
    }
  }

  Future<void> _onChangeStage(
      ChangeStage event, Emitter<DealActivityState> emit) async {
    try {
      final response = await dealActivityRepository.updateStageGiveTask(
          state.organizationId ?? '',
          state.task?.id ?? '',
          event.businessProcess?.id ?? '');
      bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        emit(state.copyWith(
            status: DealActivityStatus.success,
            selectedBusinessProcess: event.businessProcess));
      } else {
        emit(state.copyWith(
            status: DealActivityStatus.error, error: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: DealActivityStatus.error,
          errorTitle: 'Chức năng đổi trạng thái',
          error: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
      UpdateStatus event, Emitter<DealActivityState> emit) async {
    try {
      final response = await dealActivityRepository.updateStatus(
          state.organizationId ?? '', state.task?.id ?? '', event.isSuccess);
      bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        emit(state.copyWith(status: DealActivityStatus.successUpdateStatus));
      } else {
        emit(state.copyWith(
            status: DealActivityStatus.error, error: response.data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          status: DealActivityStatus.error,
          errorTitle: 'Chức năng cập nhật trạng thái',
          error: e.toString()));
    }
  }

  Future<void> _onRemoveState(
      RemoveState event, Emitter<DealActivityState> emit) async {
    emit(DealActivityState(status: DealActivityStatus.initial));
  }

  Future<void> _onCreateReminderWorkspace(
      CreateReminderWorkspace event, Emitter<DealActivityState> emit) async {
    final response = await calendarRepository.createReminder(
        state.organizationId ?? '', event.reminder);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      add(LoadDealActivity(
          organizationId: state.organizationId ?? '',
          workspaceId: state.workspaceId ?? ''));
      emit(state.copyWith(status: DealActivityStatus.successCreateReminder));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error, error: response.data['message']));
    }
  }

  Future<void> _onUpdateReminderWorkspace(
      UpdateReminderWorkspace event, Emitter<DealActivityState> emit) async {
    final response = await calendarRepository.updateReminder(
        state.organizationId ?? '', event.reminder);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      add(LoadDealActivity(
          organizationId: state.organizationId ?? '',
          workspaceId: state.workspaceId ?? ''));
      emit(state.copyWith(status: DealActivityStatus.successCreateReminder));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error, error: response.data['message']));
    }
  }

  Future<void> _onDeleteReminderWorkspace(
      DeleteReminderWorkspace event, Emitter<DealActivityState> emit) async {
    final response = await calendarRepository.deleteReminder(
        state.organizationId ?? '', event.reminderId);
    bool isSuccess = response.statusCode == 200;
    if (isSuccess) {
      add(LoadDealActivity(
          organizationId: state.organizationId ?? '',
          workspaceId: state.workspaceId ?? ''));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error, error: response.data['message']));
    }
  }
}
