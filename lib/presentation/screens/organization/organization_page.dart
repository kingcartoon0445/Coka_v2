import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/config/routes.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/data/models/organization_model.dart';
import 'package:source_base/data/models/user_profile.dart';
import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/auth/auth_event.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/custom_bottom_navigation.dart';
import 'package:source_base/presentation/screens/shared/widgets/notification_list_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/organization_drawer.dart';
import 'package:source_base/presentation/widget/language_switcher.dart';

import '../../blocs/customer_service/customer_service_action.dart';
import '../../blocs/organization/organization_action_bloc.dart';

class OrganizationPage extends StatefulWidget {
  final String organizationId;
  final Widget child;

  const OrganizationPage({
    super.key,
    required this.organizationId,
    required this.child,
  });

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  UserProfile? _userInfo;
  OrganizationModel? _organizationInfo;
  List<OrganizationModel> _organizations = [];
  bool _isLoadingOrganizationsError = false;
  int _unreadNotificationCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(OrganizationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        'didUpdateWidget - old: ${oldWidget.organizationId}, new: ${widget.organizationId}');
    if (oldWidget.organizationId != widget.organizationId) {
      print('Organization ID changed - reloading data');
      _loadOrganizations();
    }
  }

  Future<void> _initData() async {
    await Future.wait([
      _loadUserInfo(),
      _loadOrganizations(),
      _loadUnreadNotificationCount(),
    ]);
  }

  Future<void> _loadOrganizations() async {
    if (mounted) {
      setState(() {
        _isLoadingOrganizationsError = false;
      });
    }

    try {
      context.read<OrganizationBloc>().add(const LoadOrganizations(
            limit: '10',
            offset: '0',
            searchText: '',
          ));
    } catch (e) {
      print('Lỗi khi load organizations: $e');
      if (mounted) {
        setState(() {
          _isLoadingOrganizationsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải danh sách tổ chức'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      if (mounted) {
        context.read<OrganizationBloc>().add(LoadUserInfo(
              organizationId: widget.organizationId,
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin người dùng')),
        );
      }
    }
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      // final notificationRepository = NotificationRepository(ApiClient());
      // final response = await notificationRepository.getUnreadCount();
      if (mounted) {
        setState(() {
          // _unreadNotificationCount = response['content'] ?? 0;
        });
      }
    } catch (e) {
      print('Lỗi khi load số lượng thông báo chưa đọc: $e');
      // Không hiển thị lỗi cho user vì đây không phải chức năng quan trọng
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 130,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 2),
          Container(
            width: 80,
            height: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
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

  Widget _buildTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/messages')) {
      return const Text('Tin nhắn');
    }
    if (location.contains('/campaigns')) {
      return const Text('Chiến dịch');
    }

    // if (_isLoading) {
    //   return _buildSkeletonTitle();
    // }

    if (_isLoadingOrganizationsError) {
      return const Text(
        'Lỗi tải tổ chức',
        style: TextStyle(color: Colors.red),
      );
    }

    if (_organizationInfo == null && widget.organizationId != 'default') {
      return _buildSkeletonTitle();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _userInfo?.fullName ?? '',
          style: TextStyles.heading3,
        ),
        if (_organizationInfo != null)
          Text(
            _getRoleText(_organizationInfo?.type),
            style: TextStyles.subtitle2,
          ),
      ],
    );
  }

  Widget _buildDrawer() {
    return OrganizationDrawer(
      userInfo: _userInfo,
      currentOrganizationId: widget.organizationId,
      organizations: _organizations,
      onLogout: () => _handleLogout(context),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/messages')) {
      return 1;
    }
    if (location.contains('/campaigns')) {
      return 2;
    }
    return 0;
  }

  // Kiểm tra xem có đang ở trang AI Chatbot không
  bool _isAIChatbotPage(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return location.contains('/campaigns/ai-chatbot');
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.replace('/organization/${widget.organizationId}');
        break;
      case 1:
        context.replace(AppPaths.messages(widget.organizationId));
        break;
      case 2:
        context.replace('/organization/${widget.organizationId}/campaigns');
        break;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    context.read<AuthBloc>().add(LogoutRequested());
    if (context.mounted) {
      context.replace('/');
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
          const notificationWidget = NotificationListWidget(
            showTitle: false,
            showMoreOption: false,
            fullScreen: true,
          );

          return notificationWidget;

          // return const SizedBox.shrink();
        },
      ),
    ).then((_) {
      // Reload unread count khi đóng notification modal
      _loadUnreadNotificationCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có đang ở trang AI Chatbot không
    final isAIChatbotPage = _isAIChatbotPage(context);

    return BlocConsumer<OrganizationBloc, OrganizationState>(
        bloc: context.read<OrganizationBloc>(),
        listener: (context, state) {
          if (state.status == OrganizationStatus.error) {
            Helpers.showSnackBar(context, state.error ?? 'Unknown error');
          }
          if (state.status == OrganizationStatus.loadUserInfoSuccess) {
            setState(() {
              _userInfo = state.user;
            });
          }
          if (state.status == OrganizationStatus.loadOrganizationsSuccess) {
            _organizations = state.organizations;
            if (widget.organizationId != 'default') {
              final currentOrg = _organizations.firstWhere(
                (org) => org.id == widget.organizationId,
                // orElse: () => null,
              );
              if (mounted) {
                setState(() {
                  _organizationInfo = currentOrg;
                });
              }
              print('Lưu organization mặc định: ${widget.organizationId}');
              context.read<OrganizationBloc>().add(
                    ChangeOrganization(
                      organizationId: widget.organizationId,
                    ),
                  );
              SharedPreferencesService().setString(
                PrefKey.defaultOrganizationId,
                widget.organizationId,
              );
              //   await ApiClient.storage.write(
              //     key: 'default_organization_id',
              //     value: widget.organizationId,
              //   );
              //   final savedOrgId = await ApiClient.storage.read(key: 'default_organization_id');
              //   print('Kiểm tra lại organization mặc định đã lưu: $savedOrgId');
              // } else {
              //   print('Organization ID ${widget.organizationId} không tìm thấy trong danh sách.');
              //   if (mounted) {
              //     if (organizations.isNotEmpty) {
              //       context.go('/organization/${organizations[0]['id']}');
              //     } else {
              //       setState(() {
              //         _isLoadingOrganizationsError = true;
              //       });
              //     }
              //   }
              context.read<CustomerServiceBloc>().add(
                    LoadCustomerService(
                      organizationId: widget.organizationId,
                      pagingRequest: LeadPagingRequest(
                        searchText: null,
                        limit: 10,
                        offset: 0,
                        fields: null,
                        status: null,
                        startDate: null,
                        endDate: null,
                        stageIds: null,
                        sourceIds: null,
                        utmSources: null,
                        ratings: null,
                        teamIds: null,
                        assignees: null,
                        tags: null,
                        isBusiness: null,
                        isArchive: null,
                      ),
                    ),
                  );
            } else {
              if (mounted) {
                setState(() {
                  final currentOrg = _organizations.first;
                  if (currentOrg != null) {
                    if (mounted) {
                      setState(() {
                        _organizationInfo = currentOrg;
                      });
                    }
                    print(
                        'Lưu organization mặc định: ${widget.organizationId}');
                    context.read<OrganizationBloc>().add(ChangeOrganization(
                          organizationId: _organizationInfo!.id!,
                        ));
                    context.read<CustomerServiceBloc>().add(
                          LoadCustomerService(
                            organizationId: context
                                    .read<OrganizationBloc>()
                                    .state
                                    .organizationId ??
                                '',
                            pagingRequest: LeadPagingRequest(
                              searchText: null,
                              limit: 10,
                              offset: 0,
                              fields: null,
                              status: null,
                              startDate: null,
                              endDate: null,
                              stageIds: null,
                              sourceIds: null,
                              utmSources: null,
                              ratings: null,
                              teamIds: null,
                              assignees: null,
                              tags: null,
                              isBusiness: null,
                              isArchive: null,
                            ),
                          ),
                        );
                    SharedPreferencesService().setString(
                      PrefKey.defaultOrganizationId,
                      _organizationInfo!.id!,
                    );
                    //   await ApiClient.storage.write(
                    //     key: 'default_organization_id',
                    //     value: widget.organizationId,
                    //   );
                    //   final savedOrgId = await ApiClient.storage.read(key: 'default_organization_id');
                    //   print('Kiểm tra lại organization mặc định đã lưu: $savedOrgId');
                    // } else {
                    //   print('Organization ID ${widget.organizationId} không tìm thấy trong danh sách.');
                    //   if (mounted) {
                    //     if (organizations.isNotEmpty) {
                    //       context.go('/organization/${organizations[0]['id']}');
                    //     } else {
                    //       setState(() {
                    //         _isLoadingOrganizationsError = true;
                    //       });
                    //     }
                    //   }
                  }
                });
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
                    title: _buildTitle(context),
                    actions: [
                      LanguageDropdown(
                        supportedLocales: context.supportedLocales,
                        fallbackLocale: Locale('en', 'US'),
                      ),
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
                                    border: Border.all(
                                        color: Colors.white, width: 1),
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
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
            body: widget.child,
            bottomNavigationBar: isAIChatbotPage
                ? null
                : CustomBottomNavigation(
                    selectedIndex: _calculateSelectedIndex(context),
                    onTapped: (index) => _onItemTapped(index, context),
                    showCampaignBadge: false,
                    showSettingsBadge: false,
                  ),
          );
        });
  }
}
