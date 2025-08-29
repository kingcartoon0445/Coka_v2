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
  String? fullName;
  String? email;
  String? phone;
  String? rawPhone;
  int? gender;
  String? dob;
  int? maritalStatus;
  String? address;
  int? rating;
  String? work;
  String? physicalId;
  String? flowStep;
  String? companyId;
  Customer? customer;
  Deal? deal;
  List<String>? source;
  List<String>? utmSource;
  List<String>? device;
  List<String>? tags;
  List<Assignees>? assignees;
  String? createdDate;
  String? lastModifiedDate;

  CustomerDetailModel(
      {this.id,
      this.fullName,
      this.email,
      this.phone,
      this.rawPhone,
      this.gender,
      this.dob,
      this.maritalStatus,
      this.address,
      this.rating,
      this.work,
      this.physicalId,
      this.flowStep,
      this.companyId,
      this.customer,
      this.deal,
      this.source,
      this.utmSource,
      this.device,
      this.tags,
      this.assignees,
      this.createdDate,
      this.lastModifiedDate});

  CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phone = json['phone'];
    rawPhone = json['rawPhone'];
    gender = json['gender'];
    dob = json['dob'];
    maritalStatus = json['maritalStatus'];
    address = json['address'];
    rating = json['rating'];
    work = json['work'];
    physicalId = json['physicalId'];
    flowStep = json['flowStep'];
    companyId = json['companyId'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    tags = [];
    for (var item in json['tags']) {
      tags!.add(item.toString());
    }
    print(tags);
    // deal = json['deal'] != null ? new Deal.fromJson(json['deal']) : null;
    // source = json['source'];
    // utmSource = json['utmSource'];
    if (json['device'] != null) {
      device = <String>[];
      json['device'].forEach((v) {
        device!.add(v);
      });
    }
    // tags = json['tags'];
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
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['rawPhone'] = this.rawPhone;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['maritalStatus'] = this.maritalStatus;
    data['address'] = this.address;
    data['rating'] = this.rating;
    data['work'] = this.work;
    data['physicalId'] = this.physicalId;
    data['flowStep'] = this.flowStep;
    data['companyId'] = this.companyId;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    if (this.deal != null) {
      data['deal'] = this.deal!.toJson();
    }
    data['source'] = this.source;
    data['utmSource'] = this.utmSource;
    if (this.device != null) {
      data['device'] = this.device!.map((v) => v).toList();
    }
    data['tags'] = this.tags;
    if (this.assignees != null) {
      data['assignees'] = this.assignees!.map((v) => v.toJson()).toList();
    }
    data['createdDate'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }
}

class Customer {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  int? gender;
  String? dob;
  String? physicalId;
  String? address;
  String? work;
  List<String>? tags;

  Customer(
      {this.id,
      this.fullName,
      this.email,
      this.phone,
      this.gender,
      this.dob,
      this.physicalId,
      this.address,
      this.work,
      this.tags});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phone = json['phone'];
    gender = json['gender'];
    dob = json['dob'];
    physicalId = json['physicalId'];
    address = json['address'];
    work = json['work'];
    if (json['tags'] != null) {
      tags = <String>[];
      json['tags'].forEach((v) {
        tags!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['physicalId'] = this.physicalId;
    data['address'] = this.address;
    data['work'] = this.work;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v).toList();
    }
    return data;
  }
}

class Deal {
  String? id;
  String? leadId;
  String? customerId;
  String? name;
  String? email;
  String? phone;
  String? description;
  String? priority;

  Deal(
      {this.id,
      this.leadId,
      this.customerId,
      this.name,
      this.email,
      this.phone,
      this.description,
      this.priority});

  Deal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    leadId = json['leadId'];
    customerId = json['customerId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    description = json['description'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['leadId'] = this.leadId;
    data['customerId'] = this.customerId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['description'] = this.description;
    data['priority'] = this.priority;
    return data;
  }
}
