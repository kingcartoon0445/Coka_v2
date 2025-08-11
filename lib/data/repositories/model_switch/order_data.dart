class OrderData {
  final String id;
  final String workspaceId;
  final String customerId;
  final String actor;
  final double totalPrice;
  final List<OrderDetailData> orderDetails;

  OrderData({
    required this.id,
    required this.workspaceId,
    required this.customerId,
    required this.actor,
    required this.totalPrice,
    required this.orderDetails,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] ?? '',
      workspaceId: json['workspaceId'] ?? '',
      customerId: json['customerId'] ?? '',
      actor: json['actor'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      orderDetails: (json['orderDetails'] as List<dynamic>? ?? [])
          .map((e) => OrderDetailData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'workspaceId': workspaceId,
      'customerId': customerId,
      'actor': actor,
      'totalPrice': totalPrice,
      'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    };
    data.removeWhere((key, value) => value == "");
    return data;
  }
}

class OrderDetailData {
  final String productId;
  final int quantity;
  final num unitPrice;

  OrderDetailData({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    return OrderDetailData(
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
