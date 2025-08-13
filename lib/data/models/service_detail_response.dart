import 'package:source_base/data/models/customer_service_response.dart'; 
export 'package:source_base/data/models/organization_model.dart';

class ServiceDetailResponse {
  int? code;
  List<ServiceDetailModel>? content;
  Metadata? metadata;

  ServiceDetailResponse({this.code, this.content, this.metadata});

  ServiceDetailResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <ServiceDetailModel>[];
      json['content'].forEach((v) {
        content!.add(new ServiceDetailModel.fromJson(v));
      });
    }
       if (json['data'] != null) {
      content = <ServiceDetailModel>[];
      json['data'].forEach((v) {
        content!.add(new ServiceDetailModel.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.content != null) {
      data['content'] = this.content!.map((v) => v.toJson()).toList();
    }
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    return data;
  }
}

class ServiceDetailModel {
  String? id;
  String? summary;
  String? createdDate;
  String? createdByName;
  String? type;
  String? icon;

  ServiceDetailModel(
      {this.id,
      this.summary,
      this.createdDate,
      this.createdByName,
      this.type,
      this.icon});

  ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    summary = json['summary'];
    createdDate = json['createdDate'];
    createdByName = json['createdByName'];
    type = json['type'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['summary'] = this.summary;
    data['createdDate'] = this.createdDate;
    data['createdByName'] = this.createdByName;
    data['type'] = this.type;
    data['icon'] = this.icon;
    return data;
  }
}
