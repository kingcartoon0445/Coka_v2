class BusinessProcessTaskResponse {
  final bool? success;
  final String? message;
  final List<BusinessProcessTaskModel>? data;
  final Pagination? pagination; 

  BusinessProcessTaskResponse({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory BusinessProcessTaskResponse.fromJson(Map<String, dynamic> json) {
    return BusinessProcessTaskResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BusinessProcessTaskModel.fromJson(e))
              .toList() ??
          <BusinessProcessTaskModel>[],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (success != null) map['success'] = success;
    if (message != null) map['message'] = message;
    if (data != null) map['data'] = data!.map((e) => e.toJson()).toList();
    if (pagination != null) map['pagination'] = pagination!.toJson();
    return map;
  }
}

class BusinessProcessTaskModel {
  final String? id;
  final String? stageId;
  final String? stageName;
  final String? name;
  final String? username;
  final String? email;
  final String? phone;
  final num? orderValue;
  final String? description;
  final String? customerId;
  final String? orderId;
  final List<AssignedTo>? assignedTo;
  final num? status;
  final String? notes;
  final bool? isBlocked;
  final String? blockedReason;
  final DateTime? createdDate;
  final String? createdBy;
  final DateTime? updatedDate;
  final String? updatedBy;
  final List<dynamic>? subTasks;
  final List<dynamic>? stageHistory;
  final List<dynamic>? tags;

  BusinessProcessTaskModel({
    this.id,
    this.stageId,
    this.stageName,
    this.name,
    this.username,
    this.email,
    this.phone,
    this.orderValue,
    this.description,
    this.customerId,
    this.orderId,
    this.assignedTo,
    this.status,
    this.notes,
    this.isBlocked,
    this.blockedReason,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
    this.subTasks,
    this.stageHistory,
    this.tags,
  });

  factory BusinessProcessTaskModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return BusinessProcessTaskModel(
      id: json['id'] as String?,
      stageId: json['stageId'] as String?,
      stageName: json['stageName'] as String?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      orderValue: (json['orderValue'] as num?)?.toInt(),
      description: json['description'] as String?,
      customerId: json['customerId'] as String?,
      orderId: json['orderId'] as String?,
      assignedTo: (json['assignedTo'] as List<dynamic>?)
              ?.map((e) => AssignedTo.fromJson(e))
              .toList() ??
          <AssignedTo>[],
      status: (json['status'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      isBlocked: json['isBlocked'] as bool?,
      blockedReason: json['blockedReason'] as String?,
      createdDate: parseDate(json['createdDate']),
      createdBy: json['createdBy'] as String?,
      updatedDate: parseDate(json['updatedDate']),
      updatedBy: json['updatedBy'] as String?,
      subTasks: (json['subTasks'] as List<dynamic>?) ?? <dynamic>[],
      stageHistory: (json['stageHistory'] as List<dynamic>?) ?? <dynamic>[],
      tags: (json['tags'] as List<dynamic>?) ?? <dynamic>[],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (id != null) map['id'] = id;
    if (stageId != null) map['stageId'] = stageId;
    if (stageName != null) map['stageName'] = stageName;
    if (name != null) map['name'] = name;
    if (username != null) map['username'] = username;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (orderValue != null) map['orderValue'] = orderValue;
    if (description != null) map['description'] = description;
    if (customerId != null) map['customerId'] = customerId;
    if (orderId != null) map['orderId'] = orderId;
    if (assignedTo != null) {
      map['assignedTo'] = assignedTo!.map((e) => e.toJson()).toList();
    }
    if (status != null) map['status'] = status;
    if (notes != null) map['notes'] = notes;
    if (isBlocked != null) map['isBlocked'] = isBlocked;
    if (blockedReason != null) map['blockedReason'] = blockedReason;
    if (createdDate != null)
      map['createdDate'] = createdDate!.toIso8601String();
    if (createdBy != null) map['createdBy'] = createdBy;
    if (updatedDate != null)
      map['updatedDate'] = updatedDate!.toIso8601String();
    if (updatedBy != null) map['updatedBy'] = updatedBy;
    if (subTasks != null) map['subTasks'] = subTasks;
    if (stageHistory != null) map['stageHistory'] = stageHistory;
    if (tags != null) map['tags'] = tags;
    return map;
  }
}

class AssignedTo {
  final String? id;
  final String? name;
  final String? avatar;
  final String? type;
  final num? status;

  AssignedTo({
    this.id,
    this.name,
    this.avatar,
    this.type,
    this.status,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      type: json['type'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (id != null) map['id'] = id;
    if (name != null) map['name'] = name;
    if (avatar != null) map['avatar'] = avatar;
    if (type != null) map['type'] = type;
    if (status != null) map['status'] = status;
    return map;
  }
}

class Pagination {
  final num? pageNumber;
  final num? pageSize;
  final num? totalRecords;
  final num? totalPages;

  Pagination({
    this.pageNumber,
    this.pageSize,
    this.totalRecords,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalRecords: (json['totalRecords'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (pageNumber != null) map['pageNumber'] = pageNumber;
    if (pageSize != null) map['pageSize'] = pageSize;
    if (totalRecords != null) map['totalRecords'] = totalRecords;
    if (totalPages != null) map['totalPages'] = totalPages;
    return map;
  }
}
