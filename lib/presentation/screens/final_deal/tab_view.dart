import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/config/routes.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/final_deal/widget/switch_item.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../blocs/deal_activity/deal_activity_action.dart';
import '../../blocs/final_deal/final_deal_action.dart';

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  State<TabView> createState() => _TabViewState();
}

Widget _buildSkeletonTitle() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 260,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 2),
          Container(
            width: 160,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 2),
          Container(
            width: 100,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Container(
            width: 260,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 2),
          Container(
            width: 160,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 2),
          Container(
            width: 100,
            height: 12,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}

class _TabViewState extends State<TabView> {
  Offset? _longPressPosition;
  String? taskId;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalDealBloc, FinalDealState>(
        builder: (context, state) {
      List<TaskModel> taskes = state.taskes;

      if (state.status == FinalDealStatus.loadingListTask) {
        return _buildSkeletonTitle();
      }

      if (taskes.isEmpty) {
        return Center(
          child: Text('no_transaction_yet'.tr()),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh by dispatching the same event that loads the tasks
          if (state.selectedBusinessProcess != null) {
            context.read<FinalDealBloc>().add(GetBusinessProcessTask(
                  organizationId:
                      context.read<OrganizationBloc>().state.organizationId ??
                          '',
                  processId: '',
                  stage: state.selectedBusinessProcess,
                  customerId: '',
                  assignedTo: '',
                  status: '',
                  includeHistory: false,
                  page: 1,
                  pageSize: 10,
                ));
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: taskes.length,
          itemBuilder: (context, index) {
            final businessProcessTask = taskes[index];
            final timeAgo = timeago.format(
              businessProcessTask.createdDate ?? DateTime.now(),
              locale: context.locale.languageCode,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  log('tap');
                  context.read<DealActivityBloc>().add(LoadDealActivity(
                        organizationId: context
                                .read<OrganizationBloc>()
                                .state
                                .organizationId ??
                            '',
                        businessProcesses: state.businessProcesses,
                        task: businessProcessTask,
                        workspaceId: state.selectedWorkspace?.id ?? '',
                      ));
                  context
                      .push(
                    AppPaths.dealActivity,
                  )
                      .then((value) {
                    context.read<FinalDealBloc>().add(SelectBusinessProcess(
                          businessProcess: state.selectedBusinessProcess!,
                          organizationId: context
                                  .read<OrganizationBloc>()
                                  .state
                                  .organizationId ??
                              '',
                        ));
                  });
                },
                onTapDown: _storeTapPosition,
                onLongPress: () {
                  log('long press');
                  setState(() {
                    taskId = taskes[index].id ?? '';
                  });
                  _showContextMenu(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: taskId == taskes[index].id
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: taskId == taskes[index].id
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
                      //         color: Colors.red,
                      //         borderRadius: const BorderRadius.only(
                      //           topLeft: Radius.circular(12),
                      //           topRight: Radius.circular(12),
                      //         ),
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           Expanded(
                      //             flex: 1,
                      //             child: Container(
                      //               decoration: const BoxDecoration(
                      //                 color: Colors.red,
                      //                 borderRadius: BorderRadius.only(
                      //                   topLeft: Radius.circular(12),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //           Expanded(
                      //             flex: 1,
                      //             child: Container(
                      //               color: Colors.green,
                      //             ),
                      //           ),
                      //           Expanded(
                      //             flex: 1,
                      //             child: Container(
                      //               decoration: const BoxDecoration(
                      //                 color: Colors.blue,
                      //                 borderRadius: BorderRadius.only(
                      //                   topRight: Radius.circular(12),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),

                      // Transaction Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Amount
                            Text(
                              businessProcessTask.name ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatCurrency(
                                  businessProcessTask.orderValue ?? 0),
                              style: const TextStyle(
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
                                    businessProcessTask.username ??
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
                                _buildInteractionItem(
                                    Icons.phone_outlined, '0'),
                                const SizedBox(width: 10),
                                _buildInteractionItem(
                                    Icons.description_outlined, '0'),
                                const SizedBox(width: 10),
                                _buildInteractionItem(
                                    Icons.attach_file_outlined, '0'),
                                const Spacer(),
                                Tooltip(
                                  message: DateFormat('hh:mm dd/MM/yyyy')
                                      .format(businessProcessTask.createdDate ??
                                          DateTime.now()),
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
        ),
      );
    });
  }

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

    if (selected != null) {
      log('Bạn đã chọn: $selected');
      _handleMenuAction(selected, taskId ?? '');
    }
    setState(() {
      taskId = null;
    });
  }

  void _handleMenuAction(String action, String taskId) {
    switch (action) {
      case 'change_stage':
        // log('Change stage for transaction at index: $index');
        _showChangeStageBottomSheet(context, taskId);
        break;
      case 'delete_transaction':
        _showDeleteTransactionBottomSheet(context, taskId);
        // log('Delete transaction at index: $index');
        // TODO: Implement delete transaction functionality
        break;
    }
  }

  void _showDeleteTransactionBottomSheet(BuildContext context, String taskId) {
    Future.delayed(
      const Duration(milliseconds: 100),
      () => showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => BlocListener<DealActivityBloc, DealActivityState>(
          listener: (context, state) {
            if (state.status == DealActivityStatus.successEditOrder) {
              context.read<FinalDealBloc>().add(SelectBusinessProcess(
                    businessProcess: state.selectedBusinessProcess!,
                    organizationId:
                        context.read<OrganizationBloc>().state.organizationId ??
                            '',
                  ));
            }
          },
          child: AlertDialog(
            title: const Text('Xóa hoạt động?'),
            content: const Text('Bạn có chắc muốn xóa hoạt động này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  context.read<DealActivityBloc>().add(EditOrder(
                        organizationId: context
                                .read<OrganizationBloc>()
                                .state
                                .organizationId ??
                            '',
                        taskId: taskId,
                        type: EditOrderType.delete,
                      ));
                  // TODO: Implement delete action
                  Navigator.pop(context);
                },
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeStageBottomSheet(
    BuildContext context,
    String taskId,
  ) {
    showModalBottomSheet(
      useRootNavigator: true,
      // useSafeArea: ,
      // showDragHandle: true,

      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SwitchItem(
        taskId: taskId,
      ),
    );
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
}
