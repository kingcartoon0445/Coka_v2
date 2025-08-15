class CustomerOrderApiResponse {
  final bool? success;
  final String? message;
  final CustomerOrderDataModel? data;
  final dynamic
      pagination; // nếu pagination có cấu trúc thì thay dynamic bằng model

  CustomerOrderApiResponse({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory CustomerOrderApiResponse.fromJson(Map<String, dynamic> json) {
    return CustomerOrderApiResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? CustomerOrderDataModel.fromJson(json['data'])
          : null,
      pagination: json['pagination'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (success != null) 'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data!.toJson(),
      if (pagination != null) 'pagination': pagination,
    };
  }
}

class CustomerOrderDataModel {
  final String? id;
  final String? customerId;
  final num? totalPrice;
  final List<CustomerOrderDetailModel> orderDetails;

  CustomerOrderDataModel({
    this.id,
    this.customerId,
    this.totalPrice,
    this.orderDetails = const [],
  });

  factory CustomerOrderDataModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderDataModel(
      id: json['id'] as String?,
      customerId: json['customerId'] as String?,
      totalPrice: json['totalPrice'] as num?,
      orderDetails: (json['orderDetails'] is List)
          ? (json['orderDetails'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? CustomerOrderDetailModel.fromJson(e)
                  : CustomerOrderDetailModel())
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (customerId != null) 'customerId': customerId,
      if (totalPrice != null) 'totalPrice': totalPrice,
      'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerOrderDetailModel {
  final String? id;
  final String? productId;
  final num? quantity;
  final CustomerOrderProductModel? product;

  CustomerOrderDetailModel({
    this.id,
    this.productId,
    this.quantity,
    this.product,
  });

  factory CustomerOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderDetailModel(
      id: json['id'] as String?,
      productId: json['productId'] as String?,
      quantity: json['quantity'] as num?,
      product: json['product'] is Map<String, dynamic>
          ? CustomerOrderProductModel.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'productId': productId,
      if (quantity != null) 'quantity': quantity,
      if (product != null) 'product': product!.toJson(),
    };
  }
}

class CustomerOrderProductModel {
  final String? name;
  final num? price;
  final String? description;
  final String? image;
  final num? status;
  final num? tax;
  final String? categoryId;
  final String? code;
  final List<dynamic> categories;
  final List<dynamic> categoryIds;
  final String? id;
  final String? organizationId;
  final DateTime? createdDate;
  final String? createdBy;
  final DateTime? updatedDate;
  final String? updatedBy;

  CustomerOrderProductModel({
    this.name,
    this.price,
    this.description,
    this.image,
    this.status,
    this.tax,
    this.categoryId,
    this.code,
    this.categories = const [],
    this.categoryIds = const [],
    this.id,
    this.organizationId,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
  });

  factory CustomerOrderProductModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return CustomerOrderProductModel(
      name: json['name'] as String?,
      price: json['price'] as num?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      status: json['status'] as num?,
      tax: json['tax'] as num?,
      categoryId: json['categoryId'] as String?,
      code: json['code'] as String?,
      categories:
          (json['categories'] is List) ? (json['categories'] as List) : [],
      categoryIds:
          (json['categoryIds'] is List) ? (json['categoryIds'] as List) : [],
      id: json['id'] as String?,
      organizationId: json['organizationId'] as String?,
      createdDate: parseDate(json['createdDate']),
      createdBy: json['createdBy'] as String?,
      updatedDate: parseDate(json['updatedDate']),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (status != null) 'status': status,
      if (tax != null) 'tax': tax,
      if (categoryId != null) 'categoryId': categoryId,
      if (code != null) 'code': code,
      'categories': categories,
      'categoryIds': categoryIds,
      if (id != null) 'id': id,
      if (organizationId != null) 'organizationId': organizationId,
      if (createdDate != null) 'createdDate': createdDate!.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedDate != null) 'updatedDate': updatedDate!.toIso8601String(),
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}
