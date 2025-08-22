import 'package:source_base/data/models/service_detail_response.dart';

import 'customer_service_event.dart';
import 'customer_service_state.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bc;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';

class CustomerServiceBloc
    extends Bloc<CustomerServiceEvent, CustomerServiceState> {
  final OrganizationRepository organizationRepository;
  final CalendarRepository calendarRepository;
  StreamSubscription? _firebaseListener;

  CustomerServiceBloc({
    required this.organizationRepository,
    required this.calendarRepository,
  }) : super(const CustomerServiceState()) {
    on<LoadCustomerService>(_onLoadCustomerService,
        transformer: bc.droppable());
    on<LoadJourneyPaging>(_onLoadJourneyPaging, transformer: bc.droppable());
    on<LoadMoreServiceDetails>(_onLoadMoreServiceDetails,
        transformer: bc.droppable());
    on<LoadMoreCustomers>(_onLoadMoreCustomers, transformer: bc.droppable());
    on<PostCustomerNote>(_onPostCustomerNote, transformer: bc.sequential());
    on<UpdateNoteMark>(_onUpdateNoteMark, transformer: bc.sequential());
    on<CreateReminder>(_onCreateReminder, transformer: bc.sequential());
    on<UpdateReminder>(_onUpdateReminder, transformer: bc.sequential());
    on<ChangeStatusRead>(_onChangeStatusRead, transformer: bc.sequential());
    on<LoadFirstProviderChat>(_onLoadFirstProviderChat,
        transformer: bc.droppable());
    on<LoadMoreProviderChats>(_onLoadMoreProviderChats,
        transformer: bc.droppable());
    on<StorageConvertToCustomer>(_onStorageConvertToCustomer,
        transformer: bc.sequential());
    on<StorageUnArchiveCustomer>(_onStorageUnArchiveCustomer,
        transformer: bc.sequential());
    on<FirebaseConversationUpdated>(_onFirebaseConversationUpdated);
    on<ToggleFirebaseListenerRequested>(_onToggleFirebaseListenerRequested,
        transformer: bc.restartable());
    on<DisableFirebaseListenerRequested>(_onDisableFirebaseListenerRequested);
    on<LoadFacebookChat>(_onLoadFacebookChat, transformer: bc.droppable());
    on<DeleteCustomer>(_onDeleteCustomer, transformer: bc.sequential());
    on<DeleteReminder>(_onDeleteReminder, transformer: bc.sequential());
    on<ShowError>(_onShowError);
  }

  // -------------------- Helpers --------------------
  bool _ok(dynamic data) => Helpers.isResponseSuccess(data);

  String _currentCustomerServiceId(CustomerServiceModel? cs) =>
      cs?.id ?? state.customerService?.id ?? '';

  bool _hasMore(int? offset, int? count, int? total) {
    final o = offset ?? 0;
    final c = count ?? 0;
    final t = total ?? 0;
    return o + c < t;
  }

  // -------------------- Event Handlers --------------------
  Future<void> _onLoadFacebookChat(
    LoadFacebookChat event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(facebookChat: event.facebookChat));
  }

  Future<void> _onLoadCustomerService(
    LoadCustomerService event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(status: CustomerServiceStatus.loadingUserInfo));

    final response = await organizationRepository.getCustomerService(
      event.organizationId,
      event.pagingRequest ?? state.pagingRequest!,
    );

    if (_ok(response.data)) {
      final CustomerServiceResponse parsed =
          CustomerServiceResponse.fromJson(response.data);
      final hasMore = _hasMore(
        parsed.metadata?.offset,
        parsed.metadata?.count,
        parsed.metadata?.total,
      );

      emit(
        state.copyWith(
          status: CustomerServiceStatus.success,
          customerServices: parsed.content ?? [],
          customersMetadata: parsed.metadata,
          pagingRequest: event.pagingRequest ?? state.pagingRequest,
          hasMoreCustomers: hasMore,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: CustomerServiceStatus.error,
          error: (response.data['message'] as String?) ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onLoadJourneyPaging(
    LoadJourneyPaging event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: CustomerServiceStatus.loading,
          customerService: event.customerService,
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
            status: CustomerServiceStatus.success,
            customerService: event.customerService,
            serviceDetails: parsed.content ?? [],
            serviceDetailsMetadata: parsed.metadata,
            hasMoreServiceDetails: hasMore,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CustomerServiceStatus.error,
            error: (response.data['message'] as String?) ?? 'Unknown error',
          ),
        );
      }
    } catch (e, st) {
      log('LoadJourneyPaging error', error: e, stackTrace: st);
      emit(state.copyWith(
          status: CustomerServiceStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreServiceDetails(
    LoadMoreServiceDetails event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerServiceStatus.loadingMore));

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
            status: CustomerServiceStatus.success,
            serviceDetails: updated,
            serviceDetailsMetadata: parsed.metadata,
            hasMoreServiceDetails: hasMore,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CustomerServiceStatus.error,
            error: (response.data['message'] as String?) ?? 'Unknown error',
          ),
        );
      }
    } catch (e, st) {
      log('LoadMoreServiceDetails error', error: e, stackTrace: st);
      emit(state.copyWith(
          status: CustomerServiceStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreCustomers(
    LoadMoreCustomers event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerServiceStatus.loadingMore));

      final response = await organizationRepository.getCustomerService(
        event.organizationId,
        event.pagingRequest ?? state.pagingRequest!,
      );

      if (_ok(response.data)) {
        final CustomerServiceResponse parsed =
            CustomerServiceResponse.fromJson(response.data);

        final updated = List<CustomerServiceModel>.from(state.customerServices)
          ..addAll(parsed.content ?? []);

        final hasMore = _hasMore(
          parsed.metadata?.offset,
          parsed.metadata?.count,
          parsed.metadata?.total,
        );

        emit(
          state.copyWith(
            status: CustomerServiceStatus.success,
            customerServices: updated,
            customersMetadata: parsed.metadata,
            hasMoreCustomers: hasMore,
          ),
        );
      } else {
        // If first load failed -> show error; otherwise keep current list
        final message =
            (response.data['message'] as String?) ?? 'Unknown error';
        if (state.customerServices.isEmpty) {
          emit(state.copyWith(
              status: CustomerServiceStatus.error, error: message));
        } else {
          log('Load more customers error: $message');
        }
      }
    } catch (e, st) {
      if (state.customerServices.isEmpty) {
        emit(state.copyWith(
            status: CustomerServiceStatus.error, error: e.toString()));
      } else {
        log('Load more customers exception', error: e, stackTrace: st);
      }
    }
  }

  Future<void> _onPostCustomerNote(
    PostCustomerNote event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await organizationRepository.postCustomerNote(
      event.customerId,
      event.note,
      event.organizationId ?? '',
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
          status: CustomerServiceStatus.error,
          error: (response.data['message'] as String?) ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onUpdateNoteMark(
    UpdateNoteMark event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await calendarRepository.updateNoteMark(
      event.ScheduleId,
      event.isDone,
      event.Notes,
    );

    emit(
      state.copyWith(
        status: _ok(response.data)
            ? CustomerServiceStatus.success
            : CustomerServiceStatus.error,
      ),
    );
  }

  Future<void> _onCreateReminder(
    CreateReminder event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      final response = await calendarRepository.createReminder(
        event.organizationId,
        event.body,
      );

      if (_ok(response.data)) {
        add(LoadJourneyPaging(organizationId: event.organizationId));
        emit(state.copyWith(status: CustomerServiceStatus.success));
      } else {
        emit(
          state.copyWith(
            status: CustomerServiceStatus.errorCreateReminder,
            error: (response.data['message'] as String?) ?? 'Unknown error',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(
          status: CustomerServiceStatus.errorCreateReminder,
          error: e.toString()));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await calendarRepository.updateReminder(
      event.organizationId,
      event.body,
    );

    if (_ok(response.data)) {
      final updated = List<ScheduleModel>.from(state.scheduleDetails)
        ..removeWhere((e) => e.id == event.body.id);
      add(LoadJourneyPaging(organizationId: event.organizationId));
      emit(
        state.copyWith(
          status: CustomerServiceStatus.successStorageCustomer,
          scheduleDetails: updated,
        ),
      );
    } else {
      emit(state.copyWith(status: CustomerServiceStatus.errorUpdateReminder));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await calendarRepository.deleteReminder(
      event.organizationId,
      event.reminderId,
    );

    if (response.statusCode == 200) {
      add(LoadJourneyPaging(organizationId: event.organizationId));
      emit(state.copyWith(status: CustomerServiceStatus.successDeleteReminder));
    } else {
      emit(state.copyWith(status: CustomerServiceStatus.errorDeleteReminder));
    }
  }

  Future<void> _onShowError(
    ShowError event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(status: event.status, error: event.error));
  }

  Future<void> _onLoadFirstProviderChat(
    LoadFirstProviderChat event,
    Emitter<CustomerServiceState> emit,
  ) async {
    log('Loading Facebook chats for organization: ${event.organizationId}');
    emit(state.copyWith(
      status: CustomerServiceStatus.loading,
      customerServices: [],
    ));
    Future.delayed(const Duration(seconds: 1), () async {
      final response = await organizationRepository.getFacebookChatPaging(
        event.organizationId,
        20,
        0,
        event.provider,
      );

      final success = _ok(response.data);
      log('API Response success: $success');

      if (success) {
        final CustomerServiceResponse parsed =
            CustomerServiceResponse.fromJson(response.data);
        final hasMore = _hasMore(
          parsed.metadata?.offset,
          parsed.metadata?.count,
          parsed.metadata?.total,
        );

        emit(
          state.copyWith(
            status: CustomerServiceStatus.success,
            customerServices: parsed.content ?? [],
            facebookChatsMetadata: parsed.metadata,
            hasMoreFacebookChats: hasMore,
          ),
        );
      } else {
        log('API Error: ${response.data}');
        emit(state.copyWith(status: CustomerServiceStatus.error));
      }
    });
  }

  Future<void> _onLoadMoreProviderChats(
    LoadMoreProviderChats event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      log('Loading more Facebook chats - offset: ${event.offset}, limit: ${event.limit}');
      emit(state.copyWith(status: CustomerServiceStatus.loadingMore));

      final response = await organizationRepository.getFacebookChatPaging(
        event.organizationId,
        20,
        0,
        event.provider,
      );

      if (_ok(response.data)) {
        final CustomerServiceResponse parsed =
            CustomerServiceResponse.fromJson(response.data);

        final updated = List<CustomerServiceModel>.from(state.customerServices)
          ..addAll(parsed.content ?? []);

        final hasMore = _hasMore(
          parsed.metadata?.offset,
          parsed.metadata?.count,
          parsed.metadata?.total,
        );

        log('Loaded ${parsed.content?.length ?? 0} more Facebook chats');
        log('Total Facebook chats now: ${updated.length}');
        log('Has more: $hasMore');

        emit(
          state.copyWith(
            status: CustomerServiceStatus.success,
            customerServices: updated,
            facebookChatsMetadata: parsed.metadata,
            hasMoreFacebookChats: hasMore,
          ),
        );
      } else {
        final message =
            (response.data['message'] as String?) ?? 'Unknown error';
        log('Load more API Error: $message');
        emit(state.copyWith(
            status: CustomerServiceStatus.error, error: message));
      }
    } catch (e, st) {
      log('Load more provider chats exception', error: e, stackTrace: st);
      emit(state.copyWith(
          status: CustomerServiceStatus.error, error: e.toString()));
    }
  }

  Future<void> _onStorageConvertToCustomer(
    StorageConvertToCustomer event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(status: CustomerServiceStatus.loading));

    final response = await organizationRepository.postStorageConvertToCustomer(
      event.customerId,
      event.organizationId,
    );

    if (_ok(response.data)) {
      emit(
          state.copyWith(status: CustomerServiceStatus.successStorageCustomer));
    } else {
      emit(
        state.copyWith(
          status: CustomerServiceStatus.error,
          error: (response.data['message'] as String?) ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onStorageUnArchiveCustomer(
    StorageUnArchiveCustomer event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(status: CustomerServiceStatus.loading));

    final response = await organizationRepository.postUnArchiveCustomer(
      event.customerId,
      event.organizationId,
    );

    if (_ok(response.data)) {
      emit(
          state.copyWith(status: CustomerServiceStatus.successStorageCustomer));
    } else {
      emit(
        state.copyWith(
          status: CustomerServiceStatus.error,
          error: (response.data['message'] as String?) ?? 'Unknown error',
        ),
      );
    }
  }

  Future<void> _onChangeStatusRead(
    ChangeStatusRead event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await organizationRepository.updateStatusRead(
      event.conversationId,
      event.organizationId,
    );

    if (_ok(response.data)) {
      final updated = List<CustomerServiceModel>.from(state.customerServices);
      final index = updated.indexWhere((e) => e.id == event.conversationId);
      if (index != -1) {
        // updated[index] = updated[index].copyWith(isRead: true);
        emit(state.copyWith(customerServices: updated));
      }
    }
  }

  void _onDisableFirebaseListenerRequested(
    DisableFirebaseListenerRequested event,
    Emitter<CustomerServiceState> emit,
  ) {
    disableFirebaseListener();
  }

  void _onToggleFirebaseListenerRequested(
    ToggleFirebaseListenerRequested event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final ref = FirebaseDatabase.instance
        .ref('root/OrganizationId: ${event.organizationId}');

    await _firebaseListener?.cancel();
    _firebaseListener = ref.onValue.listen((eventListen) {
      final data = (eventListen.snapshot.value ?? {}) as Map;
      log('Firebase data: $data');
      if (!data.containsKey('CreateOrUpdateConversation')) return;

      try {
        final outerKey = data['CreateOrUpdateConversation'].keys.first;
        final rawData = data['CreateOrUpdateConversation'][outerKey];

        final CustomerServiceModel newConversation =
            CustomerServiceModel.fromFirebase(jsonDecode(jsonEncode(rawData)));

        //Update isRead nếu có
        // if (newConversation.id == state.facebookChat?.id) {
        //   newConversation.isRead = true;
        // }

        add(
          FirebaseConversationUpdated(
            organizationId: event.organizationId,
            conversation: newConversation,
            isUpdate: true,
          ),
        );
      } catch (e, st) {
        log('Error parsing Firebase message', error: e, stackTrace: st);
      }
    });
  }

  Future<void> _onFirebaseConversationUpdated(
    FirebaseConversationUpdated event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final existingIndex =
        state.customerServices.indexWhere((e) => e.id == event.conversation.id);

    var updatedChats = List<CustomerServiceModel>.from(state.customerServices);

    // If in detail view or same page, mark as read
    if (state.facebookChat?.id == event.conversation.id) {
      // if (updatedChats.isNotEmpty && updatedChats.first.isRead == true) {
      //   add(
      //     ChangeStatusRead(
      //       conversationId: updatedChats.first.id ?? '',
      //       organizationId: event.organizationId,
      //     ),
      //   );
      // }
    }
    // if (state.facebookChat?.pageId == event.conversation.pageId) {
    //   isRead = true;
    // }

    if (existingIndex != -1) {
      // if (updatedChats[existingIndex].pageId == event.conversation.pageId) {
      //   isRead = true;
      // }

      // Preserve immutable fields from existing item
      final newChat =
          updatedChats[existingIndex] = updatedChats[existingIndex].copyWith(
        createdDate: event.conversation.createdDate,
        lastModifiedDate: event.conversation.lastModifiedDate,
        snippet: event.conversation.snippet,
        channel: event.conversation.channel,
        pageName: event.conversation.pageName,
      );
      updatedChats
        ..removeAt(existingIndex)
        ..insert(0, newChat);
    } else {
      updatedChats.insert(0, event.conversation);
    }

    log('updatedChats length: ${updatedChats.length}');
    emit(state.copyWith(customerServices: updatedChats));
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await organizationRepository.deleteCustomerService(
      event.customerId,
      event.organizationId,
    );

    if (_ok(response.data)) {
      final updated = state.customerServices
          .where((e) => e.id != event.customerId)
          .toList();
      emit(
        state.copyWith(
          status: CustomerServiceStatus.successDeleteReminder,
          customerServices: updated,
        ),
      );
    } else {
      emit(state.copyWith(status: CustomerServiceStatus.error));
    }
  }

  void disableFirebaseListener() {
    _firebaseListener?.cancel();
    _firebaseListener = null;
  }

  @override
  Future<void> close() {
    _firebaseListener?.cancel();
    return super.close();
  }
}
