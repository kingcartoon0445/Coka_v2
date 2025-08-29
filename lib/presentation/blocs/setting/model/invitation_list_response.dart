class InvitationListResponse {
  int? code;
  List<InvitationListModel>? content;
  Metadata? metadata;

  InvitationListResponse({this.code, this.content, this.metadata});

  InvitationListResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <InvitationListModel>[];
      json['content'].forEach((v) {
        content!.add(new InvitationListModel.fromJson(v));
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

class InvitationListModel {
  String? id;
  String? organizationId;
  Organization? organization;
  String? profileId;
  String? typeOfEmployee;
  String? type;
  int? status;
  String? createdDate;

  InvitationListModel(
      {this.id,
      this.organizationId,
      this.organization,
      this.profileId,
      this.typeOfEmployee,
      this.type,
      this.status,
      this.createdDate});

  InvitationListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    organizationId = json['organizationId'];
    organization = json['organization'] != null
        ? new Organization.fromJson(json['organization'])
        : null;
    profileId = json['profileId'];
    typeOfEmployee = json['typeOfEmployee'];
    type = json['type'];
    status = json['status'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['organizationId'] = this.organizationId;
    if (this.organization != null) {
      data['organization'] = this.organization!.toJson();
    }
    data['profileId'] = this.profileId;
    data['typeOfEmployee'] = this.typeOfEmployee;
    data['type'] = this.type;
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    return data;
  }
}

class Organization {
  String? id;
  String? name;
  String? description;
  String? avatar;
  String? website;
  String? subscription;
  int? status;
  String? createdDate;

  Organization(
      {this.id,
      this.name,
      this.description,
      this.avatar,
      this.website,
      this.subscription,
      this.status,
      this.createdDate});

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    avatar = json['avatar'];
    website = json['website'];
    subscription = json['subscription'];
    status = json['status'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['avatar'] = this.avatar;
    data['website'] = this.website;
    data['subscription'] = this.subscription;
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
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
