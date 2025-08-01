import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final ThemeData themeData;
  final Locale currentLocale;
  final List<Locale> supportedLocales;

  const ThemeState({
    required this.themeMode,
    required this.themeData,
    required this.currentLocale,
    required this.supportedLocales,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    ThemeData? themeData,
    Locale? currentLocale,
    List<Locale>? supportedLocales,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeData: themeData ?? this.themeData,
      currentLocale: currentLocale ?? this.currentLocale,
      supportedLocales: supportedLocales ?? this.supportedLocales,
    );
  }

  @override
  List<Object?> get props =>
      [themeMode, themeData, currentLocale, supportedLocales];
}
