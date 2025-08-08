import 'package:equatable/equatable.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';

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
  final ProductModel? product;
  const SwicthSelected(
      {this.customerPaging, this.workspaceModel, this.product});
}

class ConfirmSwitchFinalDeal extends SwitchFinalDealEvent {}

class RemoveSelected extends SwitchFinalDealEvent {
  final bool removeSelectCustomer;
  final bool removeSelectWork;
  final bool removeSelectProduct;
  const RemoveSelected(
      {this.removeSelectCustomer = false,
      this.removeSelectWork = false,
      this.removeSelectProduct = false});
}
