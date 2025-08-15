import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart'
    show BuildChip, ChipsInput, ChipsInputState;
import 'package:source_base/presentation/screens/shared/widgets/product_selection_item.dart';

import '../../../blocs/switch_final_deal/switch_final_deal_action.dart';

class ProductSelectionBottomSheet extends StatefulWidget {
  const ProductSelectionBottomSheet({super.key});

  @override
  State<ProductSelectionBottomSheet> createState() =>
      _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState
    extends State<ProductSelectionBottomSheet> {
  final TextEditingController _quantityController = TextEditingController();
  ProductModel? currentSelectedProduct;
  ChipsInputState<ProductModel>? sta;
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchFinalDealBloc, SwitchFinalDealState>(
        builder: (context, state) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chọn sản phẩm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.text),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Selection Section
                      _buildLabel('Chọn sản phẩm mới'),
                      const SizedBox(height: 8),
                      _buildProductSelectionField(state),
                      const SizedBox(height: 20),

                      // Quantity and Tax Section (only show if product is selected)
                      if (currentSelectedProduct != null) ...[
                        _buildProductDetailsSection(state),
                        const SizedBox(height: 20),
                        _buildAddProductButton(),
                        const SizedBox(height: 20),
                      ],

                      // Selected Products List
                      if (state.selectedProducts.isNotEmpty) ...[
                        _buildSelectedProductsList(state),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Tổng số tiền:\n${Helpers.formatCurrency(_calculateTotalAmount(state))}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: state.selectedProducts.isNotEmpty
                          ? () {
                              Navigator.pop(context, state.selectedProducts);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }

  static final _inputDecoration = InputDecoration(
    hintText: 'Chọn sản phẩm',
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

  Widget _buildProductSelectionField(SwitchFinalDealState state) {
    return ChipsInput<ProductModel>(
        initialValue: const [],
        allowInputText: false,
        suggestions: state.products ?? [],
        decoration: _inputDecoration,
        isOnlyOne: true,
        onChanged: (data) {
          if (data.isNotEmpty) {
            setState(() {
              currentSelectedProduct = data.last;
              _quantityController.text = '1';
            });
          } else {
            setState(() {
              currentSelectedProduct = null;
              _quantityController.clear();
            });
          }
        },
        chipBuilder: BuildChip,
        suggestionBuilder: (context, sta, data) {
          this.sta = sta;
          return InkWell(
            onTap: () {
              sta.selectSuggestion(data);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: false ? const Color(0xFFF9FAFB) : Colors.transparent,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: false ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  Text(
                    Helpers.formatCurrency(data.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: false ? AppColors.primary : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildProductDetailsSection(SwitchFinalDealState state) {
    if (currentSelectedProduct == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Giá:'),
            const SizedBox(width: 8),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(Helpers.formatCurrency(
                    currentSelectedProduct?.price ?? 0))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Số lượng'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Nhập số lượng",
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Thuế (%)'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(currentSelectedProduct?.tax.toString() ?? ''),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddProductButton() {
    if (currentSelectedProduct == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        if (quantity > 0) {
          context.read<SwitchFinalDealBloc>().add(
                AddProductToSelection(
                  product: currentSelectedProduct!,
                  quantity: quantity,
                ),
              );

          setState(() {
            sta?.deleteChip(currentSelectedProduct!);
            currentSelectedProduct = null;
            _quantityController.clear();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Thêm sản phẩm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProductsList(SwitchFinalDealState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm đã chọn:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        ...state.selectedProducts.reversed
            .map(
              (productItem) => ProductSelectionItem(
                productItem: productItem,
                onRemove: () {},
              ),
            )
            .toList(),
      ],
    );
  }

  double _calculateTotalAmount(SwitchFinalDealState state) {
    return state.selectedProducts.fold(
      0.0,
      (sum, productItem) => sum + productItem.totalWithTax,
    );
  }
}
