import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class TagResponse {
  final bool success;
  final String message;
  final List<TagModel> data;
  final dynamic pagination;

  TagResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory TagResponse.fromJson(Map<String, dynamic> json) {
    return TagResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((e) => TagModel.fromJson(e))
          .toList(),
      pagination: json['pagination'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination,
    };
  }
}

class TagModel extends ChipData {
  final String workspaceId;
  final String textColor;
  final String backgroundColor;

  TagModel({
    required String id,
    required String name,
    required this.workspaceId,
    required this.textColor,
    required this.backgroundColor,
  }) : super(id, name);

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      workspaceId: json['workspaceId'] ?? '',
      textColor: json['textColor'] ?? '',
      backgroundColor: json['backgroundColor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workspaceId': workspaceId,
      'textColor': textColor,
      'backgroundColor': backgroundColor,
    };
  }
}
