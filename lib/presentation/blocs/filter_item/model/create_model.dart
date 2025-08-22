class CreateLeadModel {
  String? fullName;
  String? title;
  String? phone;
  String? email;
  String? sourceId;
  String? utmSource;
  bool? isBusiness;
  List<String>? tags;
  List<String>? assignees;
  String? companyId;

  CreateLeadModel(
      {this.fullName,
      this.title,
      this.phone,
      this.email,
      this.sourceId,
      this.utmSource,
      this.isBusiness,
      this.tags,
      this.assignees,
      this.companyId});

  CreateLeadModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    title = json['title'];
    phone = json['phone'];
    email = json['email'];
    sourceId = json['sourceId'];
    utmSource = json['utmSource'];
    isBusiness = json['isBusiness'];
    tags = json['tags'].cast<String>();
    assignees = json['assignees'].cast<String>();
    companyId = json['companyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['title'] = this.title;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['sourceId'] = this.sourceId;
    data['utmSource'] = this.utmSource;
    data['isBusiness'] = this.isBusiness;
    data['tags'] = this.tags;
    data['assignees'] = this.assignees;
    data['companyId'] = this.companyId;
    return data;
  }
}
