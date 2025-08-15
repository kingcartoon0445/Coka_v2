// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';

enum CustomerServiceStatus {
  initial,
  loading,
  loadingUserInfo,
  errorCreateReminder,
  errorUpdateReminder,
  errorDeleteReminder,
  error,
  loadingMore,
  success,
  successStorageCustomer,
  successDeleteReminder,
}

class CustomerServiceState extends Equatable {
  final CustomerServiceStatus status;
  final List<CustomerServiceModel> customerServices;
  final CustomerServiceModel? customerService;
  final List<ServiceDetailModel> serviceDetails;
  final List<ScheduleModel> scheduleDetails;
  final CustomerServiceModel? facebookChat;
  final String? error;
  final Metadata? serviceDetailsMetadata;
  final bool hasMoreServiceDetails;
  final Metadata? customersMetadata;
  final bool hasMoreCustomers;
  final Metadata? facebookChatsMetadata;
  final bool hasMoreFacebookChats;
  final LeadPagingRequest? pagingRequest;
  const CustomerServiceState({
    this.status = CustomerServiceStatus.loading,
    this.customerServices = const [],
    this.customerService,
    this.serviceDetails = const [],
    this.scheduleDetails = const [],
    this.facebookChat,
    this.error,
    this.serviceDetailsMetadata,
    this.hasMoreServiceDetails = false,
    this.customersMetadata,
    this.hasMoreCustomers = false,
    this.facebookChatsMetadata,
    this.hasMoreFacebookChats = false,
    this.pagingRequest,
  });

  CustomerServiceState copyWith({
    CustomerServiceStatus? status,
    List<CustomerServiceModel>? customerServices,
    CustomerServiceModel? customerService,
    List<ServiceDetailModel>? serviceDetails,
    List<ScheduleModel>? scheduleDetails,
    CustomerServiceModel? facebookChat,
    String? error,
    String? organizationId,
    Metadata? serviceDetailsMetadata,
    bool? hasMoreServiceDetails,
    Metadata? customersMetadata,
    bool? hasMoreCustomers,
    Metadata? facebookChatsMetadata,
    bool? hasMoreFacebookChats,
    LeadPagingRequest? pagingRequest,
  }) {
    return CustomerServiceState(
      status: status ?? this.status,
      customerServices: customerServices != null
          ? List<CustomerServiceModel>.unmodifiable(customerServices)
          : this.customerServices,
      customerService: customerService ?? this.customerService,
      serviceDetails: serviceDetails != null
          ? List<ServiceDetailModel>.unmodifiable(serviceDetails)
          : this.serviceDetails,
      scheduleDetails: scheduleDetails != null
          ? List<ScheduleModel>.unmodifiable(scheduleDetails)
          : this.scheduleDetails,
      facebookChat: facebookChat ?? this.facebookChat,
      error: error ?? this.error,
      serviceDetailsMetadata:
          serviceDetailsMetadata ?? this.serviceDetailsMetadata,
      hasMoreServiceDetails:
          hasMoreServiceDetails ?? this.hasMoreServiceDetails,
      customersMetadata: customersMetadata ?? this.customersMetadata,
      hasMoreCustomers: hasMoreCustomers ?? this.hasMoreCustomers,
      hasMoreFacebookChats: hasMoreFacebookChats ?? this.hasMoreFacebookChats,
      facebookChatsMetadata:
          facebookChatsMetadata ?? this.facebookChatsMetadata,
      pagingRequest: pagingRequest ?? this.pagingRequest,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        customerServices,
        customerService,
        serviceDetails,
        scheduleDetails,
        facebookChat,
        serviceDetailsMetadata,
        hasMoreServiceDetails,
        customersMetadata,
        hasMoreCustomers,
        facebookChatsMetadata,
        hasMoreFacebookChats,
        pagingRequest,
      ];
}
