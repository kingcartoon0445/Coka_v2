import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class PagingResponse {
  int? code;
  List<PagingModel>? content;
  Metadata? metadata;

  PagingResponse({this.code, this.content, this.metadata});

  PagingResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <PagingModel>[];
      json['content'].forEach((v) {
        content!.add(new PagingModel.fromJson(v));
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

class PagingModel extends ChipData {
  final String? organizationId;
  final String? workspaceId;
  final int? count;
  final int? status;
  final String? createdDate;
  final String? lastModifiedDate;

  PagingModel(
    String id,
    String name, {
    this.organizationId,
    this.workspaceId,
    this.count,
    this.status,
    this.createdDate,
    this.lastModifiedDate,
  }) : super(id, name);

  /// Factory constructor để parse từ JSON
  factory PagingModel.fromJson(Map<String, dynamic> json) {
    return PagingModel(
      json['id'] as String,
      json['name'] as String,
      organizationId: json['organizationId'] as String?,
      workspaceId: json['workspaceId'] as String?,
      count: json['count'] as int?,
      status: json['status'] as int?,
      createdDate: json['createdDate'] as String?,
      lastModifiedDate: json['lastModifiedDate'] as String?,
    );
  }

  /// Chuyển về JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'organizationId': organizationId,
      'workspaceId': workspaceId,
      'count': count,
      'status': status,
      'createdDate': createdDate,
      'lastModifiedDate': lastModifiedDate,
    };
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
