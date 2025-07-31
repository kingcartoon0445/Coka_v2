// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart'
    as service_detail;

enum CustomerServiceStatus {
  initial,
  loading,
  success,
  error,
  postCustomerNoteSuccess,
  loadingMore
}

class CustomerServiceState extends Equatable {
  final CustomerServiceStatus status;
  final List<CustomerServiceModel> customerServices;
  final CustomerServiceModel? customerService;
  final List<service_detail.ServiceDetailModel> serviceDetails;
  final List<ScheduleModel> scheduleDetails;
  final String? error;
  final String? organizationId;
  final service_detail.Metadata? serviceDetailsMetadata;
  final bool hasMoreServiceDetails;
  final Metadata? customersMetadata;
  final bool hasMoreCustomers;

  const CustomerServiceState({
    this.status = CustomerServiceStatus.initial,
    this.customerServices = const [],
    this.customerService,
    this.serviceDetails = const [],
    this.scheduleDetails = const [],
    this.error,
    this.organizationId,
    this.serviceDetailsMetadata,
    this.hasMoreServiceDetails = false,
    this.customersMetadata,
    this.hasMoreCustomers = false,
  });

  CustomerServiceState copyWith({
    CustomerServiceStatus? status,
    List<CustomerServiceModel>? customerServices,
    CustomerServiceModel? customerService,
    List<service_detail.ServiceDetailModel>? serviceDetails,
    List<ScheduleModel>? scheduleDetails,
    String? error,
    String? organizationId,
    service_detail.Metadata? serviceDetailsMetadata,
    bool? hasMoreServiceDetails,
    Metadata? customersMetadata,
    bool? hasMoreCustomers,
  }) {
    return CustomerServiceState(
      status: status ?? this.status,
      customerServices: customerServices ?? this.customerServices,
      customerService: customerService ?? this.customerService,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      scheduleDetails: scheduleDetails ?? this.scheduleDetails,
      error: error ?? this.error,
      organizationId: organizationId ?? this.organizationId,
      serviceDetailsMetadata:
          serviceDetailsMetadata ?? this.serviceDetailsMetadata,
      hasMoreServiceDetails:
          hasMoreServiceDetails ?? this.hasMoreServiceDetails,
      customersMetadata: customersMetadata ?? this.customersMetadata,
      hasMoreCustomers: hasMoreCustomers ?? this.hasMoreCustomers,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        organizationId,
        customerServices,
        customerService,
        serviceDetails,
        scheduleDetails,
        serviceDetailsMetadata,
        hasMoreServiceDetails,
        customersMetadata,
        hasMoreCustomers,
      ];
}
