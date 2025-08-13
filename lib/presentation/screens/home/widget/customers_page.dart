import 'dart:async';
import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/config/enum_platform.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_event.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_state.dart';
import 'package:source_base/presentation/blocs/organization/organization_action_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/tabs/facebook_chat.dart';
import 'package:source_base/presentation/screens/home/widget/customers_list.dart';
import 'package:source_base/presentation/screens/home/widget/filter_modal.dart';
import 'package:source_base/presentation/screens/shared/widgets/dropdown_button_widget.dart';
import 'package:source_base/presentation/widget/error_widget.dart';

class CustomersPage extends StatefulWidget {
  final String organizationId;
  const CustomersPage({super.key, required this.organizationId});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _showClearButton = false;
  String? _searchQuery;

  FilterResult? _currentFilter;
  bool _isArchive = false;

  static final Map<String, ({String name, Color badgeColor})> _tabConfig = {
    'all': (name: 'all'.tr(), badgeColor: const Color(0xFF5C33F0)),
    'fb': (name: 'Facebook Messenger', badgeColor: const Color(0xFF92F7A8)),
    'zalo': (name: 'Zalo OA', badgeColor: const Color(0xFFA4F3FF)),
    'chat': (name: 'Live chat', badgeColor: const Color(0xFFFEC067)),
    'undefined': (name: 'Chưa xác định', badgeColor: const Color(0xFF9F87FF)),
  };
  bool showFilter = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabConfig.length, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          _fetchCustomerCounts();
        }
        if (_tabController.index == 0) {
          setState(() => showFilter = true);
        } else {
          setState(() => showFilter = false);
        }
      });

    _fetchCustomerCounts();
    _searchController.addListener(() {
      setState(() => _showClearButton = _searchController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchCustomerCounts();
  }

  // ---------------- UI Builders ----------------
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
      color: Colors.white,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppColors.text, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 14, height: 1.0),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            if (_showClearButton)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                color: Colors.grey,
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/page_info.svg',
                width: 20,
                colorFilter:
                    const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              ),
              onPressed: _showFilterModal,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(Map<String, dynamic>? currentWorkspace, bool isLoading) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 150,
          height: 20,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4)),
        ),
      );
    }
    return StandardDropdownButton(
      text: currentWorkspace?['name'] ?? 'Không có tên',
      onTap: _showWorkspaceList,
      isEnabled: !isLoading,
      iconSize: 24,
      spaceBetweenTextAndIcon: 4,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildTabBar() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          onTap: (value) {
            context.read<CustomerServiceBloc>().add(
                  DisableFirebaseListenerRequested(
                      organizationId: widget.organizationId),
                );
            switch (value) {
              case 1:
                context.read<CustomerServiceBloc>().add(
                      LoadFirstProviderChat(
                          organizationId: widget.organizationId,
                          provider: 'FACEBOOK'),
                    );
                context.read<CustomerServiceBloc>().add(
                      ToggleFirebaseListenerRequested(
                        organizationId: widget.organizationId,
                        isEnabled: true,
                        platform: PlatformSocial.facebook,
                      ),
                    );
                break;
              case 2:
                context.read<CustomerServiceBloc>().add(
                      LoadFirstProviderChat(
                          organizationId: widget.organizationId,
                          provider: 'ZALO'),
                    );
                context.read<CustomerServiceBloc>().add(
                      ToggleFirebaseListenerRequested(
                        organizationId: widget.organizationId,
                        isEnabled: true,
                        platform: PlatformSocial.zalo,
                      ),
                    );
                break;
              default:
                break;
            }
          },
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
                      children: [Text(config.name), const SizedBox(width: 4)])))
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Actions ----------------
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _searchQuery = query);
      _loadCustomerService();
    });
  }

  Future<void> _fetchCustomerCounts() async {
    // TODO: Plug real API when available. Kept minimal to avoid unnecessary calls.
    developer.log('Fetching customer counts (stub)');
  }

  void _showWorkspaceList() {
    // TODO: Implement workspace list modal if needed.
  }

  void _showFilterModal() async {
    final result = await FilterModal.show(context, widget.organizationId, '',
        initialValue: _currentFilter);
    if (!mounted || result == null) return;
    setState(() => _currentFilter = result);
    _loadCustomerService();
  }

  void _loadCustomerService() {
    context.read<CustomerServiceBloc>().add(
          LoadCustomerService(
            organizationId:
                context.read<OrganizationBloc>().state.organizationId ?? '',
            pagingRequest: LeadPagingRequest(
              limit: 20,
              offset: 0,
              searchText: _searchQuery,
              fields: null,
              status: null,
              startDate: _currentFilter?.dateRange?.start,
              endDate: _currentFilter?.dateRange?.end,
              stageIds: null,
              sourceIds: _currentFilter?.categories.map((e) => e.id).toList(),
              utmSources: _currentFilter?.sources.map((e) => e.name).toList(),
              ratings: null,
              teamIds: null,
              assignees: _currentFilter?.assignees
                  .map((e) => e.profileId ?? '')
                  .toList(),
              tags: _currentFilter?.tags.map((e) => e.name ?? '').toList(),
              isBusiness: null,
              isArchive: _isArchive,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: _buildTitle(null, false),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(showFilter ? 56 : 0),
          child: Column(children: [
            _buildTabBar(),
            if (showFilter) _buildActiveFiltersBar(),
          ]),
        ),
      ),
      body: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
        builder: (context, state) {
          if (state.status == CustomerServiceStatus.loading)
            return _buildShimmerItem();
          if (state.status == CustomerServiceStatus.error) {
            return ErrorMessageWidget(
              message: state.error ?? '',
              onRetry: _fetchCustomerCounts,
            );
          }

          String? stageGroupId = AppConstants.stageObject.entries
              .firstWhere(
                (entry) => entry.value['name'] == 'all'.tr(),
                orElse: () => const MapEntry('', {}),
              )
              .key;
          stageGroupId = stageGroupId.isEmpty ? null : stageGroupId;

          return TabBarView(
            controller: _tabController,
            children: [
              CustomersList(
                organizationId: widget.organizationId,
                stageGroupId: stageGroupId,
                searchQuery: _searchQuery,
                queryParams: state.customerServices,
                onRefresh: _loadCustomerService,
              ),
              const FacebookMessagesTab(provider: 'FACEBOOK'),
              const FacebookMessagesTab(provider: 'ZALO'),
              CustomersList(
                organizationId: widget.organizationId,
                stageGroupId: stageGroupId,
                searchQuery: _searchQuery,
                queryParams: state.customerServices,
                onRefresh: _loadCustomerService,
              ),
              CustomersList(
                organizationId: widget.organizationId,
                stageGroupId: stageGroupId,
                searchQuery: _searchQuery,
                queryParams: state.customerServices,
                onRefresh: _loadCustomerService,
              ),
            ],
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        spacing: 15,
        backgroundColor: const Color(0xFF5C33F0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        activeIcon: Icons.close,
        iconTheme: const IconThemeData(color: Colors.white),
        children: [
          SpeedDialChild(
            label: 'Thủ công',
            backgroundColor: const Color(0xFFE3DFFF),
            child: const Icon(Icons.create, color: Colors.black),
            onTap: () {},
          ),
          SpeedDialChild(
            backgroundColor: const Color(0xFFE3DFFF),
            label: 'Google Sheet',
            child: const Icon(Icons.description, color: Colors.black),
            onTap: () {},
          ),
          SpeedDialChild(
            backgroundColor: const Color(0xFFE3DFFF),
            label: 'Nhập từ danh bạ',
            child:
                const Icon(Icons.perm_contact_cal_rounded, color: Colors.black),
            onTap: () async {
              if (await FlutterContacts.requestPermission()) {
                if (!context.mounted) return;
                // TODO: show bottom sheet to import contacts.
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final Color? activeColor;
  final VoidCallback onTap;

  const _FilterToggle({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
    this.activeColor,
  });

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
