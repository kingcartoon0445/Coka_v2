import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/config/routes.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/data/models/organization_model.dart';
import 'package:source_base/data/models/user_profile.dart';
import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/auth/auth_event.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/custom_bottom_navigation.dart';
import 'package:source_base/presentation/screens/shared/widgets/notification_list_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/organization_drawer.dart';
import 'package:source_base/presentation/widget/language_switcher.dart';

import '../../blocs/customer_service/customer_service_action.dart';
import '../../blocs/final_deal/final_deal_action.dart';
import '../../blocs/organization/organization_action_bloc.dart';

// ignore: must_be_immutable
class OrganizationPage extends StatefulWidget {
  String organizationId; // giữ để tương thích router bên ngoài

  final Widget child;

  OrganizationPage({
    super.key,
    required this.organizationId,
    required this.child,
  });

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  // Trạng thái cục bộ
  late String _orgId; // ✅ không mutate widget.organizationId trực tiếp
  UserProfile? _userInfo;
  OrganizationModel? _organizationInfo;
  List<OrganizationModel> _organizations = [];
  bool _isLoadingOrganizationsError = false;
  int _unreadNotificationCount = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Điều hướng animation bottom tabs
  int _lastTabIndex = 0;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _orgId = widget.organizationId;

    // load organizations list
    context.read<OrganizationBloc>().add(const LoadOrganizations(
          limit: '10',
          offset: '0',
          searchText: '',
        ));

