import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_template_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/selected_product_item.dart';

import 'models/business_process_tag_response.dart';
import 'models/customer_paging_response.dart';
import 'models/product_response.dart';

abstract class SwitchFinalDealEvent extends Equatable {
  const SwitchFinalDealEvent();

  @override
  List<Object?> get props => [];
}

class SwitchFinalDealInitialized extends SwitchFinalDealEvent {
  final String organizationId;
  const SwitchFinalDealInitialized({required this.organizationId});
}

class SwicthSelected extends SwitchFinalDealEvent {
  final CustomerPaging? customerPaging;
  final WorkspaceModel? workspaceModel;
  final List<SelectedProductItem>? products;
  final BusinessProcessTemplateModel? businessProcessTemplate;
  final String organizationId;
  final List<MemberModel>? assignees;
  final List<TagModel>? businessProcessTag;
  final BusinessProcessModel? businessProcess;
  const SwicthSelected(
      {required this.organizationId,
      this.customerPaging,
      this.workspaceModel,
      this.products,
      this.businessProcessTemplate,
      this.assignees,
      this.businessProcessTag,
      this.businessProcess});
}

class AddProductToSelection extends SwitchFinalDealEvent {
  final ProductModel product;
  final int quantity;
  const AddProductToSelection({
    required this.product,
    required this.quantity,
  });
}

class UpdateProductQuantity extends SwitchFinalDealEvent {
  final String productId;
  final int quantity;
  const UpdateProductQuantity({
    required this.productId,
    required this.quantity,
  });
}

class RemoveProductFromSelection extends SwitchFinalDealEvent {
  final String productId;
  const RemoveProductFromSelection({
    required this.productId,
  });
}

class GetBusinessProcess extends SwitchFinalDealEvent {
  final String organizationId;
  final String workspaceId;
  const GetBusinessProcess(
      {required this.organizationId, required this.workspaceId});
}

class ConfirmSwitchFinalDeal extends SwitchFinalDealEvent {
  final String organizationId;
  final String stageId;
  final String title;
  final String transactionValue;
  const ConfirmSwitchFinalDeal(
      {required this.organizationId,
      required this.stageId,
      required this.title,
      required this.transactionValue});
}

class LoadCustomer extends SwitchFinalDealEvent {
  final CustomerServiceModel customerService;
  const LoadCustomer({required this.customerService});
}

class RemoveSelected extends SwitchFinalDealEvent {
  final bool removeSelectCustomer;
  final bool removeSelectWork;
  final bool removeSelectProduct;
  final bool removeSelectBusinessProcessTemplate;
  final bool removeSelectBusinessProcessTag;
  const RemoveSelected(
      {this.removeSelectCustomer = false,
      this.removeSelectWork = false,
      this.removeSelectProduct = false,
      this.removeSelectBusinessProcessTemplate = false,
      this.removeSelectBusinessProcessTag = false});
}

class QuantityChanged extends SwitchFinalDealEvent {
  final int quantity;
  const QuantityChanged({required this.quantity});
}

class ClearSelected extends SwitchFinalDealEvent {}

class AddBusinessProcessTag extends SwitchFinalDealEvent {
  final String organizationId;
  final String name;
  final String backgroundColor;
  final String textColor;
  final String workspaceId;
  const AddBusinessProcessTag(
      {required this.organizationId,
      required this.name,
      required this.backgroundColor,
      required this.textColor,
      required this.workspaceId});
}

class NoteChanged extends SwitchFinalDealEvent {
  final String note;
  const NoteChanged({required this.note});
}
