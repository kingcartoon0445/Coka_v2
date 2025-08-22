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
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
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
              size: 30,
              color: Color(0xFF5A48EF),
            ),
            label: "lead".tr(),
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.handshake_outlined, size: 26),
                if (showCampaignBadge)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: _BadgeDot(),
                  ),
              ],
            ),
            selectedIcon: const Icon(
              Icons.handshake_outlined,
              size: 30,
              color: Color(0xFF5A48EF),
            ),
            label: "customer_label".tr(),
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.person_outline_outlined, size: 26),
                if (showSettingsBadge)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: _BadgeDot(),
                  ),
              ],
            ),
            selectedIcon: const Icon(
              Icons.person_outline_outlined,
              size: 30,
              color: Color(0xFF5A48EF),
            ),
            label: "profile_label".tr(), // tránh trùng key
          ),
          NavigationDestination(
            icon: const Icon(Icons.holiday_village_outlined, size: 26),
            selectedIcon: const Icon(
              Icons.holiday_village_outlined,
              size: 30,
              color: Color(0xFF5A48EF),
            ),
            label: "product_label".tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.keyboard_control, size: 26),
            selectedIcon: const Icon(
              Icons.keyboard_control,
              size: 30,
              color: Color(0xFF5A48EF),
            ),
            label: "expand".tr(),
          ),
        ],
        onDestinationSelected: onTapped,
        selectedIndex: selectedIndex,
        animationDuration: const Duration(milliseconds: 250),
        indicatorColor: const Color(0xFFDCDBFF),
        backgroundColor: Colors.white,
        elevation: 0, // nhẹ hơn
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 68,
      ),
    );
  }
}

class _BadgeDot extends StatelessWidget {
  const _BadgeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
