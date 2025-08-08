import 'package:equatable/equatable.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';

enum SwitchFinalDealStatus { initial, loading, success, error }

class SwitchFinalDealState extends Equatable {
  final SwitchFinalDealStatus status;
  final String? error;
  final List<CustomerPaging>? customers;
  final WorkspaceModel? selectWorkSpaceModel;
  final List<WorkspaceModel>? workSpaceModels;
  final CustomerPaging? selectedCustomer;
  final List<ProductModel>? products;
  final ProductModel? selectedProduct;
  const SwitchFinalDealState({
    this.status = SwitchFinalDealStatus.initial,
    this.selectWorkSpaceModel,
    this.workSpaceModels,
    this.error,
    this.customers = const [],
    this.selectedCustomer,
    this.products = const [],
    this.selectedProduct,
  });

  SwitchFinalDealState copyWith({
    SwitchFinalDealStatus? status,
    String? error,
    List<WorkspaceModel>? workSpaceModel,
    WorkspaceModel? selectWorkSpaceModel,
    List<CustomerPaging>? customers,
    CustomerPaging? selectedCustomer,
    List<ProductModel>? products,
    ProductModel? selectedProduct,
  }) {
    return SwitchFinalDealState(
      status: status ?? this.status,
      selectWorkSpaceModel: selectWorkSpaceModel ?? this.selectWorkSpaceModel,
      workSpaceModels: workSpaceModel ?? this.workSpaceModels,
      error: error ?? this.error,
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        selectWorkSpaceModel,
        selectedCustomer,
        workSpaceModels,
        customers,
        products,
        selectedProduct,
      ];
}
