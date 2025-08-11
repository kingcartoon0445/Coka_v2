import 'product_response.dart';

class SelectedProductItem {
  final ProductModel product;
  final int quantity;
  final double totalPrice;
  final double taxAmount;

  SelectedProductItem({
    required this.product,
    required this.quantity,
    required this.totalPrice,
    required this.taxAmount,
  });

  double get totalWithTax => totalPrice + taxAmount;

  double get taxAmountCalculated => totalPrice * (product.tax / 100);

  SelectedProductItem copyWith({
    ProductModel? product,
    int? quantity,
    double? totalPrice,
    double? taxAmount,
  }) {
    return SelectedProductItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  factory SelectedProductItem.fromProduct(ProductModel product, int quantity) {
    final totalPrice = product.price * quantity;

    return SelectedProductItem(
      product: product,
      quantity: quantity,
      totalPrice: totalPrice.toDouble(),
      taxAmount: 0, // Không tính thuế
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedProductItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id;

  @override
  int get hashCode => product.id.hashCode;

  @override
  String toString() {
    return 'SelectedProductItem{product: ${product.name}, quantity: $quantity, totalPrice: $totalPrice, taxAmount: $taxAmount}';
  }
}
