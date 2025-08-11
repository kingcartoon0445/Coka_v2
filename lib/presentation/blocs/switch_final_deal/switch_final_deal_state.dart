import 'package:equatable/equatable.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_tag_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_template_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/selected_product_item.dart';

enum SwitchFinalDealStatus { initial, loading, success,orderSuccess ,error }

class SwitchFinalDealState extends Equatable {
  final SwitchFinalDealStatus status;
  final String? error;
  final int? quantity;
  final String? note;

  final CustomerServiceModel? customerService;
  final List<CustomerPaging>? customers;
  final WorkspaceModel? selectWorkSpaceModel;
  final List<WorkspaceModel>? workSpaceModels;
  final CustomerPaging? selectedCustomer;
  final List<ProductModel>? products;
  // final List<? selectedProduct;
  final List<SelectedProductItem> selectedProducts;
  final List<BusinessProcessModel>? businessProcess;
  final BusinessProcessModel? selectBusinessProcess;
  final List<BusinessProcessTemplateModel>? businessProcessTemplate;
  final BusinessProcessTemplateModel? selectBusinessProcessTemplate;
  final List<MemberModel>? selectedAssignees;
  final List<TagModel>? businessProcessTag;
  final List<TagModel>? selectedBusinessProcessTag;
  const SwitchFinalDealState(
      {this.status = SwitchFinalDealStatus.initial,
      this.quantity,
      this.note,
      this.customerService,
      this.selectWorkSpaceModel,
      this.workSpaceModels,
      this.error,
      this.customers = const [],
      this.selectedCustomer,
      this.products = const [],
      // this.selectedProduct,
      this.selectedProducts = const [],
      this.businessProcess = const [],
      this.selectBusinessProcess,
      this.businessProcessTemplate = const [],
      this.selectBusinessProcessTemplate,
      this.selectedAssignees = const [],
      this.businessProcessTag = const [],
      this.selectedBusinessProcessTag = const []});

  SwitchFinalDealState copyWith(
      {SwitchFinalDealStatus? status,
      String? error,
      bool isClean = false,
      int? quantity,
      String? note,
      CustomerServiceModel? customerService,
      List<WorkspaceModel>? workSpaceModel,
      WorkspaceModel? selectWorkSpaceModel,
      List<CustomerPaging>? customers,
      CustomerPaging? selectedCustomer,
      List<ProductModel>? products,
      // ProductModel? selectedProduct,
      List<SelectedProductItem>? selectedProducts,
      List<BusinessProcessModel>? businessProcess,
      BusinessProcessModel? selectBusinessProcess,
      List<BusinessProcessTemplateModel>? businessProcessTemplate,
      BusinessProcessTemplateModel? selectBusinessProcessTemplate,
      List<MemberModel>? selectedAssignees,
      List<TagModel>? businessProcessTag,
      List<TagModel>? selectedBusinessProcessTag}) {
    return SwitchFinalDealState(
        status: status ?? this.status,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
        customerService: customerService ?? this.customerService,
        selectWorkSpaceModel: isClean
            ? selectWorkSpaceModel
            : selectWorkSpaceModel ?? this.selectWorkSpaceModel,
        workSpaceModels: workSpaceModel ?? workSpaceModels,
        error: error ?? this.error,
        customers: customers ?? this.customers,
        selectedCustomer: isClean
            ? selectedCustomer
            : selectedCustomer ?? this.selectedCustomer,
        products: products ?? this.products,
        // selectedProduct:
        //     isClean ? selectedProduct : selectedProduct ?? this.selectedProduct,
        selectedProducts: selectedProducts ?? this.selectedProducts,
        businessProcess: businessProcess ?? this.businessProcess,
        selectBusinessProcess: isClean
            ? selectBusinessProcess
            : selectBusinessProcess ?? this.selectBusinessProcess,
        businessProcessTemplate:
            businessProcessTemplate ?? this.businessProcessTemplate,
        selectBusinessProcessTemplate: isClean
            ? selectBusinessProcessTemplate
            : selectBusinessProcessTemplate ??
                this.selectBusinessProcessTemplate,
        selectedAssignees: selectedAssignees ?? this.selectedAssignees,
        businessProcessTag: businessProcessTag ?? this.businessProcessTag,
        selectedBusinessProcessTag:
            selectedBusinessProcessTag ?? this.selectedBusinessProcessTag);
  }

  @override
  List<Object?> get props => [
        status,
        error,
        quantity,
        note,
        customerService,
        selectWorkSpaceModel,
        selectedCustomer,
        workSpaceModels,
        customers,
        products,
        // selectedProduct,
        selectedProducts,
        businessProcess,
        selectBusinessProcess,
        businessProcessTemplate,
        selectBusinessProcessTemplate,
        selectedAssignees,
        businessProcessTag,
        selectedBusinessProcessTag
      ];
}
