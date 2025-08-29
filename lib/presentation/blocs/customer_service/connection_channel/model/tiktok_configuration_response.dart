class TiktokConfigurationResponse {
  int? code;
  TiktokConfigurationModel? content;

  TiktokConfigurationResponse({this.code, this.content});

  TiktokConfigurationResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    content =
        json['content'] != null ? new TiktokConfigurationModel.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.content != null) {
      data['content'] = this.content!.toJson();
    }
    return data;
  }
}

class TiktokConfigurationModel {
  String? duplicateId;
  String? transferStatus;
  String? pageId;
  String? publishTime;
  String? updateTime;
  String? createTime;
  String? title;
  String? userId;
  String? formStatus;
  String? thumbnail;
  String? templateId;
  String? destinationUrl;
  String? previewUrl;
  String? connectionState;
  List<MappingField>? mappingField;
  int? status;
  String? createdDate;
  String? lastModifiedDate;

  TiktokConfigurationModel(
      {this.duplicateId,
      this.transferStatus,
      this.pageId,
      this.publishTime,
      this.updateTime,
      this.createTime,
      this.title,
      this.userId,
      this.formStatus,
      this.thumbnail,
      this.templateId,
      this.destinationUrl,
      this.previewUrl,
      this.connectionState,
      this.mappingField,
      this.status,
      this.createdDate,
      this.lastModifiedDate});

  TiktokConfigurationModel.fromJson(Map<String, dynamic> json) {
    duplicateId = json['duplicateId'];
    transferStatus = json['transferStatus'];
    pageId = json['pageId'];
    publishTime = json['publishTime'];
    updateTime = json['updateTime'];
    createTime = json['createTime'];
    title = json['title'];
    userId = json['userId'];
    formStatus = json['formStatus'];
    thumbnail = json['thumbnail'];
    templateId = json['templateId'];
    destinationUrl = json['destinationUrl'];
    previewUrl = json['previewUrl'];
    connectionState = json['connectionState'];
    if (json['mappingField'] != null) {
      mappingField = <MappingField>[];
      json['mappingField'].forEach((v) {
        mappingField!.add(new MappingField.fromJson(v));
      });
    }
    status = json['status'];
    createdDate = json['createdDate'];
    lastModifiedDate = json['lastModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['duplicateId'] = this.duplicateId;
    data['transferStatus'] = this.transferStatus;
    data['pageId'] = this.pageId;
    data['publishTime'] = this.publishTime;
    data['updateTime'] = this.updateTime;
    data['createTime'] = this.createTime;
    data['title'] = this.title;
    data['userId'] = this.userId;
    data['formStatus'] = this.formStatus;
    data['thumbnail'] = this.thumbnail;
    data['templateId'] = this.templateId;
    data['destinationUrl'] = this.destinationUrl;
    data['previewUrl'] = this.previewUrl;
    data['connectionState'] = this.connectionState;
    if (this.mappingField != null) {
      data['mappingField'] = this.mappingField!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }
}

class MappingField {
  String? tiktokFieldId;
  String? tiktokFieldTitle;
  String? cokaField;

  MappingField({this.tiktokFieldId, this.tiktokFieldTitle, this.cokaField});

  MappingField.fromJson(Map<String, dynamic> json) {
    tiktokFieldId = json['tiktokFieldId'];
    tiktokFieldTitle = json['tiktokFieldTitle'];
    cokaField = json['cokaField'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tiktokFieldId'] = this.tiktokFieldId;
    data['tiktokFieldTitle'] = this.tiktokFieldTitle;
    data['cokaField'] = this.cokaField;
    return data;
  }
}
