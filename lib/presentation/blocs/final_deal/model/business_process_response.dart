import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

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
        data!.add(BusinessProcessModel.fromJson(v));
      });
    }
    pagination = json['pagination'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['pagination'] = pagination;
    return data;
  }
}

class BusinessProcessModel extends ChipData {
  String? description;
  String? templateId;
  String? workspaceId;
  int? status;
  List<ProcessStages>? processStages;

  BusinessProcessModel(super.id, super.name,
      {this.description,
      this.templateId,
      this.workspaceId,
      this.status,
      this.processStages});

  factory BusinessProcessModel.fromJson(Map<String, dynamic> json) {
    return BusinessProcessModel(json['id'], json['name'],
        description: json['description'],
        templateId: json['templateId'],
        workspaceId: json['workspaceId'],
        status: json['status'],
        processStages: json['processStages'] != null
            ? (json['processStages'] as List)
                .map((v) => ProcessStages.fromJson(v))
                .toList()
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['templateId'] = templateId;
    data['workspaceId'] = workspaceId;
    data['status'] = status;
    if (processStages != null) {
      data['processStages'] = processStages!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['color'] = color;
    data['orderIndex'] = orderIndex;
    data['isRequired'] = isRequired;
    data['estimatedDays'] = estimatedDays;
    data['startDate'] = startDate;
    data['completedDate'] = completedDate;
    data['status'] = status;
    data['assignedTo'] = assignedTo;
    data['notes'] = notes;
    data['isCurrentStage'] = isCurrentStage;
    return data;
  }
}
