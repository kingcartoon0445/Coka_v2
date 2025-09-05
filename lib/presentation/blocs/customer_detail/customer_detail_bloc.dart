import 'package:bloc_concurrency/bloc_concurrency.dart' as bc;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/deal_activity_repository.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'package:source_base/data/repositories/switch_final_deal_repository.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_event.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_state.dart';
import 'package:source_base/presentation/blocs/customer_detail/model/customer_detail_response.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/customer_detail_model.dart';
import 'dart:developer';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';

class _Ids {
  final String? leadId;
  final String? customerId;
  const _Ids(this.leadId, this.customerId);
}

class CustomerDetailBloc
    extends Bloc<CustomerDetailEvent, CustomerDetailState> {
  final OrganizationRepository organizationRepository;
  final CalendarRepository calendarRepository;
  final DealActivityRepository dealActivityRepository;
  final SwitchFinalDealRepository switchFinalDealRepository;
  CustomerDetailBloc({
    required this.organizationRepository,
    required this.calendarRepository,
    required this.dealActivityRepository,
    required this.switchFinalDealRepository,
  }) : super(const CustomerDetailState()) {
    on<LoadCustomerDetail>(_onLoadCustomerDetail, transformer: bc.sequential());
    on<LoadCustomerDetailValue>(_onLoadCustomerDetailValue,
        transformer: bc.droppable());
    on<LoadMoreServiceDetails>(_onLoadMoreServiceDetails,
        transformer: bc.droppable());
    on<PostCustomerNote>(_onPostCustomerNote, transformer: bc.sequential());
    on<UpdateNoteMark>(_onUpdateNoteMark, transformer: bc.sequential());
    on<CreateReminder>(_onCreateReminder, transformer: bc.sequential());
    on<UpdateReminder>(_onUpdateReminder, transformer: bc.sequential());
    on<DeleteReminder>(_onDeleteReminder, transformer: bc.sequential());
    on<LoadPaginges>(_onLoadPaginges, transformer: bc.sequential());
    on<ShowError>(_onShowError);
    on<DisposeCustomerDetail>(_onDisposeCustomerDetail,
        transformer: bc.sequential());
    on<LinkToLeadEvent>(_onLinkToLead, transformer: bc.sequential());
    on<SearchCustomerEvent>(_onSearchCustomer, transformer: bc.droppable());
    on<LoadFacebookChat>(_onLoadFacebookChat, transformer: bc.droppable());
    on<CancelSearch>(_onCancelSearch, transformer: bc.droppable());
    on<CancelSearchCustomer>(_onCancelSearchCustomer,
        transformer: bc.droppable());
    on<SearchCustomerPagingesEvent>(_onSearchCustomerPaginges,
        transformer: bc.droppable());
  }

  // -------------------- Helpers --------------------
  bool _ok(dynamic data) => Helpers.isResponseSuccess(data);

  Future<_Ids> _resolveIdsFromConversation(
      String orgId, String conversationId) async {
    try {
      final res = await dealActivityRepository.getDetailConversation(
          orgId, conversationId);
      if (_ok(res.data)) {
        final c = res.data['content'] as Map<String, dynamic>?;
        return _Ids(
          c?['lead']?['id'] as String?,
          c?['customer']?['id'] as String?,
        );
      }
    } catch (_) {}
    return _Ids(
        conversationId, null); // fallback: dùng conversationId như leadId
  }

  Future<LeadDetailResponse?> _fetchLead(String orgId, String id) async {
    try {
      final r = await dealActivityRepository.getCustomerDetail(orgId, id,
          isCustomer: false);
      return _ok(r.data) ? LeadDetailResponse.fromJson(r.data) : null;
    } catch (_) {
      return null;
    }
  }

  Future<CustomerDetailResponse?> _fetchCustomer(
      String orgId, String id) async {
    try {
      final r = await dealActivityRepository.getCustomerDetail(orgId, id,
          isCustomer: true);
      return _ok(r.data) ? CustomerDetailResponse.fromJson(r.data) : null;
    } catch (_) {
      return null;
    }
  }

  String? _extractCustomerIdFromLeadJson(LeadDetailResponse? leadRes) {
    try {
      final raw = leadRes?.content; // nếu bạn giữ rawJson trong model
      final c = raw?.customer;
      return c!.id;
    } catch (_) {
      return null;
    }
  }

  bool _isUuid(String? s) =>
      s != null &&
      RegExp(r'^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$')
          .hasMatch(s);

  String _currentCustomerServiceId(CustomerServiceModel? cs) =>
      cs?.id ?? state.customerService?.id ?? '';

  bool _hasMore(int? offset, int? count, int? total) {
    final o = offset ?? 0;
    final c = count ?? 0;
    final t = total ?? 0;
    return o + c < t;
  }

  Future<void> _onLoadCustomerDetail(
    LoadCustomerDetail event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(status: CustomerDetailStatus.loading));

    try {
      LeadDetailResponse? leadRes;
      CustomerDetailResponse? cusRes;

      if (state.isChat) {
        // ===== Trường hợp chat: lấy id từ conversation =====
        final ids = await _resolveIdsFromConversation(
          event.organizationId,
          event.customerId,
        );

        // Gọi song song lead & customer
        final results = await Future.wait([
          if (_isUuid(ids.leadId))
            _fetchLead(event.organizationId, ids.leadId!)
          else
            Future.value(null),
          if (_isUuid(ids.customerId))
            _fetchCustomer(event.organizationId, ids.customerId!)
          else
            Future.value(null),
        ]);

        leadRes = results[0] as LeadDetailResponse?;
        cusRes = results[1] as CustomerDetailResponse?;
      } else {
        // ===== Trường hợp không chat: gọi thẳng /lead/{id} trước =====
        if (_isUuid(event.customerId)) {
          leadRes = await _fetchLead(event.organizationId, event.customerId);
          final customerId = _extractCustomerIdFromLeadJson(leadRes);
          if (_isUuid(customerId)) {
            cusRes = await _fetchCustomer(event.organizationId, customerId!);
          }
        }
      }

      // ===== Emit kết quả =====
      if (leadRes?.content != null || cusRes?.content != null) {
        emit(state.copyWith(
          leadDetail: leadRes?.content,
          customerDetailModel: cusRes?.content,
          isDelete: false,
          status: CustomerDetailStatus.successGetCustomerDetail,
        ));
        add(LoadPaginges(organizationId: event.organizationId));
      } else {
        emit(state.copyWith(
          leadDetail: null,
          customerDetailModel: null,
          isDelete: true,
          status: CustomerDetailStatus.successGetCustomerDetail,
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: CustomerDetailStatus.errorGetCustomerDetail));
    }
  }

  Future<void> _onLoadCustomerDetailValue(
    LoadCustomerDetailValue event,
    Emitter<CustomerDetailState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: CustomerDetailStatus.loading,
          customerService: event.customerService,
          isChat: event.isChat,
        ),
      );

      // Calendar (schedule)
      final responseCalendar = await calendarRepository.getCalculator(
        event.organizationId,
        _currentCustomerServiceId(event.customerService),
      );
      if (_ok(responseCalendar.data)) {
        final ScheduleResponse schedule =
            ScheduleResponse.fromJson(responseCalendar.data);
        emit(state.copyWith(scheduleDetails: schedule.data));
      }

      // Journey/service details
      final response = await organizationRepository.getLeadPagingArchive(
        _currentCustomerServiceId(event.customerService),
        event.organizationId,
        type: event.type,
      );

      if (_ok(response.data)) {
        final ServiceDetailResponse parsed =
            ServiceDetailResponse.fromJson(response.data);

        final hasMore = _hasMore(
          parsed.metadata?.offset,
          parsed.metadata?.count,
          parsed.metadata?.total,
        );

        emit(
          state.copyWith(
            status: CustomerDetailStatus.success,
            customerService: event.customerService,
            serviceDetails: parsed.content ?? [],
            serviceDetailsMetadata: parsed.metadata,
            hasMoreServiceDetails: hasMore,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CustomerDetailStatus.error,
            error: (response.data['message'] as String?) ?? 'Unknown error',
          ),
        );
      }
    } catch (e, st) {
      log('LoadJourneyPaging error', error: e, stackTrace: st);
      emit(state.copyWith(
          status: CustomerDetailStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreServiceDetails(
    LoadMoreServiceDetails event,
    Emitter<CustomerDetailState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerDetailStatus.loadingMore));

      final response = await organizationRepository.getLeadPagingArchive(
        state.customerService?.id ?? '',
        event.organizationId,
        limit: event.limit,
        offset: event.offset,
        type: event.type,
      );

      if (_ok(response.data)) {
        final ServiceDetailResponse parsed =
            ServiceDetailResponse.fromJson(response.data);

        final updated = List<ServiceDetailModel>.from(state.serviceDetails)
          ..addAll(parsed.content ?? []);

        final hasMore = _hasMore(
          parsed.metadata?.offset,
          parsed.metadata?.count,
          parsed.metadata?.total,
        );

        emit(
          state.copyWith(
            status: CustomerDetailStatus.success,
            serviceDetails: updated,
            serviceDetailsMetadata: parsed.metadata,
            hasMoreServiceDetails: hasMore,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CustomerDetailStatus.error,
            error: (response.data['message'] as String?) ?? 'Unknown error',
          ),
        );
      }
    } catch (e, st) {
      log('LoadMoreServiceDetails error', error: e, stackTrace: st);
      emit(state.copyWith(
          status: CustomerDetailStatus.error, error: e.toString()));
    }
  }

  Future<void> _onPostCustomerNote(
    PostCustomerNote event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final response = await organizationRepository.postCustomerNote(
      event.customerId,
      event.note,
      event.organizationId,
    );

    if (_ok(response.data)) {
      final fullName = event.customerName;
      final content = response.data['content'];
      if (content != null) {
        final newSchedule = ServiceDetailModel(
          id: content['id'],
          summary: 'Thêm ghi chú: ${event.note}',
          createdDate: content['createdDate'],
          createdByName: fullName,
          type: content['type'],
          icon: '',
        );
        final updated = List<ServiceDetailModel>.from(state.serviceDetails)
          ..insert(0, newSchedule);
        emit(state.copyWith(serviceDetails: updated));
      }
    } else {
      emit(
        state.copyWith(
          status: CustomerDetailStatus.error,
          error: (response.data['message'] as String?) ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onUpdateNoteMark(
    UpdateNoteMark event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final response = await calendarRepository.updateNoteMark(
      event.ScheduleId,
      event.isDone,
      event.Notes,
    );

    emit(
      state.copyWith(
        status: _ok(response.data)
            ? CustomerDetailStatus.success
            : CustomerDetailStatus.error,
      ),
    );
  }

  Future<void> _onCreateReminder(
    CreateReminder event,
    Emitter<CustomerDetailState> emit,
  ) async {
    try {
      final response = await calendarRepository.createReminder(
        event.organizationId,
        event.body,
      );

      if (_ok(response.data)) {
        add(LoadCustomerDetailValue(organizationId: event.organizationId));
        emit(state.copyWith(status: CustomerDetailStatus.success));
      } else {
        emit(
          state.copyWith(
            status: CustomerDetailStatus.errorCreateReminder,
            error: (response.data['message'] as String?) ?? 'Unknown error',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(
          status: CustomerDetailStatus.errorCreateReminder,
          error: e.toString()));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final response = await calendarRepository.updateReminder(
      event.organizationId,
      event.body,
    );

    if (_ok(response.data)) {
      final updated = List<ScheduleModel>.from(state.scheduleDetails)
        ..removeWhere((e) => e.id == event.body.id);
      add(LoadCustomerDetailValue(organizationId: event.organizationId));
      emit(
        state.copyWith(
          status: CustomerDetailStatus.successStorageCustomer,
          scheduleDetails: updated,
        ),
      );
    } else {
      emit(state.copyWith(status: CustomerDetailStatus.errorUpdateReminder));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final response = await calendarRepository.deleteReminder(
      event.organizationId,
      event.reminderId,
    );

    if (response.statusCode == 200) {
      add(LoadCustomerDetailValue(organizationId: event.organizationId));
      emit(state.copyWith(status: CustomerDetailStatus.successDeleteReminder));
    } else {
      emit(state.copyWith(status: CustomerDetailStatus.errorDeleteReminder));
    }
  }

  Future<void> _onLoadPaginges(
    LoadPaginges event,
    Emitter<CustomerDetailState> emit,
  ) async {
    // Get list paging
    try {
      final response = await organizationRepository.getFilterItem(
        event.organizationId,
      );
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final PagingResponse responsePaging =
            PagingResponse.fromJson(response.data);
        List<PagingModel> initLabels = [];
        for (final PagingModel item in responsePaging.content ?? []) {
          for (final itemCF in state.leadDetail?.tags ?? []) {
            if (item.name == itemCF) {
              initLabels.add(item);
            }
          }
        }

        emit(state.copyWith(
            paginges: responsePaging.content,
            initLabels: initLabels,
            status: CustomerDetailStatus.successLoadPaginges));
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _onShowError(
    ShowError event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(status: event.status, error: event.error));
  }

  Future<void> _onDisposeCustomerDetail(
    DisposeCustomerDetail event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(status: CustomerDetailStatus.initial, isDelete: true));
  }

  Future<void> _onLinkToLead(
    LinkToLeadEvent event,
    Emitter<CustomerDetailState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerDetailStatus.loading));
      final response = await organizationRepository.linkToLeadRepository(
        event.organizationId,
        event.conversationId,
        event.leadId,
      );
      if (_ok(response.data)) {
        emit(state.copyWith(status: CustomerDetailStatus.successLinkToLead));
      } else {
        emit(state.copyWith(status: CustomerDetailStatus.errorLinkToLead));
      }
    } catch (e) {
      emit(state.copyWith(status: CustomerDetailStatus.errorLinkToLead));
    }
  }

  Future<void> _onSearchCustomer(
    SearchCustomerEvent event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(customersStatus: CustomersStatus.loading));
    try {
      final customers = await organizationRepository.getCustomerService(
        event.organizationId,
        LeadPagingRequest(
            limit: 10, offset: 0, searchText: event.name, channels: ["LEAD"]),
      );
      if (_ok(customers.data)) {
        final parsed = CustomerServiceResponse.fromJson(customers.data);
        emit(state.copyWith(
          customersStatus: CustomersStatus.success,
          customerServices: parsed.content ?? [],
        ));
      } else {
        emit(state.copyWith(customersStatus: CustomersStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(customersStatus: CustomersStatus.error));
    }
  }

  Future<void> _onSearchCustomerPaginges(
    SearchCustomerPagingesEvent event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(customersStatus: CustomersStatus.loading));
    final response = await switchFinalDealRepository.getListPaging(
      startDate: '',
      endDate: '',
      isBusiness: false,
      organizationId: event.organizationId,
      limit: 10,
      offset: 0,
      searchText: event.name,
    );
    if (_ok(response.data)) {
      final parsed = CustomerPagingResponse.fromJson(response.data);
      emit(state.copyWith(customerPaginges: parsed.content ?? []));
    } else {
      emit(state.copyWith(customersStatus: CustomersStatus.error));
    }
  }

  Future<void> _onLoadFacebookChat(
    LoadFacebookChat event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(isChat: event.isChat));
    if (event.facebookChat != null) {
      emit(state.copyWith(customerService: event.facebookChat));
      return;
    }

    final response = await organizationRepository.getCustomerService(
        state.organizationId ?? '',
        LeadPagingRequest(
          limit: 40,
          offset: 0,
        ));

    if (_ok(response.data)) {
      final CustomerServiceResponse parsed =
          CustomerServiceResponse.fromJson(response.data);
      final CustomerServiceModel? facebookChat = parsed.content?.firstWhere(
        (element) => element.id == event.conversationId,
        orElse: () => CustomerServiceModel(),
      );
      emit(state.copyWith(customerService: null, isDelete: true));

      emit(state.copyWith(customerService: facebookChat));
    }

    // emit(state.copyWith(facebookChat: event.facebookChat));
  }

  Future<void> _onCancelSearch(
    CancelSearch event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(state.copyWith(customerServices: []));
  }

  Future<void> _onCancelSearchCustomer(
    CancelSearchCustomer event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(CustomerDetailState());
  }
}
