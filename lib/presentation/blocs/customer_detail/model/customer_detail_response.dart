import 'package:source_base/data/models/customer_service_response.dart';

class CustomerDetailResponse {
  int? code;
  CustomerDetailModel? content;

  CustomerDetailResponse({this.code, this.content});

  CustomerDetailResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    content = json['content'] != null
        ? new CustomerDetailModel.fromJson(json['content'])
        : null;
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

class CustomerDetailModel {
  String? id;
  String? title;
  String? fullName;
  String? email;
  String? phone;
  String? rawPhone;
  int? gender;
  String? dob;
  String? address;
  String? work;
  String? physicalId;
  List<String>? deals;
  List<String>? leads;
  List<Assignees>? assignees;
  String? createdDate;
  String? lastModifiedDate;

  CustomerDetailModel(
      {this.id,
      this.title,
      this.fullName,
      this.email,
      this.phone,
      this.rawPhone,
      this.gender,
      this.dob,
      this.address,
      this.work,
      this.physicalId,
      this.deals,
      this.leads,
      this.assignees,
      this.createdDate,
      this.lastModifiedDate});

  CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    fullName = json['fullName'];
    email = json['email'];
    phone = json['phone'];
    rawPhone = json['rawPhone'];
    gender = json['gender'];
    dob = json['dob'];
    address = json['address'];
    work = json['work'];
    physicalId = json['physicalId'];
    if (json['deals'] != null) {
      deals = <String>[];
      json['deals'].forEach((v) {
        deals!.add(v);
      });
    }
    // if (json['leads'] != null) {
    //   leads = <String>[];
    //   json['leads'].forEach((v) {
    //     leads!.add(v);
    //   });
    // }
    if (json['assignees'] != null) {
      assignees = <Assignees>[];
      json['assignees'].forEach((v) {
        assignees!.add(new Assignees.fromJson(v));
      });
    }
    createdDate = json['createdDate'];
    lastModifiedDate = json['lastModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['rawPhone'] = this.rawPhone;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['address'] = this.address;
    data['work'] = this.work;
    data['physicalId'] = this.physicalId;
    if (this.deals != null) {
      data['deals'] = this.deals;
    }
    if (this.leads != null) {
      data['leads'] = this.leads;
    }
    if (this.assignees != null) {
      data['assignees'] = this.assignees!.map((v) => v.toJson()).toList();
    }
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }
}
