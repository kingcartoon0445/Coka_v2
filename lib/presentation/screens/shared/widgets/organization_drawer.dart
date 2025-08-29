import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/test_style.dart' show TextStyles;
import 'package:source_base/data/models/organization_model.dart';
import 'package:source_base/data/models/user_profile.dart';
import 'package:source_base/presentation/screens/auth/complete_profile_page.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
// Corrected import path

class OrganizationDrawer extends StatelessWidget {
  final UserProfile? userInfo;
  final String currentOrganizationId;
  final List<OrganizationModel> organizations;
  final VoidCallback onLogout;
  final Function(String) onOrganizationChange;

  const OrganizationDrawer({
    super.key,
    required this.userInfo,
    required this.currentOrganizationId,
    required this.organizations,
    required this.onLogout,
    required this.onOrganizationChange,
  });

  bool get isAdminOrOwner {
    if (organizations.isEmpty) return false;

    // Tìm tổ chức hiện tại trong danh sách
    OrganizationModel? currentOrg = organizations.firstWhere(
      (org) => org.id == currentOrganizationId,
      orElse: () => OrganizationModel(
        id: '',
        name: '',
        avatar: '',
        type: '',
      ),
    );

    if (currentOrg == null) return false;

    // Kiểm tra type của người dùng trong tổ chức (theo response từ API)
    // Type có thể là "ADMIN", "OWNER" hoặc "MEMBER"
    final type = currentOrg.type?.toString().toUpperCase() ?? '';
    return type == 'ADMIN' || type == 'OWNER';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.24,
            decoration: const BoxDecoration(
              color: AppColors.backgroundTertiary,
            ),
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              itemCount: organizations.length + 1,
              itemBuilder: (context, index) {
                if (index == organizations.length) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        // context.push(AppPaths.createOrganization);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }
                final org = organizations[index];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (org.id == currentOrganizationId)
                      Positioned(
                        left: 0,
                        top: 8,
                        child: Container(
                          width: 3,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(24.0)),
                          ),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              onOrganizationChange(org.id ?? '');
                              Navigator.pop(context);
                            },
                            child: AppAvatar(
                              size: 40,
                              shape: AvatarShape.rectangle,
                              borderRadius: 8,
                              fallbackText: org.name,
                              imageUrl: org.avatar,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            org.name ?? '',
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 64, bottom: 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(
                        size: 48,
                        shape: AvatarShape.rectangle,
                        borderRadius: 26,
                        fallbackText: userInfo?.fullName,
                        imageUrl: userInfo?.avatar,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userInfo?.fullName ?? '',
                        style: TextStyles.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const CompleteProfilePage(),
                          ));
                        },
                        child: Text(
                          'view_profile'.tr(),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            decorationColor: AppColors.textTertiary,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.group_add_outlined,
                              color: AppColors.primary),
                          title: Text('join_organization'.tr()),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //   builder: (context) => const JoinOrganizationPage(),
                            // ));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_add_outlined,
                              color: AppColors.primary),
                          title: Text('invitation'.tr()),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //   builder: (context) => const InvitationPage(),
                            // ));
                          },
                        ),
                        if (isAdminOrOwner)
                          ListTile(
                            leading: const Icon(Icons.person_search_outlined,
                                color: AppColors.primary),
                            title: Text('join_request'.tr()),
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -1.0),
                            onTap: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => JoinRequestPage(
                              //       organizationId: currentOrganizationId,
                              //     ),
                              //   ),
                              // );
                            },
                          ),
                        if (isAdminOrOwner)
                          ListTile(
                            leading: const Icon(
                                Icons.workspace_premium_outlined,
                                color: AppColors.primary),
                            title: Text('upgrade_organization'.tr()),
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -1.0),
                            onTap: () {
                              // TODO: Navigate to upgrade account
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.help_outline,
                              color: AppColors.primary),
                          title: Text('help_support'.tr()),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // TODO: Navigate to help
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings_outlined,
                              color: AppColors.primary),
                          title: Text('settings'.tr()),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            final params =
                                GoRouterState.of(context).pathParameters;
                            log("Params: $params");
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => SettingsPage(
                            //       organizationId: currentOrganizationId,
                            //       userRole: isAdminOrOwner ? 'ADMIN' : 'MEMBER',
                            //       workspaceId: '',
                            //     ),
                            //   ),
                            // );
                          },
                        ),
                        const Spacer(),
                        const Divider(
                          thickness: 0,
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ListTile(
                            leading: const Icon(Icons.logout,
                                color: AppColors.primary),
                            title: Text('logout'.tr()),
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -1.0),
                            onTap: onLogout,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
