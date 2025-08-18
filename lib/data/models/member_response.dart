import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';
export 'package:source_base/data/models/organization_model.dart';

class MemberResponse {
  int? code;
  List<MemberModel>? content;
  Metadata? metadata;

  MemberResponse({this.code, this.content, this.metadata});

  MemberResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <MemberModel>[];
      json['content'].forEach((v) {
        content!.add(new MemberModel.fromJson(v));
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

class MemberModel extends ChipData {
  String? organizationId;
  String? email;
  String? avatar;
  String? address;
  String? typeOfEmployee;
  int? status;
  String? createdBy;
  String? createdDate;
  String? lastModifiedBy;
  String? lastModifiedDate;

  MemberModel(String id, String name,
      {this.organizationId,
      this.email,
      this.avatar,
      this.address,
      this.typeOfEmployee,
      this.status,
      this.createdBy,
      this.createdDate,
      this.lastModifiedBy,
      this.lastModifiedDate})
      : super(id, name);

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      json['profileId'] as String,
      json['fullName'] as String,
      organizationId: json['organizationId'],
      email: json['email'],
      avatar: json['avatar'],
      address: json['address'],
      typeOfEmployee: json['typeOfEmployee'],
      status: json['status'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      lastModifiedBy: json['lastModifiedBy'],
      lastModifiedDate: json['lastModifiedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organizationId'] = this.organizationId;
    data['profileId'] = this.id;
    data['fullName'] = this.name;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['address'] = this.address;
    data['typeOfEmployee'] = this.typeOfEmployee;
    data['status'] = this.status;
    data['createdBy'] = this.createdBy;
    data['createdDate'] = this.createdDate;
    data['lastModifiedBy'] = this.lastModifiedBy;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }
}
