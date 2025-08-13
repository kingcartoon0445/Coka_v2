class NoteSimpleResponse {
  final bool? success;
  final String? message;
  final List<NoteSimpleModel>? data;
  final Pagination? pagination;

  NoteSimpleResponse({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory NoteSimpleResponse.fromJson(Map<String, dynamic> json) {
    return NoteSimpleResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NoteSimpleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class NoteSimpleModel {
  final String? id;
  final String? summary;
  final DateTime? createdDate;
  final String? createdByName;
  final String? type;
  final String? icon;

  NoteSimpleModel({
    this.id,
    this.summary,
    this.createdDate,
    this.createdByName,
    this.type,
    this.icon,
  });

  factory NoteSimpleModel.fromJson(Map<String, dynamic> json) {
    return NoteSimpleModel(
      id: json['id'] as String?,
      summary: json['summary'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'] as String)
          : null,
      createdByName: json['createdByName'] as String?,
      type: json['type'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'createdDate': createdDate?.toIso8601String(),
      'createdByName': createdByName,
      'type': type,
      'icon': icon,
    };
  }
}

class Pagination {
  final int? pageNumber;
  final int? pageSize;
  final int? totalRecords;
  final int? totalPages;

  Pagination({
    this.pageNumber,
    this.pageSize,
    this.totalRecords,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      pageNumber: json['pageNumber'] as int?,
      pageSize: json['pageSize'] as int?,
      totalRecords: json['totalRecords'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
    };
  }
}
