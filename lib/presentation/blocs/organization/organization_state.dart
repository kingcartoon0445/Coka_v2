// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/user_profile.dart';

enum OrganizationStatus {
  initial,
  loading,
  loadOrganizationsSuccess,
  loadUserInfoSuccess,
  loadCustomerServiceSuccess,
  postCustomerNoteSuccess,
  success,
  error
}

class OrganizationState extends Equatable {
  final OrganizationStatus status;
  final List<OrganizationModel> organizations;
  final List<CustomerServiceModel?> customerServices;
  final UserProfile? user;
  final String? email;
  final String? otpId;
  final String? error;
  final String? organizationId;

  const OrganizationState({
    this.status = OrganizationStatus.initial,
    this.customerServices = const [],
    this.user,
    this.email,
    this.organizations = const [],
    this.otpId,
    this.error,
    this.organizationId,
  });

  OrganizationState copyWith({
    OrganizationStatus? status,
    List<OrganizationModel>? organizations,
    List<CustomerServiceModel>? customerServices,
    UserProfile? user,
    String? email,
    String? otpId,
    String? error,
    String? organizationId,
  }) {
    return OrganizationState(
      status: status ?? this.status,
      organizations: organizations ?? this.organizations,
      customerServices: customerServices ?? this.customerServices,
      user: user ?? this.user,
      email: email ?? this.email,
      otpId: otpId ?? this.otpId,
      error: error ?? this.error,
      organizationId: organizationId ?? this.organizationId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        organizations,
        user,
        otpId,
        error,
        organizationId,
        customerServices
      ];
}
