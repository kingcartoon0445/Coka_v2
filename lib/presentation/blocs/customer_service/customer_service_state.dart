// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/facebook_chat_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';

enum CustomerServiceStatus {
  initial,
  loading,
  loadingUserInfo,
  success,
  successStorageCustomer,
  error,
  loadingMore
}

class CustomerServiceState extends Equatable {
  final CustomerServiceStatus status;
  final List<CustomerServiceModel> customerServices;
  final CustomerServiceModel? customerService;
  final List<ServiceDetailModel> serviceDetails;
  final List<ScheduleModel> scheduleDetails;
  final List<FacebookChatModel> facebookChats;
  final FacebookChatModel? facebookChat;
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
    this.facebookChats = const [],
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
    List<FacebookChatModel>? facebookChats,
    FacebookChatModel? facebookChat,
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
      customerServices: customerServices ?? this.customerServices,
      customerService: customerService ?? this.customerService,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      scheduleDetails: scheduleDetails ?? this.scheduleDetails,
      facebookChats: facebookChats ?? this.facebookChats,
      facebookChat: facebookChat ?? this.facebookChat,
      error: error ?? this.error,
      serviceDetailsMetadata:
          serviceDetailsMetadata ?? this.serviceDetailsMetadata,
      hasMoreServiceDetails:
          hasMoreServiceDetails ?? this.hasMoreServiceDetails,
      customersMetadata: customersMetadata ?? this.customersMetadata,
      hasMoreCustomers: hasMoreCustomers ?? this.hasMoreCustomers,
      facebookChatsMetadata:
          facebookChatsMetadata ?? this.facebookChatsMetadata,
      hasMoreFacebookChats: hasMoreFacebookChats ?? this.hasMoreFacebookChats,
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
        facebookChats,
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
