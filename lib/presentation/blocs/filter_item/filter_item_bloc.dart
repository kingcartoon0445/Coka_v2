import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/data/models/utm_member_response.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';

import 'filter_item_event.dart';
import 'filter_item_state.dart';

class FilterItemBloc extends Bloc<FilterItemEvent, FilterItemState> {
  final OrganizationRepository organizationRepository;

  FilterItemBloc({required this.organizationRepository})
      : super(const FilterItemState()) {
    on<LoadFilterItem>(_onLoadFilterItem);
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

      emit(state.copyWith(status: FilterItemStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FilterItemStatus.error,
        error: e.toString(),
      ));
    }
  }
}
