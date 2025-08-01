import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum ScheduleType {
  call('call', 'Gọi điện', Icons.phone),
  meeting('meeting', 'Gặp gỡ', Icons.people),
  reminder('reminder', 'Nhắc nhở', Icons.notifications),
  meal('meal', 'Ăn uống', Icons.local_cafe),
  document('document', 'Tài liệu', Icons.description),
  video('video', 'Video', Icons.videocam),
  event('event', 'Sự kiện', Icons.event);

  const ScheduleType(this.id, this.name, this.icon);
  final String id;
  final String name;
  final IconData icon;

  static ScheduleType fromId(String id) {
    return values.firstWhere(
      (type) => type.id == id,
      orElse: () => ScheduleType.reminder,
    );
  }
}

enum Priority {
  low(0, 'Thấp', Colors.grey),
  medium(1, 'Trung bình', Colors.orange),
  high(2, 'Cao', Colors.red);

  const Priority(this.value, this.name, this.color);
  final int value;
  final String name;
  final Color color;

  static Priority fromValue(int value) {
    return values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => Priority.medium,
    );
  }
}

class ReminderConstants {
  static const String calendarBaseUrl = 'https://calendar.coka.ai';
  static const String scheduleEndpoint = '/api/Schedule';

  // Time options for notifications
  static List<Map<String, dynamic>> notifyBeforeOptions = [
    {'minutes': 0, 'label': 'on_time'.tr()},
    {'minutes': 5, 'label': '5 ${"minutes_ago".tr()} trước'},
    {'minutes': 10, 'label': '10 ${"minutes_ago".tr()} trước'},
    {'minutes': 15, 'label': '15 ${"minutes_ago".tr()} trước'},
    {'minutes': 30, 'label': '30 ${"minutes_ago".tr()} trước'},
    {'minutes': 60, 'label': '1 ${"hours_ago".tr()} trước'},
    {'minutes': 120, 'label': '2 ${"hours_ago".tr()} trước'},
    {'minutes': 1440, 'label': '1 ${"days_ago".tr()} trước'},
  ];

  // Default notification types
  static const List<String> notificationTypes = [
    'popup',
    'email',
    'sms',
  ];

  // Days of week for repeat rules
  static List<Map<String, dynamic>> weekDays = [
    {'day': 'monday', 'label': 'monday'.tr()},
    {'day': 'tuesday', 'label': 'tuesday'.tr()},
    {'day': 'wednesday', 'label': 'wednesday'.tr()},
    {'day': 'thursday', 'label': 'thursday'.tr()},
    {'day': 'friday', 'label': 'friday'.tr()},
    {'day': 'saturday', 'label': 'saturday'.tr()},
    {'day': 'sunday', 'label': 'sunday'.tr()},
  ];
}
