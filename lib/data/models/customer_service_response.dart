class CustomerServiceResponse {
  int? code;
  List<CustomerServiceModel>? content;
  Metadata? metadata;

  CustomerServiceResponse({this.code, this.content, this.metadata});

  CustomerServiceResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <CustomerServiceModel>[];
      json['content'].forEach((v) {
        content!.add(new CustomerServiceModel.fromJson(v));
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

class CustomerServiceModel {
  String? id;
  String? title;
  String? fullName;
  List<Assignees>? assignees;
  String? createdDate;
  String? lastModifiedDate;
  String? snippet;

  CustomerServiceModel(
      {this.id,
      this.title,
      this.fullName,
      this.assignees,
      this.createdDate,
      this.lastModifiedDate,
      this.snippet});

  CustomerServiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    fullName = json['fullName'];
    if (json['assignees'] != null) {
      assignees = <Assignees>[];
      json['assignees'].forEach((v) {
        assignees!.add(new Assignees.fromJson(v));
      });
    }
    createdDate = json['createdDate'];
    lastModifiedDate = json['lastModifiedDate'];
    snippet = json['snippet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['fullName'] = this.fullName;
    if (this.assignees != null) {
      data['assignees'] = this.assignees!.map((v) => v.toJson()).toList();
    }
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    data['snippet'] = this.snippet;
    return data;
  }
}

class Assignees {
  String? id;
  String? profileId;
  String? profileName;
  String? avatar;
  String? type;

  Assignees(
      {this.id, this.profileId, this.profileName, this.avatar, this.type});

  Assignees.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileId = json['profileId'];
    profileName = json['profileName'];
    avatar = json['avatar'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['profileId'] = this.profileId;
    data['profileName'] = this.profileName;
    data['avatar'] = this.avatar;
    data['type'] = this.type;
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
