import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:country_flags/country_flags.dart';

/// A simple dropdown menu widget for switching the app's language.
/// Shows the country flag of the current locale as the button icon,
/// and lists flags with labels in the popup menu.
class LanguageDropdown extends StatelessWidget {
  /// Supported locales to choose from.
  final List<Locale> supportedLocales;

  /// Fallback locale if current isn't supported.
  final Locale? fallbackLocale;

  const LanguageDropdown({
    Key? key,
    required this.supportedLocales,
    this.fallbackLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final current = context.locale;
    // Determine flag widget for current locale or fallback icon
    final Widget currentFlag = current.languageCode != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CountryFlag.fromLanguageCode(
              current.languageCode.toUpperCase(),
              height: 24,
              width: 24,
            ),
          )
        : const Icon(Icons.language);

    return PopupMenuButton<Locale>(
      icon: currentFlag,
      onSelected: (locale) => context.setLocale(locale),
      itemBuilder: (ctx) => supportedLocales.map((locale) {
        final code = locale.languageCode?.toUpperCase();
        final flagWidget = code != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    CountryFlag.fromLanguageCode(code, height: 20, width: 20))
            : const Icon(Icons.language, size: 20);
        final label = _localeLabel(locale);
        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              flagWidget,
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Human-readable name for the locale.
  String _localeLabel(Locale locale) {
    switch (locale.toString()) {
      case 'vi_VN':
        return 'Tiếng Việt';
      case 'en_US':
        return 'English';
      default:
        return locale.toLanguageTag();
    }
  }
}
