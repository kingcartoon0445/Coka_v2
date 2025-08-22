import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/screens/final_deal/tab_view.dart';

import '../../blocs/final_deal/final_deal_action.dart';
import '../../blocs/organization/organization_action_bloc.dart';

class FinalDealScreen extends StatefulWidget {
  const FinalDealScreen({super.key});

  @override
  _FinalDealScreenState createState() => _FinalDealScreenState();
}

class _FinalDealScreenState extends State<FinalDealScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<BusinessProcessModel> businessProcesses = [];
  Offset? _longPressPosition;
  int? _longPressedIndex;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinalDealBloc, FinalDealState>(
        listener: (context, state) {
      if (state.status == FinalDealStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error ?? 'Error')),
        );
      }
      if (state.status == FinalDealStatus.success) {}
      if (state.status == FinalDealStatus.successBusinessProcessTask) {
        setState(() {
          _tabController = TabController(
            length: state.businessProcesses.length,
            vsync: this,
            // initialIndex: state.businessProcesses.indexWhere(
            //     (element) => element.id == state.selectedBusinessProcess?.id)
          );
          _tabController.addListener(() {
            // Chỉ chạy khi animation đã hoàn tất
            if (!_tabController.indexIsChanging &&
                _tabController.index != _tabController.previousIndex) {
              context.read<FinalDealBloc>().add(SelectBusinessProcess(
                    businessProcess: businessProcesses[_tabController.index],
                    organizationId:
                        context.read<OrganizationBloc>().state.organizationId ??
                            '',
                  ));
            }
          });

          businessProcesses = state.businessProcesses;
        });
      }
    }, builder: (context, state) {
      if (state.status == FinalDealStatus.loadingBusinessProcess) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return businessProcesses.isEmpty
          ? const Center(
              child: Text('Nhóm này chưa được chia giai đoạn!'),
            )
          : Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    //  labelPadding: EdgeInsets.symmetric(horizontal: 12),
                    tabAlignment: TabAlignment.start,
                    labelPadding: const EdgeInsets.only(left: 6, right: 10),
                    isScrollable: true,
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: businessProcesses
                        .map((businessProcess) => Tab(
                              text: businessProcess.name,
                            ))
                        .toList(),
                  ),
                ),

                // Summary Section
                BlocBuilder<FinalDealBloc, FinalDealState>(
                    builder: (context, state) {
                  if (state.status == FinalDealStatus.loadingBusinessProcess ||
                      state.status == FinalDealStatus.loadingListTask) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 50,
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          Helpers.formatCurrency(
                            state.taskes
                                .map((e) => e.orderValue)
                                .fold(0, (sum, item) => sum + (item ?? 0)),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          height: 5,
                          width: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          '${state.taskes.length} ${'transaction'.tr()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // TabBarView for different content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      for (var businessProcess in businessProcesses) ...[
                        TabView()
                      ]
                      // Tab 1: Khách quan tâm

                      // Tab 2: Gửi thông tin chi tiết
                      // _buildSendInfoContent(),

                      // // Tab 3: Đặt lịch đi xem dự án
                      // _buildScheduleContent(),
                    ],
                  ),
                ),
              ],
            );
    });
  }

  Widget _buildInteractionItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _storeTapPosition(TapDownDetails details) {
    _longPressPosition = details.globalPosition;
  }

  void _handleMenuAction(String action, int index) {
    switch (action) {
      case 'change_stage':
        log('Change stage for transaction at index: $index');
        _showChangeStageBottomSheet(context, index);
        break;
      case 'delete_transaction':
        log('Delete transaction at index: $index');
        // TODO: Implement delete transaction functionality
        break;
    }
  }

  void _showChangeStageBottomSheet(BuildContext context, int index) {
    final List<Map<String, dynamic>> stages = [
      {
        'name': 'Khách quan tâm',
        'isSelected': true,
      },
      {
        'name': 'Gửi thông tin chi tiết',
        'isSelected': false,
      },
      {
        'name': 'Đặt lịch đi xem dự án',
        'isSelected': false,
      },
      {
        'name': 'Đã đi xem - chờ quyết định',
        'isSelected': false,
      },
      {
        'name': 'Chốt cọc',
        'isSelected': false,
      },
    ];

    showModalBottomSheet(
      useRootNavigator: true,
      // useSafeArea: ,
      // showDragHandle: true,

      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chuyển giai đoạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Stages List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: stages.length,
                itemBuilder: (context, stageIndex) {
                  final stage = stages[stageIndex];
                  return InkWell(
                    onTap: () {
                      // Update selected stage
                      for (int i = 0; i < stages.length; i++) {
                        stages[i]['isSelected'] = i == stageIndex;
                      }
                      Navigator.pop(context);
                      log('Changed stage to: ${stage['name']} for transaction at index: $index');
                      // TODO: Implement actual stage change logic
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            stage['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: stage['isSelected']
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: stage['isSelected']
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          stage['isSelected']
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 24,
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị menu ngay vị trí tay chạm
  void _showContextMenu(BuildContext context) async {
    if (_longPressPosition == null) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          _longPressPosition!.dx,
          _longPressPosition!.dy - 100,
          0,
          0,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'change_stage',
          child: Row(
            children: [
              Icon(
                Icons.swap_horiz,
                size: 20,
                color: Colors.black87,
              ),
              SizedBox(width: 8),
              Text(
                'Chuyển giai đoạn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete_transaction',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                'Xoá giao dịch',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Reset màu sắc khi menu đóng
    setState(() {
      _longPressedIndex = null;
    });

    if (selected != null) {
      log('Bạn đã chọn: $selected');
      _handleMenuAction(selected, _longPressedIndex ?? 0);
    }
  }

  Widget _buildSendInfoContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.send,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Gửi thông tin chi tiết',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nội dung sẽ được cập nhật sau',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Đặt lịch đi xem dự án',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nội dung sẽ được cập nhật sau',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
