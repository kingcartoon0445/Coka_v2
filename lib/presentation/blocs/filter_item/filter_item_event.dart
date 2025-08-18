import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class FilterItemEvent extends Equatable {
  const FilterItemEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái xác thực
class CheckFilterItemStatus extends FilterItemEvent {}

class LoadFilterItems extends FilterItemEvent {
  final String limit;
  final String offset;
  final String searchText;

  const LoadFilterItems({
    required this.limit,
    required this.offset,
    required this.searchText,
  });
}

// class LoadUserInfo extends FilterItemEvent {
//   final String organizationId;

//   const LoadUserInfo({required this.organizationId});
// }

class LoadFilterItem extends FilterItemEvent {
  final String organizationId;

  const LoadFilterItem({required this.organizationId});
}

class CreateLead extends FilterItemEvent {
  final String organizationId;
  final Map<String, dynamic> data;

  const CreateLead({required this.organizationId, required this.data});
}