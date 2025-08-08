import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:source_base/app.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/dio/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Khởi tạo dịch vụ định vị (dependency injection)
  await setupServiceLocator();
  SharedPreferencesService().init();
  // Khởi tạo đa ngôn ngữ12
  await EasyLocalization.ensureInitialized();

  // Cố định hướng màn hình (tùy chọn)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}
