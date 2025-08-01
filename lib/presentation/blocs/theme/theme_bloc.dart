import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/dio/service_locator.dart';
import 'package:source_base/presentation/blocs/theme/theme_event.dart';
import 'package:source_base/presentation/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferencesService _storageService =
      getIt<SharedPreferencesService>();

  static const String _languageKey = 'selected_language';
  static const String _countryKey = 'selected_country';

  ThemeBloc()
      : super(
          ThemeState(
            themeMode: ThemeMode.light,
            themeData: _lightTheme,
            currentLocale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('vi')],
          ),
        ) {
    on<InitTheme>(_onInitTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeLanguage>(_onChangeLanguage);

    // Khởi tạo theme và ngôn ngữ
    add(InitTheme());
  }

  // Xử lý sự kiện khởi tạo theme
  void _onInitTheme(InitTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = _storageService.getBool(PrefKey.isDarkMode) ?? false;

    // Lấy ngôn ngữ đã lưu
    final savedLanguage = _storageService.getString(_languageKey) ?? 'en';
    final savedCountry = _storageService.getString(_countryKey) ?? 'US';
    final currentLocale = Locale(savedLanguage, savedCountry);

    emit(
      ThemeState(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeData: isDarkMode ? _darkTheme : _lightTheme,
        currentLocale: currentLocale,
        supportedLocales: const [Locale('en'), Locale('vi')],
      ),
    );
  }

  // Xử lý sự kiện chuyển đổi theme
  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ThemeState> emit) async {
    final isDarkMode = state.themeMode == ThemeMode.dark;
    final newIsDarkMode = !isDarkMode;

    // Lưu trạng thái theme mới
    await _storageService.setBool(PrefKey.isDarkMode, newIsDarkMode);

    emit(
      state.copyWith(
        themeMode: newIsDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeData: newIsDarkMode ? _darkTheme : _lightTheme,
      ),
    );
  }

  // Xử lý sự kiện thay đổi ngôn ngữ
  Future<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<ThemeState> emit) async {
    // Lưu ngôn ngữ mới vào storage
    await _storageService.setString(_languageKey, event.locale.languageCode);
    if (event.locale.countryCode != null) {
      await _storageService.setString(_countryKey, event.locale.countryCode!);
    }

    emit(state.copyWith(currentLocale: event.locale));
  }

  // Định nghĩa theme sáng
  static final ThemeData _lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    fontFamily: 'GoogleSans',
    useMaterial3: true,
    textTheme: TextStyles.textTheme,
    appBarTheme: const AppBarTheme(
      toolbarHeight: 56,
      titleSpacing: 8,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
  );

  // Định nghĩa theme tối
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.grey[800],
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}
