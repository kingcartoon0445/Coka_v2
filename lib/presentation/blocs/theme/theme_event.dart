import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện khởi tạo theme
class InitTheme extends ThemeEvent {}

// Sự kiện chuyển đổi theme
class ToggleTheme extends ThemeEvent {}

// Sự kiện thay đổi ngôn ngữ
class ChangeLanguage extends ThemeEvent {
  final Locale locale;

  const ChangeLanguage(this.locale);

  @override
  List<Object?> get props => [locale];
}
