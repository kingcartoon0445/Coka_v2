import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/facebook_chat_response.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart'
    as service_detail;
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'customer_service_event.dart';
import 'customer_service_state.dart';

class CustomerServiceBloc
    extends Bloc<CustomerServiceEvent, CustomerServiceState> {
  final OrganizationRepository organizationRepository;
  final CalendarRepository calendarRepository;
  StreamSubscription? _firebaseListener;

  CustomerServiceBloc({
    required this.organizationRepository,
    required this.calendarRepository,
  }) : super(const CustomerServiceState()) {
    on<LoadCustomerService>(_onLoadCustomerService);
    on<LoadJourneyPaging>(_onLoadJourneyPaging);
    on<LoadMoreServiceDetails>(_onLoadMoreServiceDetails);
    on<LoadMoreCustomers>(_onLoadMoreCustomers);
    on<PostCustomerNote>(_onPostCustomerNote);
    on<UpdateNoteMark>(_onUpdateNoteMark);
    on<CreateReminder>(_onCreateReminder);
    on<ChangeStatusRead>(_onChangeStatusRead);
    on<LoadFirstProviderChat>(_onLoadFirstProviderChat);
    on<LoadMoreProviderChats>(_onLoadMoreProviderChats);
    on<StorageConvertToCustomer>(_onStorageConvertToCustomer);
    on<StorageUnArchiveCustomer>(_onStorageUnArchiveCustomer);
    on<FirebaseConversationUpdated>(_onFirebaseConversationUpdated);
    on<ToggleFirebaseListenerRequested>(_onToggleFirebaseListenerRequested);
    on<DisableFirebaseListenerRequested>(_onDisableFirebaseListenerRequested);
    on<LoadFacebookChat>(_onLoadFacebookChat);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

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
        event.organizationId, event.pagingRequest ?? state.pagingRequest!);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      final CustomerServiceResponse customerServiceResponse =
          CustomerServiceResponse.fromJson(response.data);

      // Calculate if there are more customers to load
      final hasMore = customerServiceResponse.metadata != null &&
          (customerServiceResponse.metadata!.offset ?? 0) +
                  (customerServiceResponse.metadata!.count ?? 0) <
              (customerServiceResponse.metadata!.total ?? 0);

      emit(state.copyWith(
          status: CustomerServiceStatus.success,
          customerServices: customerServiceResponse.content ?? [],
          customersMetadata: customerServiceResponse.metadata,
          pagingRequest: event.pagingRequest ?? state.pagingRequest,
          hasMoreCustomers: hasMore));
    } else {
      emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error'));
    }
  }

  Future<void> _onLoadJourneyPaging(
    LoadJourneyPaging event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(state.copyWith(
          status: CustomerServiceStatus.loading,
          customerService: event.customerService));

      final responseCalendar = await calendarRepository.getCalculator(
          event.organizationId,
          event.customerService == null
              ? state.customerService?.id ?? ''
              : event.customerService!.id ?? '');
      final bool isSuccessCalendar =
          Helpers.isResponseSuccess(responseCalendar.data);
      if (isSuccessCalendar) {
        final ScheduleResponse journeyPagingResponse =
            ScheduleResponse.fromJson(responseCalendar.data);
        emit(state.copyWith(scheduleDetails: journeyPagingResponse.data));
      }

      final response = await organizationRepository.getLeadPagingArchive(
          event.customerService == null
              ? state.customerService?.id ?? ''
              : event.customerService!.id ?? '',
          event.organizationId,
          type: event.type);
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final service_detail.ServiceDetailResponse journeyPagingResponse =
            service_detail.ServiceDetailResponse.fromJson(response.data);

        // Calculate if there are more items to load
        final hasMore = journeyPagingResponse.metadata != null &&
            (journeyPagingResponse.metadata!.offset ?? 0) +
                    (journeyPagingResponse.metadata!.count ?? 0) <
                (journeyPagingResponse.metadata!.total ?? 0);

        emit(state.copyWith(
            status: CustomerServiceStatus.success,
            customerService: event.customerService,
            serviceDetails: journeyPagingResponse.content ?? [],
            serviceDetailsMetadata: journeyPagingResponse.metadata,
            hasMoreServiceDetails: hasMore));
      } else {
        emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CustomerServiceStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreServiceDetails(
    LoadMoreServiceDetails event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerServiceStatus.loadingMore));

      final response = await organizationRepository.getLeadPagingArchive(
          state.customerService?.id ?? '', event.organizationId,
          limit: event.limit, offset: event.offset, type: event.type);

      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final service_detail.ServiceDetailResponse serviceDetailResponse =
            service_detail.ServiceDetailResponse.fromJson(response.data);

        // Append new items to existing list
        final updatedServiceDetails =
            List<service_detail.ServiceDetailModel>.from(state.serviceDetails)
              ..addAll(serviceDetailResponse.content ?? []);

        // Calculate if there are more items to load
        final hasMore = serviceDetailResponse.metadata != null &&
            (serviceDetailResponse.metadata!.offset ?? 0) +
                    (serviceDetailResponse.metadata!.count ?? 0) <
                (serviceDetailResponse.metadata!.total ?? 0);

        emit(state.copyWith(
            status: CustomerServiceStatus.success,
            serviceDetails: updatedServiceDetails,
            serviceDetailsMetadata: serviceDetailResponse.metadata,
            hasMoreServiceDetails: hasMore));
      } else {
        emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CustomerServiceStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreCustomers(
    LoadMoreCustomers event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerServiceStatus.loadingMore));

      final response = await organizationRepository.getCustomerService(
          event.organizationId, event.pagingRequest ?? state.pagingRequest!);

      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final CustomerServiceResponse customerServiceResponse =
            CustomerServiceResponse.fromJson(response.data);

        // Append new items to existing list
        final updatedCustomers =
            List<CustomerServiceModel>.from(state.customerServices)
              ..addAll(customerServiceResponse.content ?? []);

        // Calculate if there are more items to load
        final hasMore = customerServiceResponse.metadata != null &&
            (customerServiceResponse.metadata!.offset ?? 0) +
                    (customerServiceResponse.metadata!.count ?? 0) <
                (customerServiceResponse.metadata!.total ?? 0);

        emit(state.copyWith(
            status: CustomerServiceStatus.success,
            customerServices: updatedCustomers,
            customersMetadata: customerServiceResponse.metadata,
            hasMoreCustomers: hasMore));
      } else {
        // Chỉ set error nếu đây là lần load đầu tiên
        if (state.customerServices.isEmpty) {
          emit(state.copyWith(
            status: CustomerServiceStatus.error,
            error: response.data['message'] as String? ?? 'Unknown error',
          ));
        } else {
          // Nếu đã có dữ liệu, chỉ log error mà không thay đổi status
          print('Load more error: ${response.data['message']}');
        }
      }
    } catch (e) {
      // Chỉ set error nếu đây là lần load đầu tiên
      if (state.customerServices.isEmpty) {
        emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: e.toString(),
        ));
      } else {
        // Nếu đã có dữ liệu, chỉ log error mà không thay đổi status
        print('Load more exception: $e');
      }
    }
  }

  Future<void> _onPostCustomerNote(
    PostCustomerNote event,
    Emitter<CustomerServiceState> emit,
  ) async {
    // emit(state.copyWith(status: CustomerServiceStatus.loading));
    final response = await organizationRepository.postCustomerNote(
        event.customerId, event.note, event.organizationId ?? '');
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      String fullName = event.customerName;
      // Parse the new note as a ScheduleModel and add it to scheduleDetails
      if (response.data['content'] != null) {
        final newSchedule = service_detail.ServiceDetailModel(
          id: response.data['content']['id'],
          summary: "Thêm ghi chú: ${event.note}",
          createdDate: response.data['content']['createdDate'],
          createdByName: fullName,
          type: response.data['content']['type'],
          icon: "",
        );
        final updatedScheduleDetails =
            List<service_detail.ServiceDetailModel>.from(state.serviceDetails)
              ..insert(0, newSchedule);
        emit(state.copyWith(serviceDetails: updatedScheduleDetails));
      }
      // emit(state.copyWith(
      //     status: CustomerServiceStatus.postCustomerNoteSuccess));
    } else {
      emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error'));
    }
  }

  Future<void> _onUpdateNoteMark(
    UpdateNoteMark event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await calendarRepository.updateNoteMark(
        event.ScheduleId, event.isDone, event.Notes);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      emit(state.copyWith(status: CustomerServiceStatus.success));
    } else {
      emit(state.copyWith(status: CustomerServiceStatus.error));
    }
  }

  Future<void> _onCreateReminder(
    CreateReminder event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      // emit(state.copyWith(status: CustomerServiceStatus.loading));

      // TODO: Gọi API thực tế khi có
      final response = await calendarRepository.createReminder(
          event.organizationId, event.body);
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final fakeReminder = ScheduleModel(
          id: response.data['content']?['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: event.body.title,
          // description: event.body.description,
          startTime: event.body.startTime,
          endTime: event.body.endTime,
          isDone: false,
          content: event.body.content,
          // createdByName: "", // hoặc lấy từ user hiện tại nếu có
          // : DateTime.now().toIso8601String(),
          // type: event.body.,
          // Thêm các trường khác nếu ScheduleModel có
        );

        // Thêm reminder mới vào đầu danh sách serviceDetails
        final updatedServiceDetails =
            List<ScheduleModel>.from(state.scheduleDetails)
              ..insert(0, fakeReminder);

        emit(state.copyWith(
          status: CustomerServiceStatus.success,
          scheduleDetails: updatedServiceDetails,
        ));
      } else {
        emit(state.copyWith(status: CustomerServiceStatus.error));
      }

      // Tạo dữ liệu ảo cho reminder
    } catch (e) {
      emit(state.copyWith(
        status: CustomerServiceStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFirstProviderChat(
    LoadFirstProviderChat event,
    Emitter<CustomerServiceState> emit,
  ) async {
    print(
        '🔍 Loading Facebook chats for organization: ${event.organizationId}');
    emit(state.copyWith(status: CustomerServiceStatus.loading));
    final response = await organizationRepository.getFacebookChatPaging(
        event.organizationId, 20, 0, event.provider);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    print('🔍 API Response success: $isSuccess');
    print('🔍 API Response data: ${response.data}');

    if (isSuccess) {
      final FacebookChatResponse facebookChatResponse =
          FacebookChatResponse.fromJson(response.data);

      print(
          '🔍 Parsed Facebook chats count: ${facebookChatResponse.content?.length ?? 0}');
      print('🔍 Facebook chats: ${facebookChatResponse.content}');

      // Calculate if there are more Facebook chats to load
      final hasMore = facebookChatResponse.metadata != null &&
          (facebookChatResponse.metadata!.offset ?? 0) +
                  (facebookChatResponse.metadata!.count ?? 0) <
              (facebookChatResponse.metadata!.total ?? 0);

      emit(state.copyWith(
          status: CustomerServiceStatus.success,
          facebookChats: facebookChatResponse.content ?? [],
          facebookChatsMetadata: facebookChatResponse.metadata,
          hasMoreFacebookChats: hasMore));
    } else {
      print('❌ API Error: ${response.data}');
      emit(state.copyWith(status: CustomerServiceStatus.error));
    }
  }

  Future<void> _onLoadMoreProviderChats(
    LoadMoreProviderChats event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      print(
          '🔍 Loading more Facebook chats - offset: ${event.offset}, limit: ${event.limit}');
      emit(state.copyWith(status: CustomerServiceStatus.loadingMore));

      final response = await organizationRepository.getFacebookChatPaging(
          event.organizationId, event.limit, event.offset, event.provider);

      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final FacebookChatResponse facebookChatResponse =
            FacebookChatResponse.fromJson(response.data);

        // Append new items to existing list
        final updatedFacebookChats =
            List<FacebookChatModel>.from(state.facebookChats)
              ..addAll(facebookChatResponse.content ?? []);

        // Calculate if there are more items to load
        final hasMore = facebookChatResponse.metadata != null &&
            (facebookChatResponse.metadata!.offset ?? 0) +
                    (facebookChatResponse.metadata!.count ?? 0) <
                (facebookChatResponse.metadata!.total ?? 0);

        print(
            '🔍 Loaded ${facebookChatResponse.content?.length ?? 0} more Facebook chats');
        print('🔍 Total Facebook chats now: ${updatedFacebookChats.length}');
        print('🔍 Has more: $hasMore');

        emit(state.copyWith(
            status: CustomerServiceStatus.success,
            facebookChats: updatedFacebookChats,
            facebookChatsMetadata: facebookChatResponse.metadata,
            hasMoreFacebookChats: hasMore));
      } else {
        print('❌ Load more API Error: ${response.data}');
        emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error',
        ));
      }
    } catch (e) {
      print('❌ Load more exception: $e');
      emit(state.copyWith(
        status: CustomerServiceStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onStorageConvertToCustomer(
    StorageConvertToCustomer event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(status: CustomerServiceStatus.loading));
    final response = await organizationRepository.postStorageConvertToCustomer(
        event.customerId, event.organizationId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      emit(
          state.copyWith(status: CustomerServiceStatus.successStorageCustomer));
    } else {
      emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error'));
    }
  }

  Future<void> _onStorageUnArchiveCustomer(
    StorageUnArchiveCustomer event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(state.copyWith(status: CustomerServiceStatus.loading));
    final response = await organizationRepository.postUnArchiveCustomer(
        event.customerId, event.organizationId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      emit(
          state.copyWith(status: CustomerServiceStatus.successStorageCustomer));
    } else {
      emit(state.copyWith(
          status: CustomerServiceStatus.error,
          error: response.data['message'] as String? ?? 'Unknown error'));
    }
  }

  Future<void> _onChangeStatusRead(
    ChangeStatusRead event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await organizationRepository.updateStatusRead(
        event.conversationId, event.organizationId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      final updatedChats = List<FacebookChatModel>.from(state.facebookChats);
      final index = updatedChats
          .indexWhere((element) => element.id == event.conversationId);
      if (index != -1) {
        updatedChats[index] = updatedChats[index].copyWith(isRead: true);
      }
      emit(state.copyWith(facebookChats: updatedChats));
    }
  }

  void _onDisableFirebaseListenerRequested(
    DisableFirebaseListenerRequested event,
    Emitter<CustomerServiceState> emit,
  ) async {
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
      log('🔍 Firebase data: $data');
      if (!data.containsKey("CreateOrUpdateConversation")) return;
      try {
        final outerKey = data["CreateOrUpdateConversation"].keys.first;
        // final conversationId = outerKey.split(': ').last;
        // final isDetailUpdate = event.currentConversationId == conversationId;

        final rawData = data["CreateOrUpdateConversation"][outerKey];

        log('🔍 Firebase data: $rawData');
        final jsonString = jsonEncode(rawData);
        final FacebookChatModel newConversation =
            FacebookChatModel.fromFirebase(jsonDecode(jsonString));
        if (newConversation.conversationId == state.facebookChat?.id) {
          newConversation.isRead = true;
        }

        add(FirebaseConversationUpdated(
          organizationId: event.organizationId,
          conversation: newConversation,
          isUpdate: true,
          // isRead: isDetailUpdate,
        ));
      } catch (e) {
        print("Error parsing Firebase message: $e");
      }
    });
  }

  Future<void> _onFirebaseConversationUpdated(
    FirebaseConversationUpdated event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final existingIndex = state.facebookChats
        .indexWhere((e) => e.id == event.conversation.conversationId);
    List<FacebookChatModel> updatedChats = List.from(state.facebookChats);
    bool isRead = false;
    //Nếu đang ở trong chi tiết chat thì đánh đấu đã đọc
    if (state.facebookChat?.id == event.conversation.conversationId) {
      isRead = true;
      if (updatedChats.first.isRead == true) {
        add(ChangeStatusRead(
            conversationId: updatedChats.first.id ?? '',
            organizationId: event.organizationId));
      }
    }
    if (state.facebookChat?.pageId == event.conversation.pageId) {
      isRead = true;
    }
    if (existingIndex != -1) {
      log('🔍 updatedChats[existingIndex].pageId: ${updatedChats[existingIndex].pageId}');
      log('🔍 event.conversation.pageId: ${event.conversation.pageId}');
      if (updatedChats[existingIndex].pageId == event.conversation.pageId) {
        isRead = true;
      }
      // Nếu đã có, xóa ở vị trí cũ và chèn lên đầu
      updatedChats[existingIndex].isRead = event.conversation.isRead;
      updatedChats[existingIndex].snippet = event.conversation.snippet;
      // Copy all values from updatedChats[existingIndex] to event.conversation, except isRead and snippet
      event.conversation
        ..id = updatedChats[existingIndex].id
        ..integrationAuthId = updatedChats[existingIndex].integrationAuthId
        ..conversationId = updatedChats[existingIndex].conversationId
        ..pageId = updatedChats[existingIndex].pageId
        ..pageName = updatedChats[existingIndex].pageName
        ..pageAvatar = updatedChats[existingIndex].pageAvatar
        ..personId = updatedChats[existingIndex].personId
        ..personName = updatedChats[existingIndex].personName
        ..personAvatar = updatedChats[existingIndex].personAvatar
        // snippet: keep event.conversation.snippet
        ..unreadCount = updatedChats[existingIndex].unreadCount
        ..canReply = updatedChats[existingIndex].canReply
        ..updatedTime = updatedChats[existingIndex].updatedTime
        ..gptStatus = updatedChats[existingIndex].gptStatus
        ..isRead = isRead
        // isRead: keep event.conversation.isRead
        ..type = updatedChats[existingIndex].type
        ..provider = updatedChats[existingIndex].provider
        ..status = updatedChats[existingIndex].status
        ..contact = updatedChats[existingIndex].contact
        ..messageCount = updatedChats[existingIndex].messageCount
        ..assignTo = updatedChats[existingIndex].assignTo
        ..assignName = updatedChats[existingIndex].assignName
        ..assignAvatar = updatedChats[existingIndex].assignAvatar;
      final existingChat = updatedChats.removeAt(existingIndex);
      updatedChats.insert(0, event.conversation);
    } else {
      // Nếu chưa có, thêm mới vào đầu danh sách
      updatedChats.insert(
          0,
          event.conversation.copyWith(
            isRead: isRead,
          ));
    }

    log('🔍 updatedChats: $updatedChats');

    emit(state.copyWith(facebookChats: updatedChats));
    // return;
    // final updated = event.conversation.copyWith(isRead: event.isRead);
    // final index = state.facebookChats.indexWhere((e) => e.id == updated.id);
    // final newList = [...state.facebookChats];
    // if (index != -1) {
    //   newList[index] = updated;
    // } else {
    //   newList.insert(0, updated);
    // }
    // emit(state.copyWith(facebookChats: newList));
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerServiceState> emit,
  ) async {
    final response = await organizationRepository.deleteCustomerService(
        event.customerId, event.organizationId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      final updatedCustomers = state.customerServices
          .where((element) => element.id != event.customerId)
          .toList();
      emit(state.copyWith(
          status: CustomerServiceStatus.success,
          customerServices: updatedCustomers));
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
