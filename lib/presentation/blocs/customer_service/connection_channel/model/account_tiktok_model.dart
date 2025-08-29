class AccountTiktokResponse {
  int? code;
  List<AccountTiktokModel>? content;

  AccountTiktokResponse({this.code, this.content});

  AccountTiktokResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <AccountTiktokModel>[];
      json['content'].forEach((v) {
        content!.add(new AccountTiktokModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.content != null) {
      data['content'] = this.content!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AccountTiktokModel {
  String? id;
  String? uid;
  String? title;
  String? name;
  int? status;
  String? createdBy;
  String? createdDate;

  AccountTiktokModel(
      {this.id,
      this.uid,
      this.title,
      this.name,
      this.status,
      this.createdBy,
      this.createdDate});

  AccountTiktokModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    title = json['title'];
    name = json['name'];
    status = json['status'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['title'] = this.title;
    data['name'] = this.name;
    data['status'] = this.status;
    data['createdBy'] = this.createdBy;
    data['createdDate'] = this.createdDate;
    return data;
  }
}
