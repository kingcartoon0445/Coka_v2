import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';

class SelectedProduct {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final double tax;

  SelectedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.tax,
  });
}

class ProductSelectionBottomSheet extends StatefulWidget {
  const ProductSelectionBottomSheet({super.key});

  @override
  State<ProductSelectionBottomSheet> createState() =>
      _ProductSelectionBottomSheetState();
}

class _ProductSelectionBottomSheetState
    extends State<ProductSelectionBottomSheet> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  List<SelectedProduct> selectedProducts = [];
  double totalAmount = 0.0;
  bool showSuggestions = false;
  List<String> suggestions = ['Căn 2PN', 'Căn 3PN'];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'Sản phẩm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                  // Product Name Section
                  _buildLabel('Tên sản phẩm'),
                  const SizedBox(height: 8),
                  _buildProductNameField(),
                  if (showSuggestions) ...[
                    const SizedBox(height: 8),
                    _buildSuggestions(),
                    const SizedBox(height: 8),
                    _buildAddNewProductLink(),
                  ],
                  const SizedBox(height: 20),

                  // Product Details Section
                  _buildProductDetailsSection(),
                  const SizedBox(height: 16),
                  _buildAddProductButton(),
                  const SizedBox(height: 20),

                  // Selected Products List
                  if (selectedProducts.isNotEmpty) ...[
                    _buildSelectedProductsList(),
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
                    const Icon(Icons.attach_money, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tổng số tiền : ${totalAmount.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle confirmation
                    Navigator.pop(context, selectedProducts);
                  },
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
    );
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

  Widget _buildProductNameField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _productNameController,
        onChanged: (value) {
          setState(() {
            showSuggestions = value.isNotEmpty;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Nhập tên',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: suggestions
            .map(
              (suggestion) => ListTile(
                title: Text(suggestion),
                onTap: () {
                  _productNameController.text = suggestion;
                  setState(() {
                    showSuggestions = false;
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAddNewProductLink() {
    return GestureDetector(
      onTap: () {
        // Handle adding new product
      },
      child: Row(
        children: [
          const Icon(Icons.add, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            'Thêm "${_productNameController.text}" thành Sản phẩm mới',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Giá (đ)'),
              const SizedBox(height: 8),
              _buildInputField(_priceController, 'Nhập giá'),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Số lượng'),
              const SizedBox(height: 8),
              _buildInputField(_quantityController, 'Nhập số lượng'),
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
              _buildInputField(_taxController, 'Nhập thuế'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return GestureDetector(
      onTap: _addProduct,
      child: Row(
        children: [
          const Icon(Icons.add, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          const Text(
            'Thêm sản phẩm',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedProductsList() {
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
        const SizedBox(height: 8),
        ...selectedProducts
            .map(
              (product) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                                 Text(
                         product.name,
                         style: const TextStyle(
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                       Text(
                         '${product.price}đ x ${product.quantity}',
                         style: TextStyle(
                           color: Colors.grey.shade600,
                           fontSize: 12,
                         ),
                       ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeProduct(product),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

    void _addProduct() {
    if (_productNameController.text.isNotEmpty) {
      final product = SelectedProduct(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _productNameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        tax: double.tryParse(_taxController.text) ?? 0.0,
      );
      
      setState(() {
        selectedProducts.add(product);
        _calculateTotal();
      });
      
      // Clear inputs
      _productNameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _taxController.clear();
    }
  }

  void _removeProduct(SelectedProduct product) {
    setState(() {
      selectedProducts.remove(product);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    totalAmount = selectedProducts.fold(0.0, (sum, product) {
      final price = product.price;
      final quantity = product.quantity;
      final tax = product.tax;
      final subtotal = price * quantity;
      final taxAmount = subtotal * (tax / 100);
      return sum + subtotal + taxAmount;
    });
  }
}
