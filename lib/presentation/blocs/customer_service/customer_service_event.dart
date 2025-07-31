import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/reminder_service_body.dart';

abstract class CustomerServiceEvent extends Equatable {
  const CustomerServiceEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái xác thực
class CheckCustomerServiceStatus extends CustomerServiceEvent {}

class LoadCustomerServices extends CustomerServiceEvent {
  final String limit;
  final String offset;
  final String searchText;

  const LoadCustomerServices({
    required this.limit,
    required this.offset,
    required this.searchText,
  });
}

class LoadCustomerService extends CustomerServiceEvent {
  final String organizationId;
  final LeadPagingRequest pagingRequest;
  const LoadCustomerService({
    required this.organizationId,
    required this.pagingRequest,
  });
}

class LoadJourneyPaging extends CustomerServiceEvent {
  final CustomerServiceModel? customerService;
  final String organizationId;
  const LoadJourneyPaging({
    this.customerService,
    required this.organizationId,
  });
}

class PostCustomerNote extends CustomerServiceEvent {
  final String customerId;
  final String customerName;
  final String note;
  final String organizationId;

  const PostCustomerNote({
    required this.customerId,
    required this.customerName,
    required this.note,
    required this.organizationId,
  });
}

class UpdateNoteMark extends CustomerServiceEvent {
  final String ScheduleId;
  final bool isDone;
  final String Notes;

  const UpdateNoteMark({
    required this.ScheduleId,
    required this.isDone,
    required this.Notes,
  });
}

class LoadMoreServiceDetails extends CustomerServiceEvent {
  final String organizationId;
  final int limit;
  final int offset;

  const LoadMoreServiceDetails({
    required this.organizationId,
    required this.limit,
    required this.offset,
  });
}

class LoadMoreCustomers extends CustomerServiceEvent {
  final String organizationId;
  final LeadPagingRequest pagingRequest;

  const LoadMoreCustomers({
    required this.organizationId,
    required this.pagingRequest,
  });
}

class CreateReminder extends CustomerServiceEvent {
  final String organizationId;
  final ReminderServiceBody body;

  const CreateReminder({
    required this.organizationId,
    required this.body,
  });
}
