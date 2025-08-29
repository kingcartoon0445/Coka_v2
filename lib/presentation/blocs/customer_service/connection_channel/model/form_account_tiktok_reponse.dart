class FormAccountTiktokResponse {
  int? code;
  List<FormAccountTiktokModel>? content;

  FormAccountTiktokResponse({this.code, this.content});

  FormAccountTiktokResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <FormAccountTiktokModel>[];
      json['content'].forEach((v) {
        content!.add(new FormAccountTiktokModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.content != null) {
      data['content'] = this.content!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FormAccountTiktokModel {
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
  int? status;
  String? createdDate;
  String? lastModifiedDate;

  FormAccountTiktokModel(
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
      this.status,
      this.createdDate,
      this.lastModifiedDate});

  FormAccountTiktokModel.fromJson(Map<String, dynamic> json) {
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
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }
}
