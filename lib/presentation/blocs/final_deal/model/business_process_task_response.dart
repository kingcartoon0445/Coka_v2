class BusinessProcessTaskResponse {
  bool? success;
  String? message;
  List<BusinessProcessTaskModel>? data;
  Pagination? pagination;

  BusinessProcessTaskResponse(
      {this.success, this.message, this.data, this.pagination});

  BusinessProcessTaskResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BusinessProcessTaskModel>[];
      json['data'].forEach((v) {
        data!.add(new BusinessProcessTaskModel.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class BusinessProcessTaskModel {
  String? id;
  String? stageId;
  String? stageName;
  String? name;
  String? description;
  String? customerId;
  String? orderId;
  List<AssignedTo>? assignedTo;
  String? startDate;
  String? dueDate;
  String? completedDate;
  int? status;
  String? priority;
  String? notes;
  bool? isBlocked;
  String? blockedReason;
  String? createdDate;
  String? createdBy;
  String? updatedDate;
  String? updatedBy;
  List<String>? subTasks;
  List<String>? stageHistory;
  String? customerInfo;

  BusinessProcessTaskModel(
      {this.id,
      this.stageId,
      this.stageName,
      this.name,
      this.description,
      this.customerId,
      this.orderId,
      this.assignedTo,
      this.startDate,
      this.dueDate,
      this.completedDate,
      this.status,
      this.priority,
      this.notes,
      this.isBlocked,
      this.blockedReason,
      this.createdDate,
      this.createdBy,
      this.updatedDate,
      this.updatedBy,
      this.subTasks,
      this.stageHistory,
      this.customerInfo});

  BusinessProcessTaskModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stageId = json['stageId'];
    stageName = json['stageName'];
    name = json['name'];
    description = json['description'];
    customerId = json['customerId'];
    orderId = json['orderId'];
    if (json['assignedTo'] != null) {
      assignedTo = <AssignedTo>[];
      json['assignedTo'].forEach((v) {
        assignedTo!.add(new AssignedTo.fromJson(v));
      });
    }
    startDate = json['startDate'];
    dueDate = json['dueDate'];
    completedDate = json['completedDate'];
    status = json['status'];
    priority = json['priority'];
    notes = json['notes'];
    isBlocked = json['isBlocked'];
    blockedReason = json['blockedReason'];
    createdDate = json['createdDate'];
    createdBy = json['createdBy'];
    updatedDate = json['updatedDate'];
    updatedBy = json['updatedBy'];
    if (json['subTasks'] != null) {
      subTasks = <String>[];
      json['subTasks'].forEach((v) {
        subTasks!.add(v);
      });
    }
    if (json['stageHistory'] != null) {
      stageHistory = <String>[];
      json['stageHistory'].forEach((v) {
        stageHistory!.add(v);
      });
    }
    customerInfo = json['customerInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['stageId'] = this.stageId;
    data['stageName'] = this.stageName;
    data['name'] = this.name;
    data['description'] = this.description;
    data['customerId'] = this.customerId;
    data['orderId'] = this.orderId;
    if (this.assignedTo != null) {
      data['assignedTo'] = this.assignedTo!.map((v) => v.toJson()).toList();
    }
    data['startDate'] = this.startDate;
    data['dueDate'] = this.dueDate;
    data['completedDate'] = this.completedDate;
    data['status'] = this.status;
    data['priority'] = this.priority;
    data['notes'] = this.notes;
    data['isBlocked'] = this.isBlocked;
    data['blockedReason'] = this.blockedReason;
    data['createdDate'] = this.createdDate;
    data['createdBy'] = this.createdBy;
    data['updatedDate'] = this.updatedDate;
    data['updatedBy'] = this.updatedBy;

    data['customerInfo'] = this.customerInfo;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['type'] = this.type;
    data['status'] = this.status;
    return data;
  }
}

class Pagination {
  int? pageNumber;
  int? pageSize;
  int? totalRecords;
  int? totalPages;

  Pagination(
      {this.pageNumber, this.pageSize, this.totalRecords, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    totalRecords = json['totalRecords'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pageNumber'] = this.pageNumber;
    data['pageSize'] = this.pageSize;
    data['totalRecords'] = this.totalRecords;
    data['totalPages'] = this.totalPages;
    return data;
  }
}
