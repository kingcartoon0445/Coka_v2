class ReminderServiceBody {
  String? id;
  String? startTime;
  String? endTime;
  List<RepeatRule>? repeatRule;
  String? title;
  String? content;
  bool? isReminder;
  bool? isDone;
  String? organizationId;
  List<Contact>? contact;
  String? notes;
  List<Reminders>? reminders;
  int? priority;
  String? schedulesType;
  List<RelatedProfiles>? relatedProfiles;
  String? workspaceId;

  ReminderServiceBody(
      {this.id,
      this.startTime,
      this.endTime,
      this.repeatRule,
      this.title,
      this.content,
      this.isReminder,
      this.isDone,
      this.organizationId,
      this.contact,
      this.notes,
      this.reminders,
      this.priority,
      this.schedulesType,
      this.relatedProfiles,
      this.workspaceId});

  ReminderServiceBody.fromJson(Map<String, dynamic> json) {
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    if (json['RepeatRule'] != null) {
      repeatRule = <RepeatRule>[];
      json['RepeatRule'].forEach((v) {
        repeatRule!.add(new RepeatRule.fromJson(v));
      });
    }
    title = json['Title'];
    content = json['Content'];
    isReminder = json['IsReminder'];
    isDone = json['IsDone'];
    organizationId = json['OrganizationId'];
    if (json['Contact'] != null) {
      contact = <Contact>[];
      json['Contact'].forEach((v) {
        contact!.add(new Contact.fromJson(v));
      });
    }
    notes = json['Notes'];
    if (json['Reminders'] != null) {
      reminders = <Reminders>[];
      json['Reminders'].forEach((v) {
        reminders!.add(new Reminders.fromJson(v));
      });
    }
    priority = json['Priority'];
    schedulesType = json['SchedulesType'];
    if (json['RelatedProfiles'] != null) {
      relatedProfiles = <RelatedProfiles>[];
      json['RelatedProfiles'].forEach((v) {
        relatedProfiles!.add(new RelatedProfiles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotNullOrEmpty(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      data[key] = value;
    }

    addIfNotNullOrEmpty('Id', this.id);
    addIfNotNullOrEmpty('StartTime', this.startTime);
    addIfNotNullOrEmpty('EndTime', this.endTime);

    if (this.repeatRule != null && this.repeatRule!.isNotEmpty) {
      final repeatRuleList = this.repeatRule!.map((v) => v.toJson()).toList();
      if (repeatRuleList.isNotEmpty) {
        data['RepeatRule'] = repeatRuleList;
      } else {
        data['RepeatRule'] = [];
      }
    } else {
      data['RepeatRule'] = [];
    }

    addIfNotNullOrEmpty('Title', this.title);
    addIfNotNullOrEmpty('Content', this.content);
    addIfNotNullOrEmpty('IsReminder', this.isReminder);
    addIfNotNullOrEmpty('IsDone', this.isDone);
    addIfNotNullOrEmpty('OrganizationId', this.organizationId);
    addIfNotNullOrEmpty('WorkspaceId', this.workspaceId);

    if (this.contact != null && this.contact!.isNotEmpty) {
      final contactList = this.contact!.map((v) => v.toJson()).toList();
      if (contactList.isNotEmpty) {
        data['Contact'] = contactList;
      } else {
        data['Contact'] = [];
      }
    } else {
      data['Contact'] = [];
    }

    addIfNotNullOrEmpty('Notes', this.notes);

    if (this.reminders != null && this.reminders!.isNotEmpty) {
      final remindersList = this.reminders!.map((v) => v.toJson()).toList();
      if (remindersList.isNotEmpty) {
        data['Reminders'] = remindersList;
      } else {
        data['Reminders'] = [];
      }
    } else {
      data['Reminders'] = [];
    }

    addIfNotNullOrEmpty('Priority', this.priority);
    addIfNotNullOrEmpty('SchedulesType', this.schedulesType);

    if (this.relatedProfiles != null && this.relatedProfiles!.isNotEmpty) {
      final relatedProfilesList =
          this.relatedProfiles!.map((v) => v.toJson()).toList();
      if (relatedProfilesList.isNotEmpty) {
        data['RelatedProfiles'] = relatedProfilesList;
      } else {
        data['RelatedProfiles'] = [];
      }
    } else {
      data['RelatedProfiles'] = [];
    }

    // Remove any key with value null or empty string (redundant, but for extra safety)
    data.removeWhere((key, value) =>
        value == null || (value is String && value.trim().isEmpty));

    return data;
  }
}

class RepeatRule {
  String? day;

  RepeatRule({this.day});

  RepeatRule.fromJson(Map<String, dynamic> json) {
    day = json['day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    return data;
  }
}

class Contact {
  String? id;
  String? phone;
  String? teamId;
  String? stageId;
  String? assignTo;
  String? fullName;
  List<String>? sourceId;
  List<String>? utmSource;
  String? createdDate;
  String? workspaceId;
  String? organizationId;
  CustomFields? customFields;

  Contact(
      {this.id,
      this.phone,
      this.teamId,
      this.stageId,
      this.assignTo,
      this.fullName,
      this.sourceId,
      this.utmSource,
      this.createdDate,
      this.workspaceId,
      this.organizationId,
      this.customFields});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    phone = json['Phone'];
    teamId = json['TeamId'];
    stageId = json['StageId'];
    assignTo = json['AssignTo'];
    fullName = json['FullName'];
    sourceId = json['SourceId'].cast<String>();
    utmSource = json['UtmSource'].cast<String>();
    createdDate = json['CreatedDate'];
    workspaceId = json['WorkspaceId'];
    organizationId = json['OrganizationId'];
    customFields = json['CustomFields'] != null
        ? new CustomFields.fromJson(json['CustomFields'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Phone'] = this.phone;
    data['TeamId'] = this.teamId;
    data['StageId'] = this.stageId;
    data['AssignTo'] = this.assignTo;
    data['FullName'] = this.fullName;
    data['SourceId'] = this.sourceId;
    data['UtmSource'] = this.utmSource;
    data['CreatedDate'] = this.createdDate;
    data['WorkspaceId'] = this.workspaceId;
    data['OrganizationId'] = this.organizationId;
    if (this.customFields != null) {
      data['CustomFields'] = this.customFields!.toJson();
    }
    return data;
  }
}

class CustomFields {
  String? additionalProp1;
  String? additionalProp2;
  String? additionalProp3;

  CustomFields(
      {this.additionalProp1, this.additionalProp2, this.additionalProp3});

  CustomFields.fromJson(Map<String, dynamic> json) {
    additionalProp1 = json['additionalProp1'];
    additionalProp2 = json['additionalProp2'];
    additionalProp3 = json['additionalProp3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['additionalProp1'] = this.additionalProp1;
    data['additionalProp2'] = this.additionalProp2;
    data['additionalProp3'] = this.additionalProp3;
    return data;
  }
}

class Reminders {
  String? time;

  Reminders({this.time});

  Reminders.fromJson(Map<String, dynamic> json) {
    time = json['Time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Time'] = this.time;
    return data;
  }
}

class RelatedProfiles {
  String? id;
  String? name;

  RelatedProfiles({this.id, this.name});

  RelatedProfiles.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    return data;
  }
}
