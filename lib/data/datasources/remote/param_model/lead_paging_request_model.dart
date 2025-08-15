import 'package:source_base/presentation/screens/home/widget/filter_modal.dart';

class LeadPagingRequest {
  final String? searchText;
  final int limit;
  final List<String>? fields;
  final int offset;
  final int? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? stageIds;
  final List<String>? sourceIds;
  final List<String>? utmSources;
  final List<int>? ratings;
  final List<String>? teamIds;
  final List<String>? assignees;
  final List<String>? tags;
  final bool? isBusiness;
  final bool? isArchive;
  final List<Condition>? customConditions;

  LeadPagingRequest({
    this.searchText,
    required this.limit,
    this.fields,
    required this.offset,
    this.status,
    this.startDate,
    this.endDate,
    this.stageIds,
    this.sourceIds,
    this.utmSources,
    this.ratings,
    this.teamIds,
    this.assignees,
    this.tags,
    this.isBusiness,
    this.isArchive,
    this.customConditions,
  });

  factory LeadPagingRequest.fromJson(Map<String, dynamic> json) {
    return LeadPagingRequest(
      searchText: json['searchText'] as String?,
      limit: json['limit'] as int,
      fields: json['fields'] != null ? List<String>.from(json['fields']) : null,
      offset: json['offset'] as int,
      status: json['status'] as int?,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      stageIds:
          json['stageIds'] != null ? List<String>.from(json['stageIds']) : null,
      sourceIds: json['sourceIds'] != null
          ? List<String>.from(json['sourceIds'])
          : null,
      utmSources: json['utmSources'] != null
          ? List<String>.from(json['utmSources'])
          : null,
      ratings: json['ratings'] != null ? List<int>.from(json['ratings']) : null,
      teamIds:
          json['teamIds'] != null ? List<String>.from(json['teamIds']) : null,
      assignees: json['assignees'] != null
          ? List<String>.from(json['assignees'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isBusiness: json['isBusiness'] as bool?,
      isArchive: json['isArchive'] as bool?,
      customConditions: (json['customConditions'] as List)
          .map((e) => Condition.fromJson(e))
          .toList(),
    );
  }

  LeadPagingRequest copyWith({
    String? searchText,
    int? limit,
    List<String>? fields,
    int? offset,
    int? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? stageIds,
    List<String>? sourceIds,
    List<String>? utmSources,
    List<int>? ratings,
    List<String>? teamIds,
    List<String>? assignees,
    List<String>? tags,
    bool? isBusiness,
    bool? isArchive,
    List<Condition>? customConditions,
  }) {
    return LeadPagingRequest(
      searchText: searchText ?? this.searchText,
      limit: limit ?? this.limit,
      fields: fields ?? this.fields,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      stageIds: stageIds ?? this.stageIds,
      sourceIds: sourceIds ?? this.sourceIds,
      utmSources: utmSources ?? this.utmSources,
      ratings: ratings ?? this.ratings,
      teamIds: teamIds ?? this.teamIds,
      assignees: assignees ?? this.assignees,
      tags: tags ?? this.tags,
      isBusiness: isBusiness ?? this.isBusiness,
      isArchive: isArchive ?? this.isArchive,
      customConditions: customConditions ?? this.customConditions,
    );
  }

  Map<String, dynamic> toJson() {
    // 1. Khởi tạo map với mọi trường (bao gồm null)
    final map = <String, dynamic>{
      'searchText': searchText,
      'limit': limit,
      'fields': fields,
      'offset': offset,
      'status': status,
      'startDate': startDate?.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'stageIds': stageIds,
      'sourceIds': sourceIds,
      'utmSources': utmSources,
      'ratings': ratings,
      'teamIds': teamIds,
      'assignees': assignees,
      'tags': tags,
      'isBusiness': isBusiness,
      'isArchive': isArchive,
      'customCondition': customConditions?.map((e) => e.toJson()).toList(),
    };

    // 2. Loại bỏ tất cả key có value == null
    map.removeWhere((key, value) => value == null);

    return map;
  }
}

// 2. Cập nhật hàm getCustomerService
