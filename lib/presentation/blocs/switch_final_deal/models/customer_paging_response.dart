import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class CustomerPagingResponse {
  int? code;
  List<CustomerPaging>? content;
  Metadata? metadata;

  CustomerPagingResponse({this.code, this.content, this.metadata});

  CustomerPagingResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <CustomerPaging>[];
      json['content'].forEach((v) {
        content!.add(new CustomerPaging.fromJson(v));
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

class CustomerPaging extends ChipData {
  String? workspaceId;
  String? workspaceName;
  String? title;
  String? phone;
  String? email;
  List<Assignees>? assignees;
  String? createdDate;
  String? lastModifiedDate;
  String? snippet;

  CustomerPaging(super.id, super.name,
      {this.workspaceId,
      this.workspaceName,
      this.title,
      this.phone,
      this.email,
      this.assignees,
      this.createdDate,
      this.lastModifiedDate,
      this.snippet});

  factory CustomerPaging.fromJson(Map<String, dynamic> json) {
    return CustomerPaging(
      json['id'] as String,
      json['fullName'] as String,
      workspaceId: json['workspaceId'],
      workspaceName: json['workspaceName'],
      title: json['title'],
      phone: json['phone'],
      email: json['email'],
      assignees: json['assignees'] != null
          ? (json['assignees'] as List)
              .map((v) => Assignees.fromJson(v))
              .toList()
          : null,
      createdDate: json['createdDate'],
      lastModifiedDate: json['lastModifiedDate'],
      snippet: json['snippet'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['workspaceId'] = this.workspaceId;
    data['workspaceName'] = this.workspaceName;
    data['title'] = this.title;
    data['fullName'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    if (this.assignees != null) {
      data['assignees'] = this.assignees!.map((v) => v.toJson()).toList();
    }
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    data['snippet'] = this.snippet;
    return data;
  }
}
