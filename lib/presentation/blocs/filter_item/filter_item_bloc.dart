import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/data/models/utm_member_response.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'package:source_base/data/repositories/switch_final_deal_repository.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';

import 'filter_item_event.dart';
import 'filter_item_state.dart';

class FilterItemBloc extends Bloc<FilterItemEvent, FilterItemState> {
  final OrganizationRepository organizationRepository;
  final SwitchFinalDealRepository switchFinalDealRepository;
  FilterItemBloc({
    required this.organizationRepository,
    required this.switchFinalDealRepository,
  }) : super(const FilterItemState()) {
    on<LoadFilterItem>(_onLoadFilterItem);
    on<CreateLead>(_onCreateLead);
  }

  Future<void> _onLoadFilterItem(
    LoadFilterItem event,
    Emitter<FilterItemState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FilterItemStatus.loading));

      // Get list paging
      final response = await organizationRepository.getFilterItem(
        event.organizationId,
      );
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        final PagingResponse responsePaging =
            PagingResponse.fromJson(response.data);
        emit(state.copyWith(paginges: responsePaging.content));
      }

      // Get list member
      final responseMember = await organizationRepository.getListMember(
        event.organizationId,
      );
      final bool isSuccessMember =
          Helpers.isResponseSuccess(responseMember.data);
      if (isSuccessMember) {
        final MemberResponse customerServiceResponse =
            MemberResponse.fromJson(responseMember.data);
        emit(state.copyWith(members: customerServiceResponse.content));
      }

      // Get utm source
      final responseUtmSource = await organizationRepository.getUtmSource(
        event.organizationId,
      );
      if (Helpers.isResponseSuccess(responseUtmSource.data)) {
        final UtmSourceResponse responseUtmSourcePaging =
            UtmSourceResponse.fromJson(responseUtmSource.data);
        emit(state.copyWith(utmSources: responseUtmSourcePaging.content));
      }

      // Get list paging
      final responsePaging = await switchFinalDealRepository.getListPaging(
        organizationId: event.organizationId,
        limit: 20,
        offset: 0,
        startDate: '',
        endDate: '',
        isBusiness: true,
        searchText: '',
      );
      final bool isSuccessPaging =
          Helpers.isResponseSuccess(responsePaging.data);
      if (isSuccessPaging) {
        final CustomerPagingResponse responsePagingModel =
            CustomerPagingResponse.fromJson(responsePaging.data);
        emit(state.copyWith(customerPaging: responsePagingModel.content ?? []));
      }
      emit(state.copyWith(status: FilterItemStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FilterItemStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreateLead(
    CreateLead event,
    Emitter<FilterItemState> emit,
  ) async {
    try {
      final response = await organizationRepository.createLead(
        event.organizationId,
        event.data,
      );
      final bool isSuccess = Helpers.isResponseSuccess(response.data);
      if (isSuccess) {
        emit(state.copyWith(status: FilterItemStatus.success));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FilterItemStatus.error,
        error: e.toString(),
      ));
    }
  }
}
