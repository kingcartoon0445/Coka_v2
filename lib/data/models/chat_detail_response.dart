import 'package:source_base/presentation/screens/chat_detail_page/model/message_model.dart';

class ChatDetailResponse {
  int? code;
  List<Message>? content;
  Metadata? metadata;

  ChatDetailResponse({this.code, this.content, this.metadata});

  ChatDetailResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <Message>[];
      json['content'].forEach((v) {
        content!.add(Message.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['code'] = this.code;
  //   if (this.content != null) {
  //       data['content'] = this.content!.map((v) => v..()).toList();
  //   }
  //   if (this.metadata != null) {
  //     data['metadata'] = this.metadata!.toJson();
  //   }
  //   return data;
  // }
}

// class ChatDetail {
//   String? id;
//   String? integrationAuthId;
//   String? conversationId;
//   String? socialConversationId;
//   String? messageId;
//   int? timestamp;
//   String? from;
//   String? fromName;
//   String? to;
//   String? toName;
//   String? message;
//   bool? isGpt;
//   String? fullName;
//   String? avatar;
//   String? profileId;
//   bool? isPageReply;
//   int? status;
//   String? json;
//   String? createdBy;
//   String? createdDate;
//   String? lastModifiedBy;
//   String? lastModifiedDate;
//   String? attachments;
//   String? type;

//   ChatDetail(
//       {this.id,
//       this.integrationAuthId,
//       this.conversationId,
//       this.socialConversationId,
//       this.messageId,
//       this.timestamp,
//       this.from,
//       this.fromName,
//       this.to,
//       this.toName,
//       this.message,
//       this.isGpt,
//       this.fullName,
//       this.avatar,
//       this.profileId,
//       this.isPageReply,
//       this.status,
//       this.json,
//       this.createdBy,
//       this.createdDate,
//       this.lastModifiedBy,
//       this.lastModifiedDate,
//       this.attachments,
//       this.type});

//   ChatDetail.fromJson(Map<String, dynamic> jsonToMap) {
//     id = jsonToMap['id'];
//     integrationAuthId = jsonToMap['integrationAuthId'];
//     conversationId = jsonToMap['conversationId'];
//     socialConversationId = jsonToMap['socialConversationId'];
//     messageId = jsonToMap['messageId'];
//     timestamp = jsonToMap['timestamp'];
//     from = jsonToMap['from'];
//     fromName = jsonToMap['fromName'];
//     to = jsonToMap['to'];
//     toName = jsonToMap['toName'];
//     message = jsonToMap['message'];
//     isGpt = jsonToMap['isGpt'];
//     fullName = jsonToMap['fullName'];
//     avatar = jsonToMap['avatar'];
//     profileId = jsonToMap['profileId'];
//     isPageReply = jsonToMap['isPageReply'];
//     status = jsonToMap['status'];
//     json = jsonToMap['json'];
//     createdBy = jsonToMap['createdBy'];
//     createdDate = jsonToMap['createdDate'];
//     lastModifiedBy = jsonToMap['lastModifiedBy'];
//     lastModifiedDate = jsonToMap['lastModifiedDate'];
//     attachments = jsonToMap['attachments'];
//     type = jsonToMap['type'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['integrationAuthId'] = this.integrationAuthId;
//     data['conversationId'] = this.conversationId;
//     data['socialConversationId'] = this.socialConversationId;
//     data['messageId'] = this.messageId;
//     data['timestamp'] = this.timestamp;
//     data['from'] = this.from;
//     data['fromName'] = this.fromName;
//     data['to'] = this.to;
//     data['toName'] = this.toName;
//     data['message'] = this.message;
//     data['isGpt'] = this.isGpt;
//     data['fullName'] = this.fullName;
//     data['avatar'] = this.avatar;
//     data['profileId'] = this.profileId;
//     data['isPageReply'] = this.isPageReply;
//     data['status'] = this.status;
//     data['json'] = this.json;
//     data['createdBy'] = this.createdBy;
//     data['createdDate'] = this.createdDate;
//     data['lastModifiedBy'] = this.lastModifiedBy;
//     data['lastModifiedDate'] = this.lastModifiedDate;
//     data['attachments'] = this.attachments;
//     data['type'] = this.type;
//     return data;
//   }
// }

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
