import 'dart:developer';

import 'package:source_base/config/helper.dart';
import 'package:source_base/data/repositories/final_deal_repository.dart';
import 'package:source_base/data/repositories/switch_final_deal_repository.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'models/customer_paging_response.dart';
import 'models/product_response.dart';
import 'switch_final_deal_action.dart';

class SwitchFinalDealBloc
    extends Bloc<SwitchFinalDealEvent, SwitchFinalDealState> {
  SwitchFinalDealBloc({required this.repository, required this.finalRepository})
      : super(const SwitchFinalDealState()) {
    on<SwitchFinalDealInitialized>(_onInitialized);
    on<SwicthSelected>(_onSwicthSelected);
    on<ConfirmSwitchFinalDeal>(_confirmSwitchFinalDeal);
    on<RemoveSelected>(_onRemoveSelected);
  }
  final SwitchFinalDealRepository repository;
  final FinalDealRepository finalRepository;
  void _onInitialized(SwitchFinalDealInitialized event,
      Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(status: SwitchFinalDealStatus.initial));

    final response = await repository.getListPaging(
        organizationId: event.organizationId,
        limit: 20,
        offset: 0,
        startDate: '',
        endDate: '',
        isBusiness: true,
        searchText: '');
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      CustomerPagingResponse customerPagingResponse =
          CustomerPagingResponse.fromJson(response.data);
      emit(state.copyWith(
          status: SwitchFinalDealStatus.success,
          customers: customerPagingResponse.content));
    }
    final responseWorkSpace =
        await finalRepository.getAllWorkspace(event.organizationId);
    if (isSuccess) {
      WorkspaceResponse workspaceResponse =
          WorkspaceResponse.fromJson(responseWorkSpace.data);
      emit(state.copyWith(
          status: SwitchFinalDealStatus.success,
          workSpaceModel: workspaceResponse.content));
    }

    final responseProduct =
        await repository.getProduct(event.organizationId, false);
    final bool isSuccessProduct =
        Helpers.isResponseSuccess(responseProduct.data);
    if (isSuccessProduct) {
      ProductResponse productResponse =
          ProductResponse.fromJson(responseProduct.data);
      emit(state.copyWith(
          status: SwitchFinalDealStatus.success,
          products: productResponse.data));
    }
  }

  void _onSwicthSelected(
      SwicthSelected event, Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(
        selectedCustomer: event.customerPaging,
        selectWorkSpaceModel: event.workspaceModel,
        selectedProduct: event.product));
  }

  void _confirmSwitchFinalDeal(
      ConfirmSwitchFinalDeal event, Emitter<SwitchFinalDealState> emit) async {
    log('confirmSwitchFinalDeal selectWorkSpaceModel: ${state.selectWorkSpaceModel?.name}');
    log('confirmSwitchFinalDeal selectedCustomer: ${state.selectedCustomer?.name}');
    // emit(state.copyWith(
    //     selectedCustomer: event.customerPaging,
    //     selectWorkSpaceModel: event.workspaceModel));
  }

  void _onRemoveSelected(
      RemoveSelected event, Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(
        selectedCustomer:
            event.removeSelectCustomer ? null : state.selectedCustomer,
        selectWorkSpaceModel:
            event.removeSelectWork ? null : state.selectWorkSpaceModel,
        selectedProduct:
            event.removeSelectProduct ? null : state.selectedProduct));
  }
}
