import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_tag_response.dart';

/// TaskResponse / TaskModel / AssignedTo / Pagination
/// - Parse 'data' an toàn: hỗ trợ List hoặc Map có mảng con (items/records/results/list/data/tasks)
/// - Parse ngày linh hoạt: ISO string hoặc epoch (ms/s)
/// - toJson() nhất quán, bao gồm tags

class TaskResponse {
  final bool? success;
  final String? message;
  final List<TaskModel> data;
  final Pagination? pagination;

  TaskResponse({
    this.success,
    this.message,
    this.data = const <TaskModel>[],
    this.pagination,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<TaskModel> parsedData = <TaskModel>[];
    Pagination? parsedPagination;

    // Nếu top-level có pagination thì ưu tiên dùng
    if (json['pagination'] is Map<String, dynamic>) {
      parsedPagination =
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>);
    }

    if (rawData is List) {
      // Trường hợp data là list các task
      parsedData = rawData
          .whereType<dynamic>()
          .map((e) => _toMap(e))
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();
    } else if (rawData is Map) {
      // Trường hợp data là object, có thể chứa list ở các key quen thuộc
      final dataMap = rawData as Map;

      // Nếu có nested pagination trong data
      if (parsedPagination == null &&
          dataMap['pagination'] is Map<String, dynamic>) {
        parsedPagination =
            Pagination.fromJson(dataMap['pagination'] as Map<String, dynamic>);
      }

      // Tìm list đầu tiên trong các key phổ biến
      final candidates = [
        'items',
        'records',
        'results',
        'list',
        'data',
        'tasks'
      ];
      List<dynamic>? listNode;

      for (final key in candidates) {
        final v = dataMap[key];
        if (v is List) {
          listNode = v;
          break;
        }
      }

      // Nếu không có các key trên mà bản thân dataMap là list-like -> bỏ qua
      // Ngược lại, nếu không tìm được list thì cố gắng đoán xem toàn bộ dataMap có phải 1 TaskModel không
      if (listNode != null) {
        parsedData = listNode
            .whereType<dynamic>()
            .map((e) => _toMap(e))
            .whereType<Map<String, dynamic>>()
            .map(TaskModel.fromJson)
            .toList();
      } else {
        // Thử parse 1 object TaskModel đơn lẻ
        final maybe = _toMap(dataMap);
        if (maybe != null) {
          parsedData = [TaskModel.fromJson(maybe)];
        }
      }
    } else if (rawData == null) {
      // Không có data -> để rỗng
      parsedData = <TaskModel>[];
    } else {
      // Kiểu không mong đợi -> để rỗng
      parsedData = <TaskModel>[];
    }

    return TaskResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: parsedData,
      pagination: parsedPagination,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (success != null) map['success'] = success;
    if (message != null) map['message'] = message;
    map['data'] = data.map((e) => e.toJson()).toList();
    if (pagination != null) map['pagination'] = pagination!.toJson();
    return map;
  }
}

class TaskModel {
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
  final List<AssignedTo> assignedTo;
  final num? status;
  final String? notes;
  final bool? isBlocked;
  final String? blockedReason;
  final DateTime? createdDate;
  final String? createdBy;
  final DateTime? updatedDate;
  final String? updatedBy;
  final List<dynamic> subTasks;
  final List<dynamic> stageHistory;
  final List<TagModel> tags;

  TaskModel({
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
    this.assignedTo = const <AssignedTo>[],
    this.status,
    this.notes,
    this.isBlocked,
    this.blockedReason,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
    this.subTasks = const <dynamic>[],
    this.stageHistory = const <dynamic>[],
    this.tags = const <TagModel>[],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.trim().isNotEmpty) {
        // ISO-8601
        return DateTime.tryParse(v);
      }
      if (v is num) {
        // Epoch ms or s
        final iv = v.toInt();
        // Nếu lớn hơn năm ~2001 tính theo ms
        if (iv > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(iv, isUtc: false);
        }
        // Nếu có vẻ là giây
        if (iv > 1000000000) {
          return DateTime.fromMillisecondsSinceEpoch(iv * 1000, isUtc: false);
        }
        return null;
      }
      return null;
    }

    List<AssignedTo> parseAssignedTo(dynamic v) {
      if (v is List) {
        return v
            .map(_toMap)
            .whereType<Map<String, dynamic>>()
            .map(AssignedTo.fromJson)
            .toList();
      }
      return <AssignedTo>[];
    }

    List<TagModel> parseTags(dynamic v) {
      if (v is List) {
        return v
            .map(_toMap)
            .whereType<Map<String, dynamic>>()
            .map(TagModel.fromJson)
            .toList();
      }
      return <TagModel>[];
    }

    List<dynamic> parseDynamicList(dynamic v) {
      if (v is List) return v;
      return const <dynamic>[];
    }

    return TaskModel(
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
      assignedTo: parseAssignedTo(json['assignedTo']),
      status: (json['status'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      isBlocked: json['isBlocked'] as bool?,
      blockedReason: json['blockedReason'] as String?,
      createdDate: parseDate(json['createdDate']),
      createdBy: json['createdBy'] as String?,
      updatedDate: parseDate(json['updatedDate']),
      updatedBy: json['updatedBy'] as String?,
      subTasks: parseDynamicList(json['subTasks']),
      stageHistory: parseDynamicList(json['stageHistory']),
      tags: parseTags(json['tags']),
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
    if (assignedTo.isNotEmpty) {
      map['assignedTo'] = assignedTo.map((e) => e.toJson()).toList();
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
    if (subTasks.isNotEmpty) map['subTasks'] = subTasks;
    if (stageHistory.isNotEmpty) map['stageHistory'] = stageHistory;
    if (tags.isNotEmpty) {
      // Giả định TagModel có toJson()
      map['tags'] = tags.map((e) => e.toJson()).toList();
    }
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

/// ——— Helpers —————————————————————————————————————————————

Map<String, dynamic>? _toMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    // Chuyển Map<dynamic, dynamic> => Map<String, dynamic>
    return v.map((key, value) => MapEntry(key?.toString() ?? '', value));
  }
  return null;
}
