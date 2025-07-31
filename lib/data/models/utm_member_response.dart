import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class UtmSourceResponse {
  int? code;
  List<UtmSourceModel>? content;
  Metadata? metadata;

  UtmSourceResponse({this.code, this.content, this.metadata});

  UtmSourceResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <UtmSourceModel>[];
      json['content'].forEach((v) {
        content!.add(new UtmSourceModel.fromJson(v));
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

class UtmSourceModel extends ChipData {
  String? organizationId;
  String? workspaceId;
  int? count;
  int? status;
  String? createdDate;
  String? lastModifiedDate;

  UtmSourceModel(String id, String name,
      {this.organizationId,
      this.workspaceId,
      this.count,
      this.status,
      this.createdDate,
      this.lastModifiedDate})
      : super(id, name);

  /// Factory constructor để parse từ JSON
  factory UtmSourceModel.fromJson(Map<String, dynamic> json) {
    return UtmSourceModel(
      json['id'] as String,
      json['name'] as String,
      organizationId: json['organizationId'],
      workspaceId: json['workspaceId'],
      count: json['count'],
      status: json['status'],
      createdDate: json['createdDate'],
      lastModifiedDate: json['lastModifiedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['organizationId'] = this.organizationId;
    data['workspaceId'] = this.workspaceId;
    data['name'] = this.name;
    data['count'] = this.count;
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
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
