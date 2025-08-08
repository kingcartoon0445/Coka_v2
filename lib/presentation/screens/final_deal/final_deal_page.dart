import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';

import '../../blocs/final_deal/final_deal_action.dart';
import '../../blocs/organization/organization_action_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class FinalDealScreen extends StatefulWidget {
  const FinalDealScreen({super.key});

  @override
  _FinalDealScreenState createState() => _FinalDealScreenState();
}

class _FinalDealScreenState extends State<FinalDealScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> transactions = [
    {
      'name': 'Nguyễn Trần Thị Bích Trâm',
      'amount': '2,000,000,000',
      'date': '8p',
      'rooms': 2,
      'baths': 2,
      'garages': 2,
      'project': 'Azvidi',
      'status': 'active'
    },
    {
      'name': 'Lê Tuấn Cường',
      'amount': '2,000,000,000',
      'date': '8p',
      'rooms': 2,
      'baths': 2,
      'garages': 2,
      'project': 'Azvidi',
      'status': 'active'
    },
    {
      'name': 'Hồ Minh Tân',
      'amount': '2,000,000,000',
      'date': '8p',
      'rooms': 2,
      'baths': 2,
      'garages': 2,
      'project': 'Azvidi',
      'status': 'active'
    },
  ];
  Offset? _longPressPosition;
  int? _longPressedIndex;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<FinalDealBloc>().add(FinalDealGetAllWorkspace(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? '',
        ));
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
    }, builder: (context, state) {
      if (state.status == FinalDealStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      _tabController =
          TabController(length: state.businessProcesses.length, vsync: this);
      return Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              padding: EdgeInsets.zero,
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
              tabs: state.businessProcesses
                  .map((businessProcess) => Tab(
                        text: businessProcess.name,
                      ))
                  .toList(),
            ),
          ),

          // Summary Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '???,??? ₫',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                const Text(
                  '? Giao dịch',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // TabBarView for different content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (var businessProcess in state.businessProcesses) ...[
                  _buildTransactionsList(),
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
                      fontWeight: FontWeight.bold,
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
                              ? Icon(
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

  Widget _buildTransactionsList() {
    return BlocBuilder<FinalDealBloc, FinalDealState>(
        builder: (context, state) {
      List<BusinessProcessTaskModel> businessProcessTasks =
          state.businessProcessTasks;
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: businessProcessTasks.length,
        itemBuilder: (context, index) {
          final businessProcessTask = businessProcessTasks[index];
          final timeAgo = timeago.format(
            DateTime.parse(businessProcessTask.createdDate ?? ''),
            locale: context.locale.languageCode,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                log('tap');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const TransactionDetailScreen()),
                // );
              },
              onTapDown: _storeTapPosition,
              onLongPress: () {
                log('long press');
                setState(() {
                  _longPressedIndex = index;
                });
                _showContextMenu(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _longPressedIndex == index
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _longPressedIndex == index
                          ? AppColors.primary.withOpacity(0.6)
                          : Colors.grey.withOpacity(0.6)),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.1),
                  //     spreadRadius: 1,
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: Column(
                  children: [
                    // Status Indicator
                    // Container(
                    //   height: 4,
                    //   decoration: BoxDecoration(
                    //     color: Colors.red,
                    //     borderRadius: const BorderRadius.only(
                    //       topLeft: Radius.circular(12),
                    //       topRight: Radius.circular(12),
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         flex: 1,
                    //         child: Container(
                    //           decoration: const BoxDecoration(
                    //             color: Colors.red,
                    //             borderRadius: BorderRadius.only(
                    //               topLeft: Radius.circular(12),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         flex: 1,
                    //         child: Container(
                    //           color: Colors.green,
                    //         ),
                    //       ),
                    //       Expanded(
                    //         flex: 1,
                    //         child: Container(
                    //           decoration: const BoxDecoration(
                    //             color: Colors.blue,
                    //             borderRadius: BorderRadius.only(
                    //               topRight: Radius.circular(12),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Transaction Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Amount
                          Text(
                            businessProcessTask.name ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '????? VNĐ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Customer Info
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  businessProcessTask.customerInfo ??
                                      'Không có tên',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // const SizedBox(height: 4),

                          // // Company Info
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     const Icon(
                          //       Icons.business_outlined,
                          //       size: 16,
                          //       color: Colors.black,
                          //     ),
                          //     const SizedBox(width: 6),
                          //     Text(
                          //       businessProcessTask.  ?? '',
                          //       style: const TextStyle(
                          //         fontSize: 14,
                          //         color: Colors.black,
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          const SizedBox(height: 12),

                          // Interaction Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildInteractionItem(
                                  Icons.calendar_month_outlined, '0'),
                              const SizedBox(width: 10),
                              _buildInteractionItem(Icons.phone_outlined, '0'),
                              const SizedBox(width: 10),
                              _buildInteractionItem(
                                  Icons.description_outlined, '0'),
                              const SizedBox(width: 10),
                              _buildInteractionItem(
                                  Icons.attach_file_outlined, '0'),
                              Spacer(),
                              Tooltip(
                                message: DateFormat('hh:mm dd/MM/yyyy').format(
                                    DateTime.parse(
                                        businessProcessTask.createdDate ?? '')),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      timeAgo ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Time and Status
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
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
        PopupMenuItem<String>(
          value: 'change_stage',
          child: Row(
            children: [
              const Icon(
                Icons.swap_horiz,
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chuyển giai đoạn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete_transaction',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              const Text(
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
