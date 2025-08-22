import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/customer_detail_model.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/order_detail_responese.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';

import 'model/deal_activity_response.dart';

enum DealActivityStatus {
  initial,
  loading,
  success,
  successUpdateStatus,
  error,
  errorChangeStage,
  errorDuplicateOrder,
  successCreateReminder,
  successUpdateNoteMark,
  successUpdateCustomer,
  successEditOrder,
}

class DealActivityState extends Equatable {
  final TaskModel? task;
  final String? workspaceId;

  final DealActivityStatus status;
  final List<BusinessProcessModel> businessProcesses;
  final List<DealActivityModel> dealActivityModels;
  final BusinessProcessModel? selectedBusinessProcess;
  final String? organizationId;
  final List<ServiceDetailModel> noteSimpleModels;
  final List<ScheduleModel> scheduleModels;
  final CustomerOrderDataModel? customerOrderDataModel;
  final String? error;
  final String? errorTitle;
  final CustomerDetailModel? customerDataModel;

  /// Constructor không const để xử lý runtime logic cho error/errorTitle.
  DealActivityState({
    this.status = DealActivityStatus.initial,
    this.businessProcesses = const [],
    this.dealActivityModels = const [],
    this.selectedBusinessProcess,
    String? error,
    String? errorTitle,
    this.organizationId,
    this.noteSimpleModels = const [],
    this.scheduleModels = const [],
    this.task,
    this.workspaceId,
    this.customerOrderDataModel,
    this.customerDataModel,
  })  : error = _normalizeError(status, error),
        errorTitle = _normalizeErrorTitle(status, errorTitle);

  /// State mặc định
  factory DealActivityState.initial() => DealActivityState();

  DealActivityState copyWith({
    DealActivityStatus? status,
    List<BusinessProcessModel>? businessProcesses,
    BusinessProcessModel? selectedBusinessProcess,
    List<DealActivityModel>? dealActivityModels,
    List<ServiceDetailModel>? noteSimpleModels,
    List<ScheduleModel>? scheduleModels,
    String? error,
    String? errorTitle,
    String? organizationId,
    TaskModel? task,
    String? workspaceId,
    CustomerOrderDataModel? customerOrderDataModel,
    CustomerDetailModel? customerDataModel,
    List<ProductModel>? products,
  }) {
    final nextStatus = status ?? this.status;
    final nextError = _normalizeError(nextStatus, error ?? this.error);
    final nextErrorTitle =
        _normalizeErrorTitle(nextStatus, errorTitle ?? this.errorTitle);

    return DealActivityState(
      status: nextStatus,
      businessProcesses: businessProcesses ?? this.businessProcesses,
      selectedBusinessProcess:
          selectedBusinessProcess ?? this.selectedBusinessProcess,
      dealActivityModels: dealActivityModels ?? this.dealActivityModels,
      noteSimpleModels: noteSimpleModels ?? this.noteSimpleModels,
      scheduleModels: scheduleModels ?? this.scheduleModels,
      error: nextError,
      errorTitle: nextErrorTitle,
      organizationId: organizationId ?? this.organizationId,
      task: task ?? this.task,
      workspaceId: workspaceId ?? this.workspaceId,
      customerOrderDataModel:
          customerOrderDataModel ?? this.customerOrderDataModel,
      customerDataModel: customerDataModel ?? this.customerDataModel,
    );
  }

  /// Chuẩn hoá error
  static String? _normalizeError(DealActivityStatus status, String? err) {
    if (status == DealActivityStatus.error) {
      return (err == null || err.isEmpty) ? 'Có lỗi xảy ra' : err;
    }
    return null;
  }

  /// Chuẩn hoá errorTitle
  static String? _normalizeErrorTitle(
      DealActivityStatus status, String? title) {
    if (status == DealActivityStatus.error) {
      return (title == null || title.isEmpty) ? 'Lỗi' : title;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        status,
        businessProcesses,
        selectedBusinessProcess,
        dealActivityModels,
        error,
        errorTitle,
        organizationId,
        noteSimpleModels,
        scheduleModels,
        task,
        workspaceId,
        customerOrderDataModel,
        customerDataModel,
      ];
}
