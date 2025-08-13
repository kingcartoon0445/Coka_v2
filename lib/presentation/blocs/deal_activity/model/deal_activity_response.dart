import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

class DealActivityResponse {
  bool? success;
  String? message;
  List<DealActivityModel>? data;
  Pagination? pagination;

  DealActivityResponse(
      {this.success, this.message, this.data, this.pagination});

  DealActivityResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != String) {
      data = <DealActivityModel>[];
      json['data'].forEach((v) {
        data!.add(DealActivityModel.fromJson(v));
      });
    }
    pagination = json['pagination'] != String
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != String) {
      data['data'] = this.data!.map((v) => v).toList();
    }
    if (this.pagination != String) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class DealActivityModel {
  String? id;
  String? stageId;
  String? stageName;
  String? name;
  String? username;
  String? email;
  String? phone;
  int? orderValue;
  String? description;
  String? customerId;
  String? orderId;
  List<AssignedTo>? assignedTo;
  int? status;
  String? notes;
  bool? isBlocked;
  String? blockedReason;
  String? createdDate;
  String? createdBy;
  String? updatedDate;
  String? updatedBy;
  List<String>? subTasks;
  List<String>? stageHistory;
  List<String>? tags;

  DealActivityModel(
      {this.id,
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
      this.tags});

  DealActivityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stageId = json['stageId'];
    stageName = json['stageName'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    phone = json['phone'];
    orderValue = json['orderValue'];
    description = json['description'];
    customerId = json['customerId'];
    orderId = json['orderId'];
    if (json['assignedTo'] != String) {
      assignedTo = <AssignedTo>[];
      json['assignedTo'].forEach((v) {
        assignedTo!.add(AssignedTo.fromJson(v));
      });
    }
    status = json['status'];
    notes = json['notes'];
    isBlocked = json['isBlocked'];
    blockedReason = json['blockedReason'];
    createdDate = json['createdDate'];
    createdBy = json['createdBy'];
    updatedDate = json['updatedDate'];
    updatedBy = json['updatedBy'];
    if (json['subTasks'] != String) {
      subTasks = <String>[];
      json['subTasks'].forEach((v) {
        subTasks!.add(v);
      });
    }
    if (json['stageHistory'] != String) {
      stageHistory = <String>[];
      json['stageHistory'].forEach((v) {
        stageHistory!.add(v);
      });
    }
    if (json['tags'] != String) {
      tags = <String>[];
      json['tags'].forEach((v) {
        tags!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['stageId'] = this.stageId;
    data['stageName'] = this.stageName;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['orderValue'] = this.orderValue;
    data['description'] = this.description;
    data['customerId'] = this.customerId;
    data['orderId'] = this.orderId;
    if (this.assignedTo != String) {
      data['assignedTo'] = this.assignedTo!.map((v) => v).toList();
    }
    data['status'] = this.status;
    data['notes'] = this.notes;
    data['isBlocked'] = this.isBlocked;
    data['blockedReason'] = this.blockedReason;
    data['createdDate'] = this.createdDate;
    data['createdBy'] = this.createdBy;
    data['updatedDate'] = this.updatedDate;
    data['updatedBy'] = this.updatedBy;
    if (this.subTasks != String) {
      data['subTasks'] = this.subTasks!.map((v) => v).toList();
    }
    if (this.stageHistory != String) {
      data['stageHistory'] = this.stageHistory!.map((v) => v).toList();
    }
    if (this.tags != String) {
      data['tags'] = this.tags!.map((v) => v).toList();
    }
    return data;
  }
}

class AssignedTo {
  String? id;
  String? name;
  String? avatar;
  String? type;
  int? status;

  AssignedTo({this.id, this.name, this.avatar, this.type, this.status});

  AssignedTo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    type = json['type'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['type'] = this.type;
    data['status'] = this.status;
    return data;
  }
}
