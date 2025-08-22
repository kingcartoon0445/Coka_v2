import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart'
    show BuildChip, ChipsInput, ChipsInputState;

/// A bloc-agnostic bottom sheet for selecting products.
///
/// Pass data in via constructor — no Bloc access inside.
/// Works with ANY state management solution.
class ProductSelectionBottomSheet extends StatefulWidget {
  /// All products available for selection (suggestions)
  final List<ProductModel> products;

  /// Optional preselected items
  final List<SelectedProduct> initialSelected;

  /// Called when the internal selected list changes (add/remove)
  final ValueChanged<List<SelectedProduct>>? onChanged;

  /// Called when a single product is added (useful if caller wants per-add side effects)
  final ValueChanged<SelectedProduct>? onAddProduct;

  const ProductSelectionBottomSheet({
    super.key,
    required this.products,
    this.initialSelected = const [],
    this.onChanged,
    this.onAddProduct,
  });

  @override
  State<ProductSelectionBottomSheet> createState() =>
      _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState
    extends State<ProductSelectionBottomSheet> {
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final FocusNode _qtyFocus = FocusNode();

  ChipsInputState<ProductModel>? _chipsState;
  ProductModel? _currentSelectedProduct;
  late List<SelectedProduct> _selected; // mutable working copy

  @override
  void initState() {
    super.initState();
    _selected = List<SelectedProduct>.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Chọn sản phẩm mới'),
                      const SizedBox(height: 8),
                      _buildProductSelectionField(),
                      const SizedBox(height: 20),
                      if (_currentSelectedProduct != null) ...[
                        _buildProductDetailsSection(),
                        const SizedBox(height: 20),
                        _buildAddProductButton(),
                        const SizedBox(height: 20),
                      ],
                      if (_selected.isNotEmpty) ...[
                        _buildSelectedProductsList(),
                        const SizedBox(height: 20),
                      ],
                    ]),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ------------------- Header / Footer -------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Chọn sản phẩm',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text)),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.text)),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Icon(Icons.attach_money, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Tổng số tiền:\n${Helpers.formatCurrency(_calculateTotalAmount())}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
          ]),
          ElevatedButton(
            onPressed: _selected.isNotEmpty
                ? () => Navigator.pop(context, _selected)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ------------------- Building blocks -------------------
  Widget _buildLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text));

  InputDecoration get _inputDecoration => InputDecoration(
        hintText: 'Chọn sản phẩm',
        suffixIcon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.text, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
      );

  Widget _buildProductSelectionField() {
    return ChipsInput<ProductModel>(
      initialValue: const [],
      allowInputText: false,
      suggestions: widget.products,
      decoration: _inputDecoration,
      isOnlyOne: true,
      onChanged: (data) {
        if (data.isNotEmpty) {
          setState(() {
            _currentSelectedProduct = data.last;
            _quantityController.text = '1';
            _qtyFocus.requestFocus();
          });
        } else {
          setState(() {
            _currentSelectedProduct = null;
            _quantityController.clear();
          });
        }
      },
      chipBuilder: BuildChip,
      suggestionBuilder: (context, sta, product) {
        _chipsState = sta;
        return InkWell(
          onTap: () => sta.selectSuggestion(product),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.centerLeft,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name,
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.text)),
                  Text(Helpers.formatCurrency(product.price),
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.text)),
                ]),
          ),
        );
      },
    );
  }

  Widget _buildProductDetailsSection() {
    final p = _currentSelectedProduct!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _buildLabel('Giá:'),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8)),
          child: Text(Helpers.formatCurrency(p.price)),
        ),
      ]),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel('Số lượng'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                focusNode: _qtyFocus,
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    hintText: 'Nhập số lượng',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel('Thuế (%)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8)),
              child: Text((p.tax ?? 0).toString()),
            ),
          ]),
        ),
      ]),
    ]);
  }

  Widget _buildAddProductButton() {
    final p = _currentSelectedProduct;
    if (p == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        if (quantity <= 0) return;

        final item = SelectedProduct(product: p, quantity: quantity);
        setState(() {
          _selected.add(item);
          widget.onChanged?.call(List.unmodifiable(_selected));
          widget.onAddProduct?.call(item);

          _chipsState?.deleteChip(p);
          _currentSelectedProduct = null;
          _quantityController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child:
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Thêm sản phẩm',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildSelectedProductsList() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sản phẩm đã chọn:',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text)),
      const SizedBox(height: 12),
      for (final item in _selected.reversed)
        _SelectedProductTile(
          key: ValueKey(
              '${item.product.id}_${item.quantity}_${item.product.price}_${item.product.tax}'),
          item: item,
          onRemove: () => setState(() {
            _selected.remove(item);
            widget.onChanged?.call(List.unmodifiable(_selected));
          }),
        ),
    ]);
  }

  double _calculateTotalAmount() {
    return _selected.fold(0.0, (sum, item) => sum + item.totalWithTax);
  }
}

// ------------------- Models & Tiles -------------------
class SelectedProduct {
  final ProductModel product;
  int quantity;

  SelectedProduct({required this.product, required this.quantity});

  double get unitPrice =>
      (product.price is num) ? (product.price as num).toDouble() : 0.0;
  double get taxPercent =>
      (product.tax is num) ? (product.tax as num).toDouble() : 0.0;

  double get total => unitPrice * quantity;
  double get totalWithTax => total * (1 + taxPercent / 100);
}

class _SelectedProductTile extends StatelessWidget {
  final SelectedProduct item;
  final VoidCallback onRemove;
  const _SelectedProductTile(
      {super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text)),
              const SizedBox(height: 4),
              Text(
                  'x${item.quantity} · ${Helpers.formatCurrency(item.unitPrice)} · Thuế ${item.taxPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(Helpers.formatCurrency(item.totalWithTax),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            const SizedBox(height: 4),
            Text('Trước thuế: ${Helpers.formatCurrency(item.total)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ]),
          IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent))
        ],
      ),
    );
  }
}
