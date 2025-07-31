class OrganizationResponse {
  int? code;
  List<OrganizationModel>? content;
  Metadata? metadata;

  OrganizationResponse({this.code, this.content, this.metadata});

  OrganizationResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <OrganizationModel>[];
      json['content'].forEach((v) {
        content!.add(new OrganizationModel.fromJson(v));
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

class OrganizationModel {
  String? id;
  String? name;
  String? description;
  String? avatar;
  String? website;
  String? subscription;
  String? type;
  int? status;
  String? createdDate;
  String? address;
  String? fieldOfActivity;
  String? hotline;

  OrganizationModel(
      {this.id,
      this.name,
      this.description,
      this.avatar,
      this.website,
      this.subscription,
      this.type,
      this.status,
      this.createdDate,
      this.address,
      this.fieldOfActivity,
      this.hotline});

  OrganizationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    avatar = json['avatar'];
    website = json['website'];
    subscription = json['subscription'];
    type = json['type'];
    status = json['status'];
    createdDate = json['createdDate'];
    address = json['address'];
    fieldOfActivity = json['fieldOfActivity'];
    hotline = json['hotline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['avatar'] = this.avatar;
    data['website'] = this.website;
    data['subscription'] = this.subscription;
    data['type'] = this.type;
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    data['address'] = this.address;
    data['fieldOfActivity'] = this.fieldOfActivity;
    data['hotline'] = this.hotline;
    return data;
  }
}

class Metadata {
  int? total;
  int? count;
  int? offset;
  int? limit;

  Metadata({this.total, this.count, this.offset, this.limit});

  Metadata.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    count = json['count'];
    offset = json['offset'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['count'] = this.count;
    data['offset'] = this.offset;
    data['limit'] = this.limit;
    return data;
  }
}