    _initData();
  }

  @override
  void didUpdateWidget(covariant OrganizationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId != widget.organizationId) {
      debugPrint(
          'Organization ID changed: ${oldWidget.organizationId} → ${widget.organizationId}');
      _orgId = widget.organizationId; // đồng bộ id mới từ props
      _loadOrganizations();
      _loadUserInfo();
    }
  }

  Future<void> _initData() async {
    await Future.wait([
      _loadOrganizations(),
      _loadUserInfo(),
      _loadUnreadNotificationCount(),
    ]);
  }

  Future<void> _loadOrganizations() async {
    if (!mounted) return;
    setState(() => _isLoadingOrganizationsError = false);
    // data list sẽ đến qua Bloc listener
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;
    context.read<OrganizationBloc>().add(LoadUserInfo(organizationId: _orgId));
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      if (!mounted) return;
      setState(() {
        // _unreadNotificationCount = response['content'] ?? 0;
      });
    } catch (e) {
      debugPrint('Load unread notifications failed: $e');
    }
  }

  String _getRoleText(String? role) {
    switch (role) {
      case 'ADMIN':
        return 'Quản trị viên';
      case 'OWNER':
        return 'Chủ tổ chức';
      default:
        return 'Thành viên';
    }
  }

  Widget _buildSkeletonTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 130, height: 14, child: ColoredBox(color: Colors.white)),
          SizedBox(height: 2),
          SizedBox(
              width: 80, height: 12, child: ColoredBox(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: AppAvatar(
          size: 48,
          shape: AvatarShape.rectangle,
          borderRadius: 16,
          fallbackText: _userInfo?.fullName,
          imageUrl: _userInfo?.avatar,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, int tabIndex) {
    final location = GoRouterState.of(context).uri.path;

    if (location.contains('/messages')) return const Text('Tin nhắn');
    if (location.contains('/campaigns')) return const Text('Chiến dịch');

    if (_isLoadingOrganizationsError) {
      return const Text('Lỗi tải tổ chức', style: TextStyle(color: Colors.red));
    }

    if (_organizationInfo == null && _orgId != 'default') {
      return _buildSkeletonTitle();
    }

    if (tabIndex == 1) return const CustomDropdown();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_userInfo?.fullName ?? '', style: TextStyles.heading3),
        if (_organizationInfo != null)
          Text(_getRoleText(_organizationInfo?.type),
              style: TextStyles.subtitle2),
      ],
    );
  }

  Widget _buildDrawer() {
    return OrganizationDrawer(
      userInfo: _userInfo,
      currentOrganizationId: _orgId,
      organizations: _organizations,
      onLogout: () => Helpers.handleLogout(context),
      onOrganizationChange: (newOrgId) {
        final location = GoRouterState.of(context).uri.path;

        // Điều hướng nếu đang ở các route phụ thuộc orgId
        if (location.contains(AppPaths.finalDeal(_orgId))) {
          context.replace(AppPaths.finalDeal(newOrgId));
        }
        if (location.contains(AppPaths.setting(_orgId))) {
          context.replace(AppPaths.setting(newOrgId));
        }

        setState(() => _orgId = newOrgId);

        // phát sự kiện thay đổi organization
        context.read<OrganizationBloc>().add(ChangeOrganization(
              organizationId: newOrgId,
            ));

        // load lại list khách
        context.read<CustomerServiceBloc>().add(
              LoadCustomerService(
                organizationId:
                    context.read<OrganizationBloc>().state.organizationId ?? '',
                pagingRequest:
                    LeadPagingRequest(limit: 10, offset: 0, channels: ["LEAD"]),
              ),
            );

        // lưu mặc định
        SharedPreferencesService().setString(
          PrefKey.defaultOrganizationId,
          newOrgId,
        );
      },
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.contains(AppPaths.organization(_orgId))) return 0;
    if (path.contains(AppPaths.finalDeal(_orgId))) return 1;
    if (path.contains(AppPaths.setting(_orgId))) return 4;
    return 0;
  }

  bool _isAIChatbotPage(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return path.contains('/campaigns/ai-chatbot');
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.replace(AppPaths.organization(_orgId));
        break;
      case 1:
        context.read<FinalDealBloc>().add(
              GetAllWorkspace(
                organizationId:
                    context.read<OrganizationBloc>().state.organizationId ?? '',
              ),
            );
        context.replace(AppPaths.finalDeal(_orgId));
        break; // ✅ FIX: thiếu break gây rơi xuống case 4
      case 4:
        context.replace(AppPaths.setting(_orgId));
        break;
      default:
        break;
    }
  }

  void _navigateToNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return const NotificationListWidget(
            showTitle: false,
            showMoreOption: false,
            fullScreen: true,
          );
        },
      ),
    ).then((_) => _loadUnreadNotificationCount());
  }

  @override
  Widget build(BuildContext context) {
    final isAIChatbotPage = _isAIChatbotPage(context);
    final currentTabIndex = _calculateSelectedIndex(context);

    // Cập nhật hướng animation khi tab đổi
    if (currentTabIndex != _lastTabIndex) {
      _isForward = currentTabIndex > _lastTabIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _lastTabIndex = currentTabIndex;
      });
    }

    return BlocConsumer<OrganizationBloc, OrganizationState>(
      listener: (context, state) {
        if (state.status == OrganizationStatus.error) {
          Helpers.showSnackBar(context, state.error ?? 'Unknown error');
        }

        if (state.status == OrganizationStatus.loadUserInfoSuccess) {
          setState(() => _userInfo = state.user);
        }

        if (state.status == OrganizationStatus.loadOrganizationsSuccess) {
          _organizations = state.organizations;

          if (_orgId != 'default') {
            final currentOrg = _organizations.firstWhere(
              (org) => org.id == _orgId,
              orElse: () => _organizations.isNotEmpty
                  ? _organizations.first
                  : OrganizationModel(),
            );

            if (mounted) {
              setState(() => _organizationInfo = currentOrg);
            }

            context.read<OrganizationBloc>().add(
                  ChangeOrganization(organizationId: _orgId),
                );

            SharedPreferencesService()
                .setString(PrefKey.defaultOrganizationId, _orgId);

            context.read<CustomerServiceBloc>().add(
                  LoadCustomerService(
                    organizationId:
                        context.read<OrganizationBloc>().state.organizationId ??
                            '',
                    pagingRequest: LeadPagingRequest(
                        limit: 10, offset: 0, channels: ["LEAD"]),
                  ),
                );
          } else {
            // Nếu 'default', chọn phần tử đầu tiên (nếu có)
            if (_organizations.isNotEmpty && mounted) {
              final currentOrg = _organizations.first;
              setState(() {
                _organizationInfo = currentOrg;
                _orgId = currentOrg.id ?? _orgId;
              });

              context
                  .read<OrganizationBloc>()
                  .add(ChangeOrganization(organizationId: _orgId));

              context.read<CustomerServiceBloc>().add(
                    LoadCustomerService(
                      organizationId: context
                              .read<OrganizationBloc>()
                              .state
                              .organizationId ??
                          '',
                      pagingRequest: LeadPagingRequest(
                          limit: 10, offset: 0, channels: ["LEAD"]),
                    ),
                  );

              SharedPreferencesService()
                  .setString(PrefKey.defaultOrganizationId, _orgId);
            }
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(),
          appBar: isAIChatbotPage
              ? null
              : AppBar(
                  leading: _buildAvatar(),
                  title: _buildTitle(context, currentTabIndex),
                  actions: [
                    const LanguageDropdown(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: _navigateToNotifications,
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          if (_unreadNotificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  _unreadNotificationCount > 99
                                      ? '99+'
                                      : _unreadNotificationCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) {
              final begin =
                  _isForward ? const Offset(1, 0) : const Offset(-1, 0);
              final slide = Tween<Offset>(begin: begin, end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOut));
              final fade =
                  CurvedAnimation(parent: animation, curve: Curves.easeOut);

              return SlideTransition(
                position: slide,
                child: FadeTransition(opacity: fade, child: child),
              );
            },
            layoutBuilder: (currentChild, _) =>
                currentChild ?? const SizedBox.shrink(),
            child: KeyedSubtree(
              key: ValueKey<int>(currentTabIndex),
              child: widget.child,
            ),
          ),
          bottomNavigationBar: isAIChatbotPage
              ? null
              : CustomBottomNavigation(
                  selectedIndex: currentTabIndex,
                  onTapped: (index) => _onItemTapped(index, context),
                  showCampaignBadge: false,
                  showSettingsBadge: false,
                ),
        );
      },
    );
  }
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key});

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalDealBloc, FinalDealState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.centerLeft,
          child: PopupMenuButton<WorkspaceModel>(
            color: Colors.white,
            onOpened: () => setState(() => isOpen = true),
            onCanceled: () => setState(() => isOpen = false),
            onSelected: (WorkspaceModel value) {
              context.read<FinalDealBloc>().add(SelectWorkspace(
                    workspace: value,
                    organizationId:
                        context.read<OrganizationBloc>().state.organizationId ??
                            '',
                  ));
              setState(() => isOpen = false);
            },
            itemBuilder: (context) {
              return state.workspaces.map((choice) {
                final isSelected = choice == state.selectedWorkspace;
                return PopupMenuItem<WorkspaceModel>(
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        choice.name ?? '',
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check,
                            color: AppColors.primary, size: 18),
                    ],
                  ),
                );
              }).toList();
            },
            offset: const Offset(0, 45),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.selectedWorkspace?.name ?? '',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Icon(isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
