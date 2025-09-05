import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/presentation/blocs/customer_detail/model/customer_detail_response.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/customer_detail_model.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';

enum CustomerDetailStatus {
  initial,
  loading,
  loadingUserInfo,
  error,
  success,
  loadingMore,
  errorCreateReminder,
  errorUpdateReminder,
  errorDeleteReminder,
  errorGetCustomerDetail,
  errorLinkToLead,
  successLinkToLead,
  successGetCustomerDetail,
  successStorageCustomer,
  successDeleteReminder,
  successLoadPaginges,
}

enum CustomersStatus { idle, loading, success, error }

class CustomerDetailState extends Equatable {
  final CustomerDetailStatus status;
  final CustomerServiceModel? customerService;
  final List<ServiceDetailModel> serviceDetails;
  final List<ScheduleModel> scheduleDetails;
  final List<CustomerPaging> customerPaginges;
  final LeadDetailModel? leadDetail;
  final CustomerDetailModel? customerDetailModel;
  final String? organizationId;
  final String? leadId;
  final String? error;
  final Metadata? serviceDetailsMetadata;
  final bool hasMoreServiceDetails;
  final List<PagingModel> initLabels;
  final List<PagingModel> paginges;
  final bool isChat;
  final bool isDelete;
  final List<CustomerServiceModel> customerServices;
  final CustomersStatus customersStatus;

  const CustomerDetailState({
    this.status = CustomerDetailStatus.initial,
    this.customerService,
    this.serviceDetails = const [],
    this.scheduleDetails = const [],
    this.customerPaginges = const [],
    this.leadDetail,
    this.customerDetailModel,
    this.organizationId,
    this.leadId,
    this.error,
    this.serviceDetailsMetadata,
    this.hasMoreServiceDetails = false,
    this.initLabels = const [],
    this.paginges = const [],
    this.isChat = false,
    this.isDelete = false,
    this.customerServices = const [],
    this.customersStatus = CustomersStatus.idle,
  });

  /// Factory khởi tạo mặc định (dùng cho Reset state)
  factory CustomerDetailState.initial() => const CustomerDetailState();

  CustomerDetailState copyWith({
    CustomerDetailStatus? status,
    CustomerServiceModel? customerService,
    List<ServiceDetailModel>? serviceDetails,
    List<ScheduleModel>? scheduleDetails,
    List<CustomerPaging>? customerPaginges,
    LeadDetailModel? leadDetail,
    CustomerDetailModel? customerDetailModel,
    String? organizationId,
    String? leadId,
    String? error,
    Metadata? serviceDetailsMetadata,
    bool? hasMoreServiceDetails,
    List<PagingModel>? initLabels,
    List<PagingModel>? paginges,
    bool? isChat,
    bool? isDelete,
    List<CustomerServiceModel>? customerServices,
    CustomersStatus? customersStatus,
  }) {
    return CustomerDetailState(
      status: status ?? this.status,
      customerService: customerService ?? this.customerService,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      scheduleDetails: scheduleDetails ?? this.scheduleDetails,
      customerPaginges: customerPaginges ?? this.customerPaginges,
      leadDetail: leadDetail ?? this.leadDetail,
      customerDetailModel: customerDetailModel ?? this.customerDetailModel,
      organizationId: organizationId ?? this.organizationId,
      leadId: leadId ?? this.leadId,
      error: error ?? this.error,
      serviceDetailsMetadata:
          serviceDetailsMetadata ?? this.serviceDetailsMetadata,
      hasMoreServiceDetails:
          hasMoreServiceDetails ?? this.hasMoreServiceDetails,
      initLabels: initLabels ?? this.initLabels,
      paginges: paginges ?? this.paginges,
      isChat: isChat ?? this.isChat,
      isDelete: isDelete ?? this.isDelete,
      customerServices: customerServices ?? this.customerServices,
      customersStatus: customersStatus ?? this.customersStatus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customerService,
        serviceDetails,
        scheduleDetails,
        customerPaginges,
        leadDetail,
        customerDetailModel,
        organizationId,
        leadId,
        error,
        serviceDetailsMetadata,
        hasMoreServiceDetails,
        initLabels,
        paginges,
        isChat,
        isDelete,
        customerServices,
        customersStatus,
      ];
}
