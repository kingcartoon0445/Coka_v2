import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/deal_activity_repository.dart';
import 'package:source_base/data/repositories/model_switch/order_data.dart';
import 'package:source_base/data/repositories/switch_final_deal_repository.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_event.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_state.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/customer_detail_model.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/order_detail_responese.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

class DealActivityBloc extends Bloc<DealActivityEvent, DealActivityState> {
  final DealActivityRepository dealActivityRepository;
  final SwitchFinalDealRepository switchFinalDealRepository;
  final CalendarRepository calendarRepository;
  DealActivityBloc(
      {required this.dealActivityRepository,
      required this.calendarRepository,
      required this.switchFinalDealRepository})
      : super(DealActivityState()) {
    on<LoadDealActivity>(_onLoadDealActivity);
    on<LoadDetailTask>(_onLoadDetailTask);
    on<ChangeStage>(_onChangeStage);
    on<UpdateStatus>(_onUpdateStatus);
    on<RemoveState>(_onRemoveState);
    on<UpdateNoteMark>(_onUpdateNoteMark);
    on<CreateReminderWorkspace>(_onCreateReminderWorkspace);
    on<UpdateReminderWorkspace>(_onUpdateReminderWorkspace);
    on<DeleteReminderWorkspace>(_onDeleteReminderWorkspace);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<UpdateOrderList>(_onUpdateOrderList);
    on<EditOrder>(_onEditOrder);
    on<DuplicateOrder>(_onDuplicateOrder);
    on<ArchiveOrder>(_onArchiveOrder);
    on<DeleteOrder>(_onDeleteOrder);
    on<SendNote>(_onSendNote);
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
    TaskModel? task;
    if (isSuccess) {
      TaskResponse taskResponse = TaskResponse.fromJson(response.data);
      task = taskResponse.data?.first;
      emit(state.copyWith(status: DealActivityStatus.success, task: task));
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
    bool isCustomer = task?.customerId != null && task?.customerId != '';
    String id = isCustomer ? task?.customerId ?? '' : task?.leadId ?? '';
    final customerResponse = await dealActivityRepository
        .getCustomerDetail(event.organizationId, id, isCustomer: isCustomer);
    bool isSuccessCustomer = Helpers.isResponseSuccess(customerResponse.data);
    if (isSuccessCustomer) {
      LeadDetailResponse customerDetailResponse =
          LeadDetailResponse.fromJson(customerResponse.data);
      emit(state.copyWith(customerDataModel: customerDetailResponse.content));
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

  Future<void> _onUpdateNoteMark(
      UpdateNoteMark event, Emitter<DealActivityState> emit) async {
    final response = await calendarRepository.updateNoteMark(
        event.scheduleId, event.isDone, '');
    if (response.statusCode == 200) {
      emit(state.copyWith(status: DealActivityStatus.successUpdateNoteMark));
      add(LoadDealActivity(
          organizationId: state.organizationId ?? '',
          workspaceId: state.workspaceId ?? ''));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error, error: response.data['message']));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<DealActivityState> emit) async {
    final response = await dealActivityRepository.updateCustomer(
        event.organizationId, event.id, event.fieldName, event.value,
        isCustomer: event.isCustomer);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      event.completer?.complete(true);
      emit(state.copyWith(status: DealActivityStatus.successUpdateCustomer));
    } else {
      event.completer?.complete(false);
      emit(state.copyWith(
        status: DealActivityStatus.initial,
      ));
    }
  }

  void _onUpdateOrderList(
      UpdateOrderList event, Emitter<DealActivityState> emit) async {
    // final selectedProduct
    OrderData orderData = OrderData(
      id: state.customerOrderDataModel?.id ?? '',
      workspaceId: state.workspaceId ?? '',
      customerId: state.customerDataModel?.id ?? '',
      actor: state.task?.assignedTo.first.id ?? '',
      totalPrice:
          event.products.fold(0.0, (sum, product) => sum + product.total),
      orderDetails: event.products
          .map((e) => OrderDetailData(
                productId: e.product.id,
                quantity: e.quantity,
                unitPrice: e.product.price,
              ))
          .toList(),
    );

    final responseOrder = await switchFinalDealRepository.postOrder(
        event.organizationId, orderData);
    final bool isSuccessOrder = Helpers.isResponseSuccess(responseOrder.data);
    if (isSuccessOrder) {
      add(LoadDetailTask(
          organizationId: event.organizationId,
          taskId: state.task?.id ?? '',
          orderId: responseOrder.data['data']['orderId']));
    }
  }

  void _onEditOrder(EditOrder event, Emitter<DealActivityState> emit) async {
    if (event.type == EditOrderType.duplicate) {
      add(DuplicateOrder(
          organizationId: event.organizationId, taskId: event.taskId));
    } else if (event.type == EditOrderType.archive) {
      add(ArchiveOrder(
          organizationId: event.organizationId, taskId: event.taskId));
    } else {
      add(DeleteOrder(
          organizationId: event.organizationId, taskId: event.taskId));
    }
  }

  void _onDuplicateOrder(
      DuplicateOrder event, Emitter<DealActivityState> emit) async {
    final response = await dealActivityRepository.duplicateOrder(
        event.organizationId, event.taskId);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      emit(state.copyWith(status: DealActivityStatus.successEditOrder));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error,
          error: response.data['message'],
          errorTitle: 'Chức năng lưu đơn hàng'));
    }
  }

  void _onArchiveOrder(
      ArchiveOrder event, Emitter<DealActivityState> emit) async {
    final response = await dealActivityRepository.archiveOrder(
        event.organizationId, event.taskId);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      emit(state.copyWith(status: DealActivityStatus.successEditOrder));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error,
          error: response.data['message'],
          errorTitle: 'Chức năng lưu đơn hàng'));
    }
  }

  void _onDeleteOrder(
      DeleteOrder event, Emitter<DealActivityState> emit) async {
    final response = await dealActivityRepository.deleteOrder(
        event.organizationId, event.taskId);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      emit(state.copyWith(status: DealActivityStatus.successEditOrder));
    } else {
      emit(state.copyWith(
          status: DealActivityStatus.error,
          error: response.data['message'],
          errorTitle: 'Chức năng lưu đơn hàng'));
    }
  }

  Future<void> _onSendNote(
      SendNote event, Emitter<DealActivityState> emit) async {
    final response = await dealActivityRepository.SendNoteJourneysService(
        event.organizationId, event.taskId, event.note);
    bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      add(LoadDealActivity(
          organizationId: event.organizationId,
          workspaceId: state.workspaceId ?? ''));
    }
  }
}
