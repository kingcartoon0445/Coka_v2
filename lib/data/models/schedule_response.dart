import 'package:source_base/data/models/reminder.dart';
import 'package:source_base/data/models/reminder_service_body.dart';

class ScheduleResponse {
  List<ScheduleModel>? data;
  int? statusCode;
  String? status;
  String? message;

  ScheduleResponse({this.data, this.statusCode, this.status, this.message});

  ScheduleResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <ScheduleModel>[];
      json['Data'].forEach((v) {
        data!.add(new ScheduleModel.fromJson(v));
      });
    }
    statusCode = json['StatusCode'];
    status = json['Status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['StatusCode'] = this.statusCode;
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}

class ScheduleModel {
  String? id;
  String? type;
  String? startTime;
  String? endTime;
  List<RepeatRule>? repeatRule;
  String? title;
  String? content;
  String? createdAt;
  String? createdBy;
  bool? isDeleted;
  String? organizationId;
  String? profileId;
  String? contact;
  bool? isDone;
  String? schedulesType;
  String? relatedProfiles;
  List<Reminder>? reminders;
  int? priority;

  ScheduleModel(
      {this.id,
      this.type,
      this.startTime,
      this.endTime,
      this.repeatRule,
      this.title,
      this.content,
      this.createdAt,
      this.createdBy,
      this.isDeleted,
      this.organizationId,
      this.profileId,
      this.contact,
      this.isDone,
      this.schedulesType,
      this.relatedProfiles,
      this.reminders,
      this.priority});

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    type = json['Type'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    if (json['RepeatRule'] != null) {
      repeatRule = [];
      json['RepeatRule'].forEach((v) {
        repeatRule!.add(RepeatRule.fromJson(v));
      });
    }
    title = json['Title'];
    content = json['Content'];
    createdAt = json['CreatedAt'];
    createdBy = json['CreatedBy'];
    isDeleted = json['IsDeleted'];
    organizationId = json['OrganizationId'];
    profileId = json['ProfileId'];
    contact = json['Contact'];
    isDone = json['IsDone'];
    schedulesType = json['SchedulesType'];
    relatedProfiles = json['RelatedProfiles'];
    if (json['Reminders'] != null) {
      reminders = <Reminder>[];
      json['Reminders'].forEach((v) {
        reminders!.add(new Reminder.fromJson(v));
      });
    }
    priority = json['Priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Type'] = this.type;
    data['StartTime'] = this.startTime;
    data['EndTime'] = this.endTime;
    if (this.repeatRule != null) {
      data['RepeatRule'] = this.repeatRule!.map((v) => v.toJson()).toList();
    }
    data['Title'] = this.title;
    data['Content'] = this.content;
    data['CreatedAt'] = this.createdAt;
    data['CreatedBy'] = this.createdBy;
    data['IsDeleted'] = this.isDeleted;
    data['OrganizationId'] = this.organizationId;
    data['ProfileId'] = this.profileId;
    data['Contact'] = this.contact;
    data['IsDone'] = this.isDone;
    data['SchedulesType'] = this.schedulesType;
    data['RelatedProfiles'] = this.relatedProfiles;
    if (this.reminders != null) {
      data['Reminders'] = this.reminders!.map((v) => v.toJson()).toList();
    }
    data['Priority'] = this.priority;
    return data;
  }
}
