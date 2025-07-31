import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';

abstract class OrganizationEvent extends Equatable {
  const OrganizationEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái xác thực
class CheckOrganizationStatus extends OrganizationEvent {}

class LoadOrganizations extends OrganizationEvent {
  final String limit;
  final String offset;
  final String searchText;

  const LoadOrganizations({
    required this.limit,
    required this.offset,
    required this.searchText,
  });
}

class LoadUserInfo extends OrganizationEvent {
  final String organizationId;

  const LoadUserInfo({required this.organizationId});
}

// class LoadCustomerService extends OrganizationEvent {
//   final String organizationId;
//   final LeadPagingRequest pagingRequest;
//   const LoadCustomerService({
//     required this.organizationId,
//     required this.pagingRequest,
//   });
// }

class ChangeOrganization extends OrganizationEvent {
  final String organizationId;

  const ChangeOrganization({required this.organizationId});
}
