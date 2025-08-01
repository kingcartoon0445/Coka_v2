import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTapped;
  final bool showCampaignBadge;
  final bool showSettingsBadge;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTapped,
    this.showCampaignBadge = false,
    this.showSettingsBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          );
        }),
      ),
      child: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_outlined, size: 26),
            selectedIcon: const Icon(
              Icons.favorite_border_outlined,
              size: 22,
              color: Color(0xFF5A48EF),
            ),
            label: "customer_care".tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.handshake_outlined, size: 22),
            selectedIcon: const Icon(
              Icons.handshake_outlined,
              size: 22,
              color: Color(0xFF5A48EF),
            ),
            label: "customer_label".tr(),
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.person_outline_outlined,
              size: 22,
            ),
            selectedIcon: const Icon(
              Icons.person_outline_outlined,
              size: 22,
              color: Color(0xFF5A48EF),
            ),
            label: "customer_label".tr(),
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.holiday_village_outlined,
              size: 22,
            ),
            selectedIcon: const Icon(
              Icons.holiday_village_outlined,
              size: 22,
              color: Color(0xFF5A48EF),
            ),
            label: "product_label".tr(),
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.keyboard_control,
              size: 22,
            ),
            selectedIcon: const Icon(
              Icons.keyboard_control,
              size: 22,
              color: Color(0xFF5A48EF),
            ),
            label: "expand".tr(),
          ),
        ],
        onDestinationSelected: onTapped,
        selectedIndex: selectedIndex,
        animationDuration: const Duration(milliseconds: 500),
        indicatorColor: const Color(0xFFDCDBFF),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
      ),
    );
  }
}
