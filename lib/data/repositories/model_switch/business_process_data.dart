class TaskData {
  final String workspaceId;
  final String stageId;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String description;
  final String customerId; 
  final List<String> assignedTo;
  final String priority;
  final String notes;
  final List<String> tagIds;
  final List<SubTask> subTasks;

  TaskData({
    required this.workspaceId,
    required this.stageId,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.description,
    required this.customerId, 
    required this.assignedTo,
    required this.priority,
    required this.notes,
    required this.tagIds,
    required this.subTasks,
  });

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      workspaceId: json['workspaceId'] ?? '',
      stageId: json['stageId'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      customerId: json['customerId'] ?? '', 
      assignedTo: List<String>.from(json['assignedTo'] ?? []),
      priority: json['priority'] ?? '',
      notes: json['notes'] ?? '',
      tagIds: List<String>.from(json['tagIds'] ?? []),
      subTasks: (json['subTasks'] as List<dynamic>? ?? [])
          .map((e) => SubTask.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'workspaceId': workspaceId,
      'stageId': stageId,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'description': description,
      'customerId': customerId, 
      'assignedTo': assignedTo,
      'priority': priority,
      'notes': notes,
      'tagIds': tagIds,
      'subTasks': subTasks.map((e) => e.toJson()).toList(),
    };
    data.removeWhere((key, value) => value == "");
    return data;
  }
}

class SubTask {
  final String name;
  final String description;
  final String assignedTo;
  final DateTime startDate;
  final DateTime dueDate;
  final String priority;
  final String notes;
  final bool isRequired;
  final int orderIndex;

  SubTask({
    required this.name,
    required this.description,
    required this.assignedTo,
    required this.startDate,
    required this.dueDate,
    required this.priority,
    required this.notes,
    required this.isRequired,
    required this.orderIndex,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      assignedTo: json['assignedTo'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      dueDate: DateTime.parse(json['dueDate']),
      priority: json['priority'] ?? '',
      notes: json['notes'] ?? '',
      isRequired: json['isRequired'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'assignedTo': assignedTo,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'notes': notes,
      'isRequired': isRequired,
      'orderIndex': orderIndex,
    };
  }
}
