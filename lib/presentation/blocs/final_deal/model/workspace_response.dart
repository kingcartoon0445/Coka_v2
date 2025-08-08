import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

class WorkspaceResponse {
  int? code;
  List<WorkspaceModel>? content;

  WorkspaceResponse({this.code, this.content});

  WorkspaceResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <WorkspaceModel>[];
      json['content'].forEach((v) {
        content!.add(new WorkspaceModel.fromJson(v));
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

class WorkspaceModel extends ChipData {
  WorkspaceModel(super.id, super.name);

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(json['workspaceId'], json['workspaceName']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['workspaceId'] = this.id;
    data['workspaceName'] = this.name;
    return data;
  }
}
