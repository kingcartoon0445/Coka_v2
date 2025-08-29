class OrganizationSearchRepsonse {
  int? code;
  List<OrganizationSearchModel>? content;
  Metadata? metadata;

  OrganizationSearchRepsonse({this.code, this.content, this.metadata});

  OrganizationSearchRepsonse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <OrganizationSearchModel>[];
      json['content'].forEach((v) {
        content!.add(new OrganizationSearchModel.fromJson(v));
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

class OrganizationSearchModel {
  String? organizationId;
  String? name;
  String? subscription;
  bool? isRequest;

  OrganizationSearchModel(
      {this.organizationId, this.name, this.subscription, this.isRequest});

  OrganizationSearchModel.fromJson(Map<String, dynamic> json) {
    organizationId = json['organizationId'];
    name = json['name'];
    subscription = json['subscription'];
    isRequest = json['isRequest'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organizationId'] = this.organizationId;
    data['name'] = this.name;
    data['subscription'] = this.subscription;
    data['isRequest'] = this.isRequest;
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
