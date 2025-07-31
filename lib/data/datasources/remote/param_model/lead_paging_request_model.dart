// 1. Model classes

class CustomCondition {
  final String field;
  final String operator;
  final String value;

  CustomCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory CustomCondition.fromJson(Map<String, dynamic> json) {
    return CustomCondition(
      field: json['field'],
      operator: json['operator'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'field': field,
        'operator': operator,
        'value': value,
      };
}

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
  // final List<CustomCondition> customConditions;

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
    // required this.customConditions,
  });

  factory LeadPagingRequest.fromJson(Map<String, dynamic> json) {
    return LeadPagingRequest(
      searchText: json['searchText'] as String,
      limit: json['limit'] as int,
      fields: List<String>.from(json['fields']),
      offset: json['offset'] as int,
      status: json['status'] as int,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      stageIds: List<String>.from(json['stageIds']),
      sourceIds: List<String>.from(json['sourceIds']),
      utmSources: List<String>.from(json['utmSources']),
      ratings: List<int>.from(json['ratings']),
      teamIds: List<String>.from(json['teamIds']),
      assignees: List<String>.from(json['assignees']),
      tags: List<String>.from(json['tags']),
      isBusiness: json['isBusiness'] as bool,
      isArchive: json['isArchive'] as bool,
      // customConditions: (json['customConditions'] as List)
      //     .map((e) => CustomCondition.fromJson(e))
      //     .toList(),
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
    };

    // 2. Loại bỏ tất cả key có value == null
    map.removeWhere((key, value) => value == null);

    return map;
  }
}

// 2. Cập nhật hàm getCustomerService
