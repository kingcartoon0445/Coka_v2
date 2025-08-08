import 'package:source_base/data/models/organization_model.dart';
export 'package:source_base/data/models/organization_model.dart';

class FacebookChatResponse {
  int? code;
  List<FacebookChatModel>? content;
  Metadata? metadata;

  FacebookChatResponse({this.code, this.content, this.metadata});

  FacebookChatResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <FacebookChatModel>[];
      json['content'].forEach((v) {
        content!.add(new FacebookChatModel.fromJson(v));
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

class FacebookChatModel {
  String? id;
  String? integrationAuthId;
  String? conversationId;
  String? pageId;
  String? pageName;
  String? pageAvatar;
  String? personId;
  String? personName;
  String? personAvatar;
  String? snippet;
  int? unreadCount;
  bool? canReply;
  int? updatedTime;
  int? gptStatus;
  bool? isRead;
  String? type;
  String? provider;
  int? status;
  Contact? contact;
  int? messageCount;
  String? assignTo;
  String? assignName;
  String? assignAvatar;

  FacebookChatModel(
      {this.id,
      this.integrationAuthId,
      this.conversationId,
      this.pageId,
      this.pageName,
      this.pageAvatar,
      this.personId,
      this.personName,
      this.personAvatar,
      this.snippet,
      this.unreadCount,
      this.canReply,
      this.updatedTime,
      this.gptStatus,
      this.isRead,
      this.type,
      this.provider,
      this.status,
      this.contact,
      this.messageCount,
      this.assignTo,
      this.assignName,
      this.assignAvatar});

  FacebookChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    integrationAuthId = json['integrationAuthId'];
    conversationId = json['conversationId'];
    pageId = json['pageId'];
    pageName = json['pageName'];
    pageAvatar = json['pageAvatar'];
    personId = json['personId'];
    personName = json['personName'];
    personAvatar = json['personAvatar'];
    snippet = json['snippet'];
    unreadCount = json['unreadCount'];
    canReply = json['canReply'];
    updatedTime = json['updatedTime'];
    gptStatus = json['gptStatus'];
    isRead = json['isRead'];
    type = json['type'];
    provider = json['provider'];
    status = json['status'];
    contact =
        json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
    messageCount = json['messageCount'];
    assignTo = json['assignTo'];
    assignName = json['assignName'];
    assignAvatar = json['assignAvatar'];
  }
  FacebookChatModel.fromFirebase(Map<String, dynamic> json) {
    id = json['Id'] ?? '';
    integrationAuthId = json['IntegrationAuthId'] ?? '';
    conversationId = json['ConversationId'] ?? '';
    pageId = json['From'] ?? '';
    pageName = json['FromName'] ?? '';
    pageAvatar = json['Avatar'] ?? '';
    personId = json['To'] ?? '';
    personName = json['ToName'] ?? '';
    personAvatar = json['Avatar'] ?? '';
    snippet = json['Message'] ?? '';
    unreadCount = 0;
    canReply = true;
    updatedTime = json['Timestamp'] ?? 0;
    gptStatus = json['IsGpt'] == true ? 1 : 0;
    isRead = false;
    type = json['Type'] ?? '';
    provider = 'facebook';
    status = json['Status'] ?? 1;

    contact = null;
    messageCount = 0;
    assignTo = '';
    assignName = '';
    assignAvatar = '';
  }
  FacebookChatModel copyWith({
    String? id,
    String? integrationAuthId,
    String? conversationId,
    String? pageId,
    String? pageName,
    String? pageAvatar,
    String? personId,
    String? personName,
    String? personAvatar,
    String? snippet,
    int? unreadCount,
    bool? canReply,
    int? updatedTime,
    int? gptStatus,
    bool? isRead,
    String? type,
    String? provider,
    int? status,
    Contact? contact,
    int? messageCount,
    String? assignTo,
    String? assignName,
    String? assignAvatar,
  }) {
    return FacebookChatModel(
      id: id ?? this.id,
      integrationAuthId: integrationAuthId ?? this.integrationAuthId,
      conversationId: conversationId ?? this.conversationId,
      pageId: pageId ?? this.pageId,
      pageName: pageName ?? this.pageName,
      pageAvatar: pageAvatar ?? this.pageAvatar,
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      personAvatar: personAvatar ?? this.personAvatar,
      snippet: snippet ?? this.snippet,
      unreadCount: unreadCount ?? this.unreadCount,
      canReply: canReply ?? this.canReply,
      updatedTime: updatedTime ?? this.updatedTime,
      gptStatus: gptStatus ?? this.gptStatus,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      contact: contact ?? this.contact,
      messageCount: messageCount ?? this.messageCount,
      assignTo: assignTo ?? this.assignTo,
      assignName: assignName ?? this.assignName,
      assignAvatar: assignAvatar ?? this.assignAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['integrationAuthId'] = this.integrationAuthId;
    data['conversationId'] = this.conversationId;
    data['pageId'] = this.pageId;
    data['pageName'] = this.pageName;
    data['pageAvatar'] = this.pageAvatar;
    data['personId'] = this.personId;
    data['personName'] = this.personName;
    data['personAvatar'] = this.personAvatar;
    data['snippet'] = this.snippet;
    data['unreadCount'] = this.unreadCount;
    data['canReply'] = this.canReply;
    data['updatedTime'] = this.updatedTime;
    data['gptStatus'] = this.gptStatus;
    data['isRead'] = this.isRead;
    data['type'] = this.type;
    data['provider'] = this.provider;
    data['status'] = this.status;
    if (this.contact != null) {
      data['contact'] = this.contact!.toJson();
    }
    data['messageCount'] = this.messageCount;
    data['assignTo'] = this.assignTo;
    data['assignName'] = this.assignName;
    data['assignAvatar'] = this.assignAvatar;
    return data;
  }
}

class Contact {
  String? workspaceId;
  String? workspaceName;
  String? contactId;
  String? contactName;
  String? contactPhone;
  String? contactEmail;

  Contact(
      {this.workspaceId,
      this.workspaceName,
      this.contactId,
      this.contactName,
      this.contactPhone,
      this.contactEmail});

  Contact.fromJson(Map<String, dynamic> json) {
    workspaceId = json['workspaceId'];
    workspaceName = json['workspaceName'];
    contactId = json['contactId'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['workspaceId'] = this.workspaceId;
    data['workspaceName'] = this.workspaceName;
    data['contactId'] = this.contactId;
    data['contactName'] = this.contactName;
    data['contactPhone'] = this.contactPhone;
    data['contactEmail'] = this.contactEmail;
    return data;
  }
}
