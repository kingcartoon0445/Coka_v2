// lib/state/login/login_state.dart

import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/data/models/utm_member_response.dart';

enum FilterItemStatus { initial, loading, success, error }

class FilterItemState extends Equatable {
  final FilterItemStatus status;
  final List<PagingModel> paginges;
  final List<MemberModel> members;
  final List<UtmSourceModel> utmSources;
  // final List<FilterItemModel> customerServices;
  final String? error;
  final String? organizationId;

  const FilterItemState({
    this.status = FilterItemStatus.initial,
    this.paginges = const [],
    this.members = const [],
    this.utmSources = const [],
    // this.customerServices = const [],
    this.error,
    this.organizationId,
  });

  FilterItemState copyWith({
    FilterItemStatus? status,
    List<PagingModel>? paginges,
    List<MemberModel>? members,
    List<UtmSourceModel>? utmSources,
    // List<FilterItemModel>? customerServices,
    String? error,
    String? organizationId,
  }) {
    return FilterItemState(
      status: status ?? this.status,
      paginges: paginges ?? this.paginges,
      members: members ?? this.members,
      utmSources: utmSources ?? this.utmSources,
      // customerServices: customerServices ?? this.customerServices,
      error: error ?? this.error,
      organizationId: organizationId ?? this.organizationId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        organizationId,
        paginges,
        members,
        utmSources,
      ];
}
