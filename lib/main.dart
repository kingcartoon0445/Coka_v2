// main.dart
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:source_base/app.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/models/notification_repository.dart';
import 'package:source_base/dio/service_locator.dart';

// ✅ chỉnh đường dẫn theo vị trí file Noti của bạn
import 'package:source_base/noti.dart';

// ✅ chỉnh đường dẫn theo code của bạn (ví dụ trước đó là package:coka/...)
// import 'package:coka/api/user.dart';           // nếu UserApi nằm trong coka
// import 'package:coka/constants.dart';          // nếu getDeviceId/getVersion ở đây
// ---------- GLOBALS ----------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'coka_notification',
  'coka_notification',
  description: 'Default notification channel',
  importance: Importance.max,
  playSound: true,
  // ❗️Xoá nếu chưa có file raw/notify
  sound: RawResourceAndroidNotificationSound("notify"),
);

// ---------- BACKGROUND HANDLER ----------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Hệ điều hành sẽ tự hiện nếu có 'notification' → tránh show lần 2
  if (message.notification != null) return;

  await _showLocalFromMessage(message);
}

// ---------- SHOW LOCAL (dùng chung) ----------
Future<void> _showLocalFromMessage(RemoteMessage m) async {
  final title = m.notification?.title ?? m.data['title']?.toString();
  final body = m.notification?.body ?? m.data['body']?.toString();
  final category = (m.data['category'] ?? '').toString();

  // Noti.notificationTapBackground decode payload dạng:
  // { "category": "...", "metadata": "<JSON string>" }
  final payload = jsonEncode({
    'category': category,
    'metadata': jsonEncode(m.data),
  });

  const android = AndroidNotificationDetails(
    'coka_notification',
    'coka_notification',
    channelDescription: 'Check',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    // ❗️Xoá nếu chưa có file raw/notify
    sound: RawResourceAndroidNotificationSound("notify"),
  );
  const ios = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(android: android, iOS: ios),
    payload: payload,
  );
}

// ---------- FCM TOKEN: sendToken + refresh ----------
Future<void> _sendToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('FCM token null/empty — bỏ qua gửi token.');
      return;
    }
    await _updateTokenToServer(token);
  } catch (e, st) {
    debugPrint('Lỗi lấy FCM token: $e\n$st');
  }
}

Future<void> _updateTokenToServer(String token) async {
  try {
    final deviceId = await AppConstants().getDeviceId();
    final version = await AppConstants().getVersion();

    // FCM token (cái này GỬI LÊN server)
    final String? fcmToken = await FirebaseMessaging.instance.getToken();

    // Access token (cái này để gắn vào header Authorization)
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString(PrefKey.accessToken);

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('Không có accessToken → bỏ qua cập nhật FCM token.');
      return;
    }
    if (fcmToken == null || fcmToken.isEmpty) {
      debugPrint('Chưa có FCM token → bỏ qua cập nhật.');
      return;
    }

    final dio = Dio(BaseOptions(
      baseUrl: DioClient.baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      validateStatus: (code) =>
          code != null && code < 500, // cho phép bắt 4xx mà không ném exception
    ));

    // 1) Thử POST không có trailing slash
    Response res = await dio.put(
      "/api/v1/user/fcm",
      data: {
        "deviceId": deviceId,
        "version": version,
        "fcmToken": fcmToken,
        "status": 1,
      },
    );

    // 2) Nếu vẫn 405 hoặc 404, thử lại với trailing slash (phòng trường hợp backend yêu cầu)
    if (res.statusCode == 405 || res.statusCode == 404) {
      res = await dio.put(
        "/api/v1/user/fcm/",
        data: {
          "deviceId": deviceId,
          "version": version,
          "fcmToken": fcmToken,
          "status": 1,
        },
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      debugPrint('updateFcmToken OK: ${res.data}');
    } else if (res.statusCode == 401) {
      debugPrint('401 Unauthorized: accessToken hết hạn? Cần refresh token.');
    } else {
      debugPrint('updateFcmToken thất bại [${res.statusCode}]: ${res.data}');
    }
  } catch (e, st) {
    debugPrint('updateFcmToken lỗi: $e\n$st');
  }
}

// ---------- BOOTSTRAP ----------
Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Local notifications + callback tap
  await Noti.initialize(flutterLocalNotificationsPlugin);

  // Channel + quyền Android 13+
  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(_channel);
  await androidPlugin?.requestNotificationsPermission();

  // Xử lý cold start mở từ notification
  await Noti.processInitialLaunch(flutterLocalNotificationsPlugin);

  // FCM: quyền + hành vi
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  // iOS: cho phép iOS tự hiện noti khi foreground (nếu payload có 'notification')
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Foreground: tránh double trên iOS nếu HĐH đã tự hiện (có 'notification')
  FirebaseMessaging.onMessage.listen((m) async {
    if (Platform.isIOS && m.notification != null) {
      return; // iOS đã tự hiện do setForegroundNotificationPresentationOptions(alert:true)
    }
    await _showLocalFromMessage(m); // Android foreground hoặc data-only
  });

  // User tap FCM noti để mở app (không qua plugin local)
  FirebaseMessaging.onMessageOpenedApp.listen((m) {
    Noti.handleFromFirebaseMessage(m);
  });

  // Background/terminated
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 GỬI TOKEN NGAY & THEO DÕI REFRESH
  await _sendToken(); // lấy token hiện tại và gửi lên server
  FirebaseMessaging.instance.onTokenRefresh.listen((t) {
    debugPrint('FCM token refreshed: $t');
    _updateTokenToServer(t); // gửi token mới lên server
  });

  // DI / SharedPrefs / Localization
  await setupServiceLocator();
  await SharedPreferencesService().init();
  await EasyLocalization.ensureInitialized();

  // Orientation + UI
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
}

// ---------- MAIN ----------
void main() {
  runZonedGuarded(() async {
    await _bootstrap();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('vi')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        saveLocale: true,
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform error: $error\n$stack');
    return true;
  };
}
