class BusinessProcessResponse {
  bool? success;
  String? message;
  List<BusinessProcessModel>? data;
  String? pagination;

  BusinessProcessResponse(
      {this.success, this.message, this.data, this.pagination});

  BusinessProcessResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BusinessProcessModel>[];
      json['data'].forEach((v) {
        data!.add(new BusinessProcessModel.fromJson(v));
      });
    }
    pagination = json['pagination'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['pagination'] = this.pagination;
    return data;
  }
}

class BusinessProcessModel {
  String? id;
  String? name;
  String? description;
  String? templateId;
  String? workspaceId;
  int? status;
  List<ProcessStages>? processStages;

  BusinessProcessModel(
      {this.id,
      this.name,
      this.description,
      this.templateId,
      this.workspaceId,
      this.status,
      this.processStages});

  BusinessProcessModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    templateId = json['templateId'];
    workspaceId = json['workspaceId'];
    status = json['status'];
    if (json['processStages'] != null) {
      processStages = <ProcessStages>[];
      json['processStages'].forEach((v) {
        processStages!.add(new ProcessStages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['templateId'] = this.templateId;
    data['workspaceId'] = this.workspaceId;
    data['status'] = this.status;
    if (this.processStages != null) {
      data['processStages'] =
          this.processStages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProcessStages {
  String? id;
  String? name;
  String? description;
  String? color;
  int? orderIndex;
  bool? isRequired;
  int? estimatedDays;
  String? startDate;
  String? completedDate;
  int? status;
  String? assignedTo;
  String? notes;
  bool? isCurrentStage;

  ProcessStages(
      {this.id,
      this.name,
      this.description,
      this.color,
      this.orderIndex,
      this.isRequired,
      this.estimatedDays,
      this.startDate,
      this.completedDate,
      this.status,
      this.assignedTo,
      this.notes,
      this.isCurrentStage});

  ProcessStages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    color = json['color'];
    orderIndex = json['orderIndex'];
    isRequired = json['isRequired'];
    estimatedDays = json['estimatedDays'];
    startDate = json['startDate'];
    completedDate = json['completedDate'];
    status = json['status'];
    assignedTo = json['assignedTo'];
    notes = json['notes'];
    isCurrentStage = json['isCurrentStage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['color'] = this.color;
    data['orderIndex'] = this.orderIndex;
    data['isRequired'] = this.isRequired;
    data['estimatedDays'] = this.estimatedDays;
    data['startDate'] = this.startDate;
    data['completedDate'] = this.completedDate;
    data['status'] = this.status;
    data['assignedTo'] = this.assignedTo;
    data['notes'] = this.notes;
    data['isCurrentStage'] = this.isCurrentStage;
    return data;
  }
}
