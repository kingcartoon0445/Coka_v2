import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Nếu điều hướng bằng Navigator, import navigatorKey từ main/app của bạn
// import 'package:source_base/main.dart' show navigatorKey;

class Noti {
  /// Gọi khi user tap local notification (foreground/background)
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    // Dồn về cùng 1 chỗ xử lý để bạn có thể tự gọi bằng payload string
    handlePayload(response.payload, isBackground: true);
  }

  /// Cho phép bạn TỰ GỌI logic tap chỉ bằng payload string
  static Future<void> handlePayload(String? payload,
      {bool isBackground = false}) async {
    try {
      // Đảm bảo có thời gian cho Navigator/route sẵn sàng
      scheduleMicrotask(() async {
        final prefs = await SharedPreferences.getInstance();
        final outer = _safeDecodeMap(payload);

        print("Firebase Notification outer: $outer");

        final category = (outer['category'] ?? '').toString();
        final metadata = _safeDecodeMap(outer['metadata']);

        debugPrint(
            'NOTI TAP | category=$category | metadata=$metadata | bg=$isBackground');

        // TODO: Điều hướng theo category (Navigator hoặc GetX)
        // switch (category) {
        //   case 'ADD_USER_TEAM':
        //     navigatorKey.currentState?.pushNamed('/workspaceMain');
        //     break;
        //   case 'ASSIGN_CONTACT':
        //     navigatorKey.currentState?.pushNamed('/workspaceMain', arguments: {'defaultIndex': 1});
        //     break;
        //   // ...
        //   default:
        //     break;
        // }
      });
    } catch (e, st) {
      debugPrint('NOTI handlePayload error: $e\n$st');
    }
  }

  /// Dùng cho FCM: khi user nhấn FCM notification → mở app
  /// Bạn có thể gọi từ FirebaseMessaging.onMessageOpenedApp
  static Future<void> handleFromFirebaseMessage(
      dynamic remoteMessageLike) async {
    // remoteMessageLike cần có: .data, .notification?.title/body (nếu muốn)
    try {
      final data =
          Map<String, dynamic>.from(remoteMessageLike.data ?? const {});
      final payload = jsonEncode({
        'category': (data['category'] ?? '').toString(),
        'metadata': jsonEncode(data),
      });
      await handlePayload(payload, isBackground: false);
    } catch (e) {
      debugPrint('handleFromFirebaseMessage error: $e');
    }
  }

  /// Khởi tạo plugin + gắn callback tap
  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: Noti.notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse:
          Noti.notificationTapBackground,
    );
  }

  /// Gọi sớm trong main sau khi initialize plugin:
  /// xử lý trường hợp app mở từ notification (cold start)
  static Future<void> processInitialLaunch(
      FlutterLocalNotificationsPlugin plugin) async {
    final details = await plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final resp = details!.notificationResponse;
      if (resp != null) {
        notificationTapBackground(resp); // tái dùng logic
      }
    }
  }

  /// Decode string -> Map (an toàn)
  static Map<String, dynamic> _safeDecodeMap(dynamic value) {
    try {
      if (value is Map<String, dynamic>) return value;
      if (value is String && value.isNotEmpty) {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }
}
