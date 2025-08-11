import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class BusinessProcessTemplateResponse {
  bool? success;
  String? message;
  List<BusinessProcessTemplateModel>? data;

  BusinessProcessTemplateResponse({
    this.success,
    this.message,
    this.data,
  });

  BusinessProcessTemplateResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BusinessProcessTemplateModel>[];
      json['data'].forEach((v) {
        data!.add(BusinessProcessTemplateModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BusinessProcessTemplateModel extends ChipData {
  String? description;
  String? category;
  bool? isDefault;
  bool? isActive;
  String? createdDate;
  String? createdBy;
  List<TemplateStages>? templateStages;

  BusinessProcessTemplateModel(super.id, super.name,
      {this.description,
      this.category,
      this.isDefault,
      this.isActive,
      this.createdDate,
      this.createdBy,
      this.templateStages});

  factory BusinessProcessTemplateModel.fromJson(Map<String, dynamic> json) {
    return BusinessProcessTemplateModel(json['id'], json['name'],
        description: json['description'],
        category: json['category'],
        isDefault: json['isDefault'],
        isActive: json['isActive'],
        createdDate: json['createdDate'],
        createdBy: json['createdBy'],
        templateStages: json['templateStages'] != null
            ? (json['templateStages'] as List)
                .map((v) => TemplateStages.fromJson(v))
                .toList()
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['category'] = category;
    data['isDefault'] = isDefault;
    data['isActive'] = isActive;
    data['createdDate'] = createdDate;
    data['createdBy'] = createdBy;
    if (templateStages != null) {
      data['templateStages'] = templateStages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TemplateStages {
  String? id;
  String? name;
  String? description;
  String? color;
  int? orderIndex;
  bool? isRequired;
  int? estimatedDays;

  TemplateStages(
      {this.id,
      this.name,
      this.description,
      this.color,
      this.orderIndex,
      this.isRequired,
      this.estimatedDays});

  TemplateStages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    color = json['color'];
    orderIndex = json['orderIndex'];
    isRequired = json['isRequired'];
    estimatedDays = json['estimatedDays'];
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
    return data;
  }
}
