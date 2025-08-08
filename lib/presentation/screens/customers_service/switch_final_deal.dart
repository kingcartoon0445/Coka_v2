import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';

import '../../blocs/switch_final_deal/switch_final_deal_action.dart';
import '../shared/widgets/chip_input.dart';
import '../shared/widgets/product_selection_bottom_sheet.dart';

class SwitchFinalDeal extends StatefulWidget {
  const SwitchFinalDeal({super.key});

  @override
  State<SwitchFinalDeal> createState() => _SwitchFinalDealState();
}

class _SwitchFinalDealState extends State<SwitchFinalDeal> {
  final TextEditingController _customerNameController =
      TextEditingController(text: 'Luu Thanh Long');
  final TextEditingController _transactionTitleController =
      TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _transactionValueController =
      TextEditingController();
  static final _inputDecoration = InputDecoration(
    hintText: 'all'.tr(),
    suffixIcon:
        const Icon(Icons.keyboard_arrow_down, color: AppColors.text, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
    ),
  );
  String _selectedPersonInCharge = '1 thành viên';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<SwitchFinalDealBloc>().add(SwitchFinalDealInitialized(
        organizationId:
            context.read<OrganizationBloc>().state.organizationId ?? ''));
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _transactionTitleController.dispose();
    _productController.dispose();
    _transactionValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchFinalDealBloc, SwitchFinalDealState>(
        builder: (context, state) {
      List<CustomerPaging> customers = state.customers ?? [];
      CustomerPaging? customerPaging = state.selectedCustomer;
      List<WorkspaceModel> listWorkSpace = state.workSpaceModels ?? [];
      WorkspaceModel? workSpaceModel = state.selectWorkSpaceModel;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Chuyển sang chốt khách'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context
                    .read<SwitchFinalDealBloc>()
                    .add(ConfirmSwitchFinalDeal());
              },
              icon: const Icon(Icons.check, color: AppColors.primary),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên khách hàng
              _buildLabel('Tên khách hàng'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _customerNameController,
                hintText: 'Nhập tên khách hàng',
              ),
              const SizedBox(height: 20),

              // Tiêu đề giao dịch
              _buildLabel('Tiêu đề giao dịch', isRequired: true),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _transactionTitleController,
                hintText: 'Nhập tiêu đề',
              ),
              const SizedBox(height: 20),

              // Tổ chức
              _buildLabel('Tổ chức'),
              const SizedBox(height: 8),
              ChipsInput<CustomerPaging>(
                initialValue: customerPaging == null ? [] : [customerPaging],
                allowInputText: false,
                suggestions: customers,
                decoration: _inputDecoration,
                isOnlyOne: true,
                onChanged: (data) {
                  if (data.isNotEmpty) {
                    context
                        .read<SwitchFinalDealBloc>()
                        .add(SwicthSelected(customerPaging: data.last));
                  } else {
                    context
                        .read<SwitchFinalDealBloc>()
                        .add(const RemoveSelected(removeSelectCustomer: true));
                  }
                },
                chipBuilder: BuildChip,
                suggestionBuilder: (context, sta, source) =>
                    BuildSuggestion(context, sta, source, false),
              ),

              const SizedBox(height: 20),

              // Chọn không gian làm việc
              _buildLabel('Chọn không gian làm việc', isRequired: true),
              const SizedBox(height: 8),
              ChipsInput<WorkspaceModel>(
                initialValue: workSpaceModel == null ? [] : [workSpaceModel],
                allowInputText: false,
                suggestions: listWorkSpace,
                decoration: _inputDecoration,
                isOnlyOne: true,
                onChanged: (data) {
                  if (data.isNotEmpty) {
                    context
                        .read<SwitchFinalDealBloc>()
                        .add(SwicthSelected(workspaceModel: data.last));
                  } else {
                    context
                        .read<SwitchFinalDealBloc>()
                        .add(const RemoveSelected(removeSelectWork: true));
                  }
                },
                chipBuilder: BuildChip,
                suggestionBuilder: (context, sta, source) =>
                    BuildSuggestion(context, sta, source, false),
              ),
              const SizedBox(height: 20),

              // Sản phẩm
              _buildLabel('Sản phẩm'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _productController,
                hintText: 'Nhập sản phẩm',
              ),
              const SizedBox(height: 20),

              // Giá trị giao dịch
              _buildLabel('Giá trị giao dịch'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _transactionValueController,
                hintText: 'Nhập số tiền',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Chọn người phụ trách
              _buildLabel('Chọn người phụ trách'),
              const SizedBox(height: 8),
              _buildPersonInChargeField(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () {
          if (hintText == 'Nhập sản phẩm') {
            _showProductSelectionBottomSheet();
          }
        },
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: hintText == 'Nhập sản phẩm'
              ? const Icon(Icons.keyboard_arrow_down, color: Colors.grey)
              : null,
        ),
      ),
    );
  }

  void _showProductSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductSelectionBottomSheet(),
    ).then((selectedProducts) {
      if (selectedProducts != null && selectedProducts.isNotEmpty) {
        // Handle the selected products
        setState(() {
          // Update the product controller with the first product name
          _productController.text = selectedProducts.first.name;
        });
      }
    });
  }

  Widget buildSuggestionProduct(
    BuildContext context,
    ChipsInputState<ProductModel> state,
    ProductModel data,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        if (isSelected) {
          state.deleteChip(data);
        } else {
          state.selectSuggestion(data);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? const Color(0xFFF9FAFB) : Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.name,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
            Text(
              Helpers.formatCurrency(data.price),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInChargeField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(
            Icons.person,
            size: 20,
            color: Colors.grey,
          ),
        ),
        title: Text(
          _selectedPersonInCharge,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
        onTap: () {
          // Hiển thị dialog chọn người phụ trách
          _showPersonInChargeDialog();
        },
      ),
    );
  }

  void _showPersonInChargeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn người phụ trách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('1 thành viên'),
              onTap: () {
                setState(() {
                  _selectedPersonInCharge = '1 thành viên';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
