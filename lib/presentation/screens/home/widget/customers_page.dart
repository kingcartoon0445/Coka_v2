import 'dart:async';
import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/config/enum_platform.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/connection_channel_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/connection_channel_event.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_event.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_state.dart';
import 'package:source_base/presentation/blocs/organization/organization_action_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/tabs/connection_channel.dart';
import 'package:source_base/presentation/screens/customers_service/tabs/web_form_dialog.dart';
import 'package:source_base/presentation/screens/customers_service/tabs/facebook_chat.dart';
import 'package:source_base/presentation/screens/home/widget/add_new_member.dart';
import 'package:source_base/presentation/screens/home/widget/customers_list.dart';
import 'package:source_base/presentation/screens/home/widget/filter_modal.dart';
import 'package:source_base/presentation/screens/shared/widgets/tiktok_form_config_dialog.dart';
import 'package:source_base/presentation/widget/error_widget.dart';

/// Nhỏ gọn hoá debounce nhập liệu
class _Debouncer {
  _Debouncer(this.duration);
  final Duration duration;
  Timer? _t;
  void call(VoidCallback action) {
    _t?.cancel();
    _t = Timer(duration, action);
  }

  void dispose() => _t?.cancel();
}

enum _TabKey { all, fb, zalo, undefined }

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key, required this.organizationId});
  final String organizationId;

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _searchController = TextEditingController();
  late final _Debouncer _debounce =
      _Debouncer(const Duration(milliseconds: 450));

  bool _showClearButton = false;
  String? _searchQuery;

  FilterResult? _currentFilter;
  bool _isArchive = false;
  bool _showFabLabel = false;
  Timer? _fabLabelTimer;

  static final Map<_TabKey, ({String name, Color badgeColor})> _tabConfig = {
    _TabKey.all: (name: 'Cơ hội'.tr(), badgeColor: const Color(0xFF5C33F0)),
    _TabKey.fb: (
      name: 'facebook_messenger'.tr(),
      badgeColor: const Color(0xFF92F7A8)
    ),
    _TabKey.zalo: (name: 'zalo_oa'.tr(), badgeColor: const Color(0xFFA4F3FF)),
    // _TabKey.chat: (name: 'Live chat', badgeColor: const Color(0xFFFEC067)),
    _TabKey.undefined: (
      name: 'undefined'.tr(),
      badgeColor: const Color(0xFF9F87FF)
    ),
  };

  int _lastIndex = 0;

  bool get _showFilter => _tabController.index == 0;

  @override
  void initState() {
    super.initState();

    // Bật listener FB khi vào trang (giữ hành vi cũ)
    context.read<CustomerServiceBloc>().add(
          ToggleFirebaseListenerRequested(
            organizationId: widget.organizationId,
            isEnabled: true,
            platform: PlatformSocial.facebook,
            userId: context.read<OrganizationBloc>().state.user?.id ?? '',
          ),
        );

    _tabController = TabController(length: _tabConfig.length, vsync: this)
      ..addListener(_onTabChangedOncePerChange);

    _fetchCustomerCounts(); // stub
    _searchController.addListener(() {
      final hasText = _searchController.text.isNotEmpty;
      if (hasText != _showClearButton) {
        setState(() => _showClearButton = hasText);
      }
    });

    // Load mặc định cho tab 0
    // _loadCustomerService();
  }

  void _onTabChangedOncePerChange() {
    // Chỉ xử lý khi đổi tab hoàn tất, tránh spam khi vuốt
    if (_tabController.indexIsChanging) return;
    final i = _tabController.index;
    if (i == _lastIndex) return;
    _lastIndex = i;

    // Tắt tất cả listener trước khi bật cái cần thiết
    context.read<CustomerServiceBloc>().add(DisableFirebaseListenerRequested(
        organizationId: widget.organizationId));

    switch (_indexToKey(i)) {
      case _TabKey.all:
        context.read<CustomerServiceBloc>().add(
              ToggleFirebaseListenerRequested(
                organizationId: widget.organizationId,
                isEnabled: true,
                platform: PlatformSocial.facebook,
                userId: context.read<OrganizationBloc>().state.user?.id ?? '',
              ),
            );
        _loadCustomerService();
        break;
      case _TabKey.fb:
        context.read<CustomerServiceBloc>().add(
              LoadFirstProviderChat(
                organizationId: widget.organizationId,
                provider: 'FACEBOOK',
              ),
            );
        context.read<CustomerServiceBloc>().add(
              ToggleFirebaseListenerRequested(
                organizationId: widget.organizationId,
                isEnabled: true,
                platform: PlatformSocial.facebook,
                userId: context.read<OrganizationBloc>().state.user?.id ?? '',
              ),
            );
        break;
      case _TabKey.zalo:
        context.read<CustomerServiceBloc>().add(
              LoadFirstProviderChat(
                organizationId: widget.organizationId,
                provider: 'ZALO',
              ),
            );
        context.read<CustomerServiceBloc>().add(
              ToggleFirebaseListenerRequested(
                organizationId: widget.organizationId,
                isEnabled: true,
                platform: PlatformSocial.zalo,
                userId: context.read<OrganizationBloc>().state.user?.id ?? '',
              ),
            );
        break;
      // case _TabKey.chat:
      case _TabKey.undefined:
        // Giữ nguyên như All (CustomersList), tái dùng _loadCustomerService
        _loadCustomerService();
        break;
    }

    // Cập nhật UI filter bar nếu cần
    setState(() {});

    // Hiển thị label 2s khi đổi tab
    _showFabLabelForAWhile();
  }

  void _showFabLabelForAWhile() {
    _fabLabelTimer?.cancel();
    if (!mounted) return;
    setState(() => _showFabLabel = true);
    _fabLabelTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showFabLabel = false);
    });
  }

  _TabKey _indexToKey(int i) => _TabKey.values[i];

  _TabKey get _currentTabKey => _indexToKey(_tabController.index);

  List<SpeedDialChild> _buildSpeedDialChildrenFor(_TabKey key) {
    switch (key) {
      case _TabKey.all:
        return [
          SpeedDialChild(
            label: 'manual'.tr(),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.create, color: Colors.white),
            onTap: () {
              showOpportunityCreateDialog(context).then((value) {
                if (value == true) {
                  _loadCustomerService();
                }
              });
            },
          ),
          // SpeedDialChild(
          //   backgroundColor: AppColors.primary.withOpacity(0.6),
          //   label: 'Google Sheet',
          //   child: const Icon(Icons.description, color: Colors.white),
          //   onTap: () {},
          // ),
          SpeedDialChild(
            label: 'import_from_contact'.tr(),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.primary,
            child:
                const Icon(Icons.perm_contact_cal_rounded, color: Colors.white),
            onTap: () async {
              if (await FlutterContacts.requestPermission()) {
                if (!context.mounted) return;
              }
            },
          ),
        ];
      case _TabKey.fb:
        return [
          // SpeedDialChild(
          //   label: 'Tạo hội thoại',
          //   backgroundColor: const Color(0xFFE3DFFF),
          //   child: const Icon(Icons.forum_outlined, color: Colors.black),
          //   onTap: () {
          //     // TODO: implement create conversation
          //   },
          // ),
          SpeedDialChild(
            label: 'link_facebook'.tr(),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.facebook, color: Colors.white, size: 20),
            onTap: () {
              Helpers().connectFacebookPage(context);
              // TODO: implement link page
            },
          ),
        ];
      case _TabKey.zalo:
        return [
          SpeedDialChild(
            label: 'link_zalo'.tr(),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.hub_outlined, color: Colors.white),
            onTap: () {
              // TODO: implement OA connect
              Helpers().connectZaloPage(context);
            },
          ),
        ];
      // case _TabKey.chat:
      //   return [
      //     SpeedDialChild(
      //       label: 'Tạo widget chat',
      //       backgroundColor: AppColors.primary.withOpacity(0.6),
      //       child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      //       onTap: () {
      //         // TODO: implement create widget
      //       },
      //     ),
      //     SpeedDialChild(
      //       label: 'Sao chép mã nhúng',
      //       backgroundColor: AppColors.primary.withOpacity(0.6),
      //       child: const Icon(Icons.code, color: Colors.white),
      //       onTap: () {
      //         // TODO: copy embed code
      //       },
      //     ),
      //   ];
      case _TabKey.undefined:
        return [
          SpeedDialChild(
            label: 'link_undefined'.tr(),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add_link, color: Colors.white),
            onTap: _showConnectionChannelsSheet,
          ),
        ];
    }
  }

  void _showConnectionChannelsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 40),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hub_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'link_new_page'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    height: 1,
                    color: const Color.fromARGB(255, 139, 138, 138),
                  ),
                  const SizedBox(height: 12),
                  _ConnectionItem(
                    // svgIcon: SvgPicture.network('assets/icons/web_form.svg'),
                    icon: Icons.language,
                    color: const Color(0xFF1877F2),
                    title: 'web_form'.tr(),
                    subtitle: 'link_web_form_subtitle'.tr(),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await showDialog(
                        context: context,
                        builder: (_) => const WebFormDialog(),
                      );
                    },
                  ),
                  _ConnectionItem(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    title: 'facebook_messenger'.tr(),
                    subtitle: 'link_facebook_subtitle'.tr(),
                    onTap: () {
                      Navigator.of(context).pop();
                      Helpers().connectFacebookPage(context);
                    },
                  ),
                  _ConnectionItem(
                    svgIcon: SvgPicture.network(
                      'https://alpha.coka.ai/icons/zalo.svg',
                      height: 20,
                    ),
                    icon: Icons.wechat_outlined,
                    color: const Color(0xFF06A8FF),
                    title: 'zalo_oa'.tr(),
                    subtitle: 'link_zalo_subtitle'.tr(),
                    onTap: () {
                      Navigator.of(context).pop();
                      Helpers().connectZaloPage(context);
                    },
                  ),
                  _ConnectionItem(
                    svgIcon: SvgPicture.network(
                      'https://alpha.coka.ai/icons/tiktok.svg',
                      height: 20,
                    ),
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xFF5C33F0),
                    title: 'tiktok'.tr(),
                    subtitle: 'link_tiktok_subtitle'.tr(),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (_) => const TiktokFormConfigDialog(),
                      );
                    },
                  ),
                  _ConnectionItem(
                    icon: Icons.webhook_outlined,
                    color: const Color(0xFF5C33F0),
                    title: 'webhook'.tr(),
                    subtitle: 'link_webhook_subtitle'.tr(),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (_) => const TiktokFormConfigDialog(),
                      ).then((value) {
                        context.read<ConnectionChannelBloc>().add(
                              GetChannelListEvent(
                                  organizationId: context
                                          .read<OrganizationBloc>()
                                          .state
                                          .organizationId ??
                                      ""),
                            );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce.dispose();
    _searchController.dispose();
    _tabController.dispose();
    _fabLabelTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId != widget.organizationId) {
      _fetchCustomerCounts();
      _loadCustomerService();
    }
  }

  // ---------------- Actions ----------------

  Future<void> _fetchCustomerCounts() async {
    // TODO: Plug real API when available.
    developer.log('Fetching customer counts (stub)');
  }

  Future<void> _showFilterModal() async {
    final result = await FilterModal.show(
      context,
      widget.organizationId,
      '',
      initialValue: _currentFilter,
    );
    if (!mounted || result == null) return;
    setState(() => _currentFilter = result);
    _loadCustomerService();
  }

  void _loadCustomerService() {
    final orgId = context.read<OrganizationBloc>().state.organizationId ??
        widget.organizationId;

    context.read<CustomerServiceBloc>().add(
          LoadCustomerService(
            organizationId: orgId,
            pagingRequest: LeadPagingRequest(
              limit: 20,
              channels: ["LEAD"],
              offset: 0,
              searchText: _searchQuery,
              startDate: _currentFilter?.dateRange?.start,
              endDate: _currentFilter?.dateRange?.end,
              sourceIds: _currentFilter?.categories.map((e) => e.id).toList(),
              utmSources: _currentFilter?.sources.map((e) => e.name).toList(),
              assignees:
                  _currentFilter?.assignees.map((e) => e.id ?? '').toList(),
              tags: _currentFilter?.tags.map((e) => e.name ?? '').toList(),
              customConditions: _currentFilter?.conditions ?? [],
              isBusiness: null,
              isArchive: _isArchive,
            ),
          ),
        );
  }

  // ---------------- UI Builders ----------------

  Widget _buildTabBar() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.text,
          indicatorColor: AppColors.primary,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          tabs: _tabConfig.values
              .map((config) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(config.name), const SizedBox(width: 4)],
                    ),
                  ))
              .toList(),
        ),
        Container(height: 1, color: const Color(0xFFE1E1E1)),
      ],
    );
  }

  Widget _buildActiveFiltersBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 0.2, height: 1, color: Color(0xFFE5E7EB)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterToggle(
                  label: "opportunity_customer".tr(),
                  active: !_isArchive,
                  icon: Icons.inbox_outlined,
                  onTap: () {
                    setState(() => _isArchive = false);
                    _loadCustomerService();
                  },
                ),
                const SizedBox(width: 10),
                _FilterToggle(
                  label: "storage".tr(),
                  active: _isArchive,
                  icon: Icons.system_update_alt,
                  onTap: () {
                    setState(() => _isArchive = !_isArchive);
                    _loadCustomerService();
                  },
                ),
                const SizedBox(width: 10),
                _FilterToggle(
                  label: 'fillter'.tr(),
                  active: true,
                  icon: Icons.filter_list_outlined,
                  activeColor: AppColors.primary,
                  onTap: _showFilterModal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerLine(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  _ShimmerLine(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFabLabel(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'link_facebook'.tr();
      case 2:
        return 'link_zalo'.tr();
      case 3:
        return 'link_undefined'.tr();
      case 4:
        return 'link_undefined'.tr();
      default:
        return 'manual'.tr();
    }
  }

  Widget _buildFab() {
    final tabIndex = _tabController.index;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
                    begin: const Offset(0.1, 0), end: Offset.zero)
                .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: _showFabLabel
              ? Container(
                  key: ValueKey('show-$tabIndex'),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C33F0).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _getFabLabel(tabIndex),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('hide')),
        ),
        SpeedDial(
          icon: Icons.add,
          spacing: 15,
          backgroundColor: const Color(0xFF5C33F0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          activeIcon: Icons.close,
          iconTheme: const IconThemeData(color: Colors.white),
          children: _buildSpeedDialChildrenFor(_currentTabKey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stageGroupId = AppConstants.stageObject.entries
        .firstWhere(
          (entry) => entry.value['name'] == 'all'.tr(),
          orElse: () => const MapEntry('', {}),
        )
        .key;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: _buildTitle(null, false),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showFilter ? 56 : 0),
          child: Column(
            children: [
              _buildTabBar(),
              if (_showFilter) _buildActiveFiltersBar(),
            ],
          ),
        ),
      ),
      body: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
        builder: (context, state) {
          switch (state.status) {
            case CustomerServiceStatus.loading:
              return _buildShimmerItem();
            case CustomerServiceStatus.error:
              return ErrorMessageWidget(
                message: state.error ?? '',
                onRetry: _fetchCustomerCounts,
              );
            case CustomerServiceStatus.success:
            default:
              final stageId = stageGroupId.isEmpty ? null : stageGroupId;
              final customersList = CustomersList(
                organizationId: widget.organizationId,
                stageGroupId: stageId,
                searchQuery: _searchQuery,
                queryParams: state.customerServices,
                onRefresh: _loadCustomerService,
              );
              return TabBarView(
                controller: _tabController,
                children: const [
                  // 0: All
                  // 1: Facebook
                  // 2: Zalo
                  // 3: Live chat (reused list)
                  // 4: Undefined (reused list)
                ].isEmpty
                    ? [
                        customersList,
                        const FacebookMessagesTab(provider: 'FACEBOOK'),
                        const FacebookMessagesTab(provider: 'ZALO'),
                        // customersList,
                        const ConnectionChannelScreen(),
                      ]
                    : [],
              );
          }
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
    this.activeColor,
  });

  final String label;
  final bool active;
  final IconData icon;
  final Color? activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? AppColors.primary) : AppColors.text;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _ConnectionItem extends StatelessWidget {
  const _ConnectionItem({
    this.svgIcon,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Widget? svgIcon;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: svgIcon ?? Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
