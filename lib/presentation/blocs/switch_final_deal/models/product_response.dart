import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class ProductResponse {
  final bool success;
  final String message;
  final List<ProductModel> data;
  final Pagination pagination;

  ProductResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'],
      message: json['message'],
      data: List<ProductModel>.from(
          json['data'].map((x) => ProductModel.fromJson(x))),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
        'pagination': pagination.toJson(),
      };
}

class ProductModel extends ChipData {
  final String? code;
  final num price;
  final String description;
  final int status;
  final List<String> images;
  final num tax;
  final String categoryId;
  final Category? category;
  final List<Category> categories;
  final DateTime createdDate;

  ProductModel(
    super.id,
    super.name, {
    this.code,
    required this.price,
    required this.description,
    required this.status,
    required this.images,
    required this.tax,
    required this.categoryId,
    this.category,
    required this.categories,
    required this.createdDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['id'],
      json['name'],
      code: json['code'],
      price: json['price'],
      description: json['description'],
      status: json['status'],
      images: List<String>.from(json['images'].map((x) => x)),
      tax: json['tax'],
      categoryId: json['categoryId'] ?? "",
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      categories: List<Category>.from(
          json['categories'].map((x) => Category.fromJson(x))),
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': super.id,
        'name': super.name,
        'code': code,
        'price': price,
        'description': description,
        'status': status,
        'images': List<dynamic>.from(images.map((x) => x)),
        'tax': tax,
        'categoryId': categoryId,
        'category': category?.toJson(),
        'categories': List<dynamic>.from(categories.map((x) => x.toJson())),
        'createdDate': createdDate.toIso8601String(),
      };
}

class Category {
  final String id;
  final String name;
  final int status;

  Category({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
      };
}

class Pagination {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;

  Pagination({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalRecords: json['totalRecords'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'totalRecords': totalRecords,
        'totalPages': totalPages,
      };
}
