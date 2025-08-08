import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String pageId;
  final String pageName;
  final String? pageAvatar;
  final String personId;
  final String personName;
  final String? personAvatar;
  final String snippet;
  final bool canReply;
  final bool isFileMessage;
  final DateTime updatedTime;
  final int gptStatus;
  final bool isRead;
  final String type;
  final String provider;
  final String status;
  final String? assignName;
  final String? assignAvatar;

  // Getter để đơn giản hóa việc lấy avatar
  String? get avatar => personAvatar;

  const Conversation({
    required this.id,
    required this.pageId,
    required this.pageName,
    this.isFileMessage = false,
    this.pageAvatar,
    required this.personId,
    required this.personName,
    this.personAvatar,
    required this.snippet,
    required this.canReply,
    required this.updatedTime,
    required this.gptStatus,
    required this.isRead,
    required this.type,
    required this.provider,
    required this.status,
    this.assignName,
    this.assignAvatar,
  });

  Conversation copyWith({
    String? assignName,
    String? assignAvatar,
    String? snippet,
    bool? isRead,
    bool? isFileMessage,
  }) {
    return Conversation(
      id: id,
      pageId: pageId,
      pageName: pageName,
      pageAvatar: pageAvatar,
      personId: personId,
      personName: personName,
      personAvatar: personAvatar,
      snippet: snippet ?? this.snippet,
      canReply: canReply,
      updatedTime: updatedTime,
      gptStatus: gptStatus,
      isRead: isRead ?? this.isRead,
      type: type,
      isFileMessage: isFileMessage ?? this.isFileMessage,
      provider: provider,
      status: status,
      assignName: assignName ?? this.assignName,
      assignAvatar: assignAvatar ?? this.assignAvatar,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      // Convert timestamp to DateTime
      final timestamp = json['updatedTime'] is int
          ? json['updatedTime']
          : int.tryParse(json['updatedTime']?.toString() ?? '') ??
              DateTime.now().millisecondsSinceEpoch;

      return Conversation(
        id: json['id']?.toString() ?? '',
        pageId: json['pageId']?.toString() ?? '',
        isFileMessage: json["snippet"] == null,
        pageName: json['pageName']?.toString() ?? '',
        pageAvatar: json['pageAvatar']?.toString(),
        personId: json['personId']?.toString() ?? '',
        personName: json['personName']?.toString() ?? '',
        personAvatar: json['personAvatar']?.toString(),
        snippet: json['snippet']?.toString() ?? '',
        canReply: json['canReply'] ?? false,
        updatedTime: DateTime.fromMillisecondsSinceEpoch(timestamp),
        gptStatus: json['gptStatus'] is int ? json['gptStatus'] : 0,
        isRead: json['isRead'] ?? false,
        type: json['type']?.toString() ?? 'MESSAGE',
        provider: json['provider']?.toString() ?? 'ZALO',
        status: json['status']?.toString() ?? '',
        assignName: json['assignName']?.toString(),
        assignAvatar: json['assignAvatar']?.toString(),
      );
    } catch (e) {
      print('Error parsing conversation: $json');
      print('Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageId': pageId,
      'pageName': pageName,
      'pageAvatar': pageAvatar,
      'personId': personId,
      'personName': personName,
      'personAvatar': personAvatar,
      'snippet': snippet,
      'canReply': canReply,
      'isFileMessage': isFileMessage,
      'updatedTime': updatedTime.millisecondsSinceEpoch,
      'gptStatus': gptStatus,
      'isRead': isRead,
      'type': type,
      'provider': provider,
      'status': status,
      'assignName': assignName,
      'assignAvatar': assignAvatar,
    };
  }

  @override
  List<Object?> get props => [
        id,
        pageId,
        pageName,
        pageAvatar,
        personId,
        personName,
        personAvatar,
        snippet,
        canReply,
        isFileMessage,
        updatedTime,
        gptStatus,
        isRead,
        type,
        provider,
        status,
        assignName,
        assignAvatar,
      ];
}
