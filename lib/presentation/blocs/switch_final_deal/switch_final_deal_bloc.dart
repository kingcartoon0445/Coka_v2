import 'dart:developer';

import 'package:source_base/config/helper.dart';
import 'package:source_base/data/repositories/final_deal_repository.dart';
import 'package:source_base/data/repositories/model_switch/business_process_data.dart';
import 'package:source_base/data/repositories/model_switch/order_data.dart';
import 'package:source_base/data/repositories/switch_final_deal_repository.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_template_response.dart';
import 'models/business_process_tag_response.dart';
import 'models/customer_paging_response.dart';
import 'models/product_response.dart';
import 'models/selected_product_item.dart';
import 'switch_final_deal_action.dart';

class SwitchFinalDealBloc
    extends Bloc<SwitchFinalDealEvent, SwitchFinalDealState> {
  SwitchFinalDealBloc({required this.repository, required this.finalRepository})
      : super(const SwitchFinalDealState()) {
    on<SwitchFinalDealInitialized>(_onInitialized);
    on<SwicthSelected>(_onSwicthSelected);
    on<ConfirmSwitchFinalDeal>(_confirmSwitchFinalDeal);
    on<GetBusinessProcess>(_onGetBusinessProcess);
    on<RemoveSelected>(_onRemoveSelected);
    on<ClearSelected>(_onClearSelected);
    on<QuantityChanged>(_onQuantityChanged);
    on<NoteChanged>(_onNoteChanged);
    on<LoadCustomer>(_onLoadCustomerService);
    on<AddProductToSelection>(_onAddProductToSelection);
    on<UpdateProductQuantity>(_onUpdateProductQuantity);
    on<RemoveProductFromSelection>(_onRemoveProductFromSelection);
    on<AddBusinessProcessTag>(_onAddBusinessProcessTag);
    on<GetProduct>(_onGetProduct);
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
    add(GetProduct(organizationId: event.organizationId));
  }

  void _onGetProduct(
      GetProduct event, Emitter<SwitchFinalDealState> emit) async {
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

  void _onLoadCustomerService(
      LoadCustomer event, Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(customerService: event.customerService));
  }

  void _onSwicthSelected(
         event, Emitter<SwitchFinalDealState> emit) async {
    if (event.workspaceModel != null) {
      add(GetBusinessProcess(
          organizationId: event.organizationId,
          workspaceId: event.workspaceModel!.id));
    }
    emit(state.copyWith(
        selectedCustomer: event.customerPaging,
        selectWorkSpaceModel: event.workspaceModel,
        selectedProducts: event.products,
        selectBusinessProcessTemplate: event.businessProcessTemplate,
        selectedAssignees: event.assignees,
        selectedBusinessProcessTag: event.businessProcessTag,
        selectBusinessProcess: event.businessProcess));
  }

  void _onGetBusinessProcess(
      GetBusinessProcess event, Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(status: SwitchFinalDealStatus.loading));
    final response = await finalRepository.getBusinessProcess(
        event.organizationId, event.workspaceId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      BusinessProcessResponse businessProcessResponse =
          BusinessProcessResponse.fromJson(response.data);
      log('businessProcessResponse: ${businessProcessResponse.data}');
      if (businessProcessResponse.data == null ||
          businessProcessResponse.data!.isEmpty) {
        final response = await repository.getBusinessProcessTemplate();
        final bool isSuccessTemplate = Helpers.isResponseSuccess(response.data);
        if (isSuccessTemplate) {
          BusinessProcessTemplateResponse businessProcessTemplateResponse =
              BusinessProcessTemplateResponse.fromJson(response.data);
          emit(state.copyWith(
              status: SwitchFinalDealStatus.success,
              businessProcessTemplate: businessProcessTemplateResponse.data,
              selectBusinessProcessTemplate:
                  businessProcessTemplateResponse.data?.first));
        }
      }
      emit(state.copyWith(
          status: SwitchFinalDealStatus.success,
          businessProcess: businessProcessResponse.data));
    }

    final responseTag = await repository.getBusinessProcessTag(
        event.organizationId, event.workspaceId);
    final bool isSuccessTag = Helpers.isResponseSuccess(responseTag.data);
    if (isSuccessTag) {
      TagResponse businessProcessTagResponse =
          TagResponse.fromJson(responseTag.data);
      emit(state.copyWith(
          status: SwitchFinalDealStatus.success,
          businessProcessTag: businessProcessTagResponse.data));
    }
  }

  void _confirmSwitchFinalDeal(
      ConfirmSwitchFinalDeal event, Emitter<SwitchFinalDealState> emit) async {
    log('confirmSwitchFinalDeal selectWorkSpaceModel: ${state.selectWorkSpaceModel?.name}');
    log('confirmSwitchFinalDeal selectedCustomer: ${state.selectedCustomer?.name}');
    log('confirmSwitchFinalDeal selectedAssignees: ${state.selectedAssignees}');
    // log('confirmSwitchFinalDeal selectedProduct: ${state.selectedProduct?.name}');
    log('confirmSwitchFinalDeal selectedBusinessProcessTemplate: ${state.selectBusinessProcessTemplate?.name}');
    log('confirmSwitchFinalDeal selectedBusinessProcess: ${state.selectBusinessProcess?.name}');
    log('confirmSwitchFinalDeal selectedWorkSpaceModel: ${state.selectWorkSpaceModel?.name}');
    log('confirmSwitchFinalDeal selectedCustomer: ${state.selectedCustomer?.name}');
    log('confirmSwitchFinalDeal selectedBusinessProcessTag: ${state.selectedBusinessProcessTag}');
    log('confirmSwitchFinalDeal selectedProducts: ${state.selectedProducts}');
    TaskData taskData = TaskData(
      subTasks: [],
      priority: '',
      notes: state.note ?? '',
      assignedTo:
          state.selectedAssignees?.map((e) => e.id ?? '').toList() ?? [],
      tagIds: state.selectedBusinessProcessTag?.map((e) => e.id).toList() ?? [],
      workspaceId: state.selectWorkSpaceModel?.id ?? '',
      stageId: state.selectBusinessProcess?.id ?? '',
      name: event.title,
      username: state.selectedCustomer?.name ?? '',
      email: state.selectedCustomer?.email ?? '',
      phone: state.selectedCustomer?.phone ?? '',
      description: state.note ?? '',
      customerId: state.selectedCustomer?.id ?? '',
    );

    final response = await repository.postBusinessProcessTask(
        event.organizationId, taskData);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      OrderData orderData = OrderData(
        id: '',
        workspaceId: state.selectWorkSpaceModel?.id ?? '',
        customerId: state.selectedCustomer?.id ?? '',
        actor: state.selectedAssignees?.first.id ?? '',
        totalPrice: state.selectedProducts
            .fold(0.0, (sum, product) => sum + product.totalPrice),
        orderDetails: state.selectedProducts
            .map((e) => OrderDetailData(
                  productId: e.product.id,
                  quantity: e.quantity,
                  unitPrice: e.product.price,
                ))
            .toList(),
      );

      final responseOrder =
          await repository.postOrder(event.organizationId, orderData);
      final bool isSuccessOrder = Helpers.isResponseSuccess(responseOrder.data);
      if (isSuccessOrder) {
        final responseLinkOrder = await repository.linkOrder(
            event.organizationId,
            response.data['data']['id'],
            responseOrder.data['data']['orderId']);
        final bool isSuccessLinkOrder =
            Helpers.isResponseSuccess(responseLinkOrder.data);
        if (isSuccessLinkOrder) {
          emit(state.copyWith(status: SwitchFinalDealStatus.orderSuccess));
        } else {
          emit(state.copyWith(status: SwitchFinalDealStatus.error));
        }
      } else {
        emit(state.copyWith(status: SwitchFinalDealStatus.error));
      }
    } else {
      emit(state.copyWith(status: SwitchFinalDealStatus.error));
    }
    // emit(state.copyWith(
    //     selectedCustomer: event.customerPaging,
    //     selectWorkSpaceModel: event.workspaceModel));
  }

  void _onRemoveSelected(
      RemoveSelected event, Emitter<SwitchFinalDealState> emit) async {
    WorkspaceModel? w =
        event.removeSelectWork ? null : state.selectWorkSpaceModel;
    emit(state.copyWith(
        isClean: true,
        selectedCustomer:
            event.removeSelectCustomer ? null : state.selectedCustomer,
        selectWorkSpaceModel: w,
        selectedBusinessProcessTag: event.removeSelectBusinessProcessTag
            ? null
            : state.selectedBusinessProcessTag,
        selectedProducts:
            event.removeSelectProduct ? null : state.selectedProducts,
        selectBusinessProcessTemplate: event.removeSelectBusinessProcessTemplate
            ? null
            : state.selectBusinessProcessTemplate));
  }

  void _onClearSelected(
      ClearSelected event, Emitter<SwitchFinalDealState> emit) async {
    emit(const SwitchFinalDealState());
  }

  void _onQuantityChanged(
      QuantityChanged event, Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(quantity: event.quantity));
  }

  void _onNoteChanged(
      NoteChanged event, Emitter<SwitchFinalDealState> emit) async {
    emit(state.copyWith(note: event.note));
  }

  void _onAddProductToSelection(
      AddProductToSelection event, Emitter<SwitchFinalDealState> emit) async {
    final newProductItem = SelectedProductItem.fromProduct(
      event.product,
      event.quantity,
    );

    final existingIndex = state.selectedProducts.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    List<SelectedProductItem> updatedProducts;
    if (existingIndex != -1) {
      updatedProducts = List.from(state.selectedProducts);
      updatedProducts[existingIndex] = newProductItem;
    } else {
      updatedProducts = [...state.selectedProducts, newProductItem];
    }

    emit(state.copyWith(selectedProducts: updatedProducts));
  }

  void _onUpdateProductQuantity(
      UpdateProductQuantity event, Emitter<SwitchFinalDealState> emit) async {
    List<SelectedProductItem> updatedProducts = [];

    for (var item in state.selectedProducts) {
      if (item.product.id == event.productId) {
        SelectedProductItem itemUpdate =
            SelectedProductItem.fromProduct(item.product, event.quantity);
        updatedProducts.add(itemUpdate);
      } else {
        updatedProducts.add(item);
      }
    }
    emit(state.copyWith(selectedProducts: []));

    emit(state.copyWith(selectedProducts: updatedProducts));
  }

  void _onRemoveProductFromSelection(RemoveProductFromSelection event,
      Emitter<SwitchFinalDealState> emit) async {
    final updatedProducts = state.selectedProducts
        .where((item) => item.product.id != event.productId)
        .toList();

    emit(state.copyWith(selectedProducts: updatedProducts));
  }

  void _onAddBusinessProcessTag(
      AddBusinessProcessTag event, Emitter<SwitchFinalDealState> emit) async {
    final response = await repository.postBusinessProcessTag(
        event.organizationId,
        event.name,
        event.backgroundColor,
        event.textColor,
        event.workspaceId);
    final bool isSuccess = Helpers.isResponseSuccess(response.data);
    if (isSuccess) {
      TagModel tagModelAdd = TagModel.fromJson(response.data['data']);

      emit(state.copyWith(
          status: SwitchFinalDealStatus.success,
          businessProcessTag: [...state.businessProcessTag!, tagModelAdd]));
    } else {
      emit(state.copyWith(status: SwitchFinalDealStatus.error));
    }
  }
}
