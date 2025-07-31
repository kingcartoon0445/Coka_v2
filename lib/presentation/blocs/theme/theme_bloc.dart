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

  ThemeBloc()
      : super(
          ThemeState(
            themeMode: ThemeMode.light,
            themeData: _lightTheme,
          ),
        ) {
    on<InitTheme>(_onInitTheme);
    on<ToggleTheme>(_onToggleTheme);

    // Khởi tạo theme
    add(InitTheme());
  }

  // Xử lý sự kiện khởi tạo theme
  void _onInitTheme(InitTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = _storageService.getBool(PrefKey.isDarkMode) ?? false;

    emit(
      ThemeState(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeData: isDarkMode ? _darkTheme : _lightTheme,
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
      ThemeState(
        themeMode: newIsDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeData: newIsDarkMode ? _darkTheme : _lightTheme,
      ),
    );
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
