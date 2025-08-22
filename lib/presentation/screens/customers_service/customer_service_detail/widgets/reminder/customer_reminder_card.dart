import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/reminder.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/reminder/add_reminder_dialog.dart';
import 'package:source_base/presentation/screens/customers_service/widgets/web_reminder_item.dart';
import 'package:source_base/presentation/screens/theme/reminder_theme.dart';
import 'package:source_base/presentation/widget/dialog_member.dart';
import 'package:source_base/presentation/widget/reminder_constants.dart';

import '../../../../../blocs/customer_service/customer_service_action.dart';

class CustomerReminderCard extends StatefulWidget {
  final CustomerServiceModel? customerData;
  final VoidCallback? onAddReminder;

  const CustomerReminderCard({
    super.key,
    this.customerData,
    this.onAddReminder,
  });

  @override
  State<CustomerReminderCard> createState() => _CustomerReminderCardState();
}

class _CustomerReminderCardState extends State<CustomerReminderCard> {
  bool _showAllReminders = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read(reminderListProvider.notifier).loadReminders(
      //   organizationId: widget.organizationId,
      //   workspaceId: widget.workspaceId,
      //   contactId: widget.customerId,
      // );
    });
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        organizationId:
            context.read<OrganizationBloc>().state.organizationId.toString(),
        workspaceId: '',
        contactId: '',
        contactData: widget.customerData,
        onCreateReminder: (reminderBody) {
          context.read<CustomerServiceBloc>().add(CreateReminder(
                organizationId: context
                    .read<OrganizationBloc>()
                    .state
                    .organizationId
                    .toString(),
                body: reminderBody!,
              ));
        },
        onUpdateReminder: (reminderBody) {
          context.read<CustomerServiceBloc>().add(UpdateReminder(
                organizationId: context
                    .read<OrganizationBloc>()
                    .state
                    .organizationId
                    .toString(),
                body: reminderBody!,
              ));
        },
      ),
    ).then((_) {
      // Reload reminders after dialog closes
      _loadReminders();
    });
  }

  void _toggleReminderDone(ScheduleModel reminder, bool isDone) {
    context.read<CustomerServiceBloc>().add(UpdateNoteMark(
          ScheduleId: reminder.id ?? '',
          isDone: isDone,
          Notes: '',
        ));
    setState(() {
      reminder.isDone = isDone;
    });
  }

  void _editReminder(ScheduleModel reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        organizationId:
            context.read<OrganizationBloc>().state.organizationId ?? '',
        workspaceId: '',
        contactId: '',
        contactData: widget.customerData,
        editingReminder: reminder,
        onCreateReminder: (reminderBody) {
          context.read<CustomerServiceBloc>().add(CreateReminder(
                organizationId: context
                    .read<OrganizationBloc>()
                    .state
                    .organizationId
                    .toString(),
                body: reminderBody!,
              ));
        },
        onUpdateReminder: (reminderBody) {
          context.read<CustomerServiceBloc>().add(UpdateReminder(
                organizationId: context
                    .read<OrganizationBloc>()
                    .state
                    .organizationId
                    .toString(),
                body: reminderBody!,
              ));
        },
      ),
    ).then((_) {
      _loadReminders();
    });
  }

  void _deleteReminder(ScheduleModel reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhắc hẹn?'),
        content: const Text('Bạn có chắc chắn muốn xóa nhắc hẹn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // await ref.read(reminderListProvider.notifier).deleteReminder(reminder.id);
                context.read<CustomerServiceBloc>().add(DeleteReminder(
                      organizationId: context
                              .read<OrganizationBloc>()
                              .state
                              .organizationId ??
                          '',
                      reminderId: reminder.id ?? '',
                    ));
                if (!context.mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<Reminder> remindersAsync = [];
    // final pendingReminders = ref.watch(pendingRemindersProvider);
    // final todayReminders = ref.watch(todayRemindersProvider);
    // List<Reminder> overdueReminders = [];
    // Lấy tất cả reminders và sắp xếp: pending trước, completed sau
    // List<Reminder>  state.scheduleDetails = [];

    return BlocConsumer<CustomerServiceBloc, CustomerServiceState>(
        bloc: context.read<CustomerServiceBloc>(),
        listener: (context, state) {
          if (state.status == CustomerServiceStatus.successDeleteReminder) {
            ShowdialogNouti(context,
                type: NotifyType.success,
                title: 'Thành công',
                message: 'Đã xóa nhắc hẹn');
          }
        },
        builder: (context, state) {
          if (state.status == CustomerServiceStatus.error) {
            return _buildErrorState();
          } else if (state.status == CustomerServiceStatus.loading) {
            return _buildLoadingState();
          }

          // final scheduleDetails = state.scheduleDetails;
          final todayReminders = state.scheduleDetails
              .where((reminder) => _isToday(reminder))
              .toList();
          final overdueReminders = state.scheduleDetails
              .where((reminder) => _isOverdue(reminder))
              .toList();
          // final  state.scheduleDetails = scheduleDetails;

          return Theme(
            data: ReminderTheme.lightTheme,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C33F0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Color(0xFF5C33F0),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "activity_label".tr(),
                          style: ReminderTypography.heading3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Di chuyển badges về phía trái, sau title
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (overdueReminders.isNotEmpty)
                                  _buildStatChip(
                                    label: "overdue".tr(),
                                    count: overdueReminders.length,
                                    color: ReminderColors.error,
                                    icon: Icons.warning,
                                  ),
                                if (overdueReminders.isNotEmpty &&
                                    todayReminders.isNotEmpty)
                                  const SizedBox(width: 4),
                                if (todayReminders.isNotEmpty)
                                  _buildStatChip(
                                    label: 'Hôm nay',
                                    count: todayReminders.length,
                                    color: ReminderColors.warning,
                                    icon: Icons.today,
                                  ),
                                if (state.scheduleDetails.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ReminderColors.primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${state.scheduleDetails.length}',
                                      style:
                                          ReminderTypography.caption.copyWith(
                                        color: ReminderColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              ],
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => _showAddReminderDialog(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: ReminderColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "add".tr(),
                                  style: ReminderTypography.button.copyWith(
                                    color: ReminderColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Content
                    Column(
                      children: [
                        // Tất cả reminders (đã sắp xếp pending trước, completed sau)
                        const SizedBox(height: 8),
                        ...(_showAllReminders
                                ? state.scheduleDetails
                                : state.scheduleDetails.take(2))
                            .map((reminder) => WebReminderItem(
                                  reminder: reminder,
                                  onTap: () {},
                                  onToggleDone: (isDone) =>
                                      _toggleReminderDone(reminder, isDone),
                                  onEdit: () => _editReminder(reminder),
                                  onDelete: () => _deleteReminder(reminder),
                                )),
                        if (state.scheduleDetails.length > 2) ...[
                          const SizedBox(height: 6),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAllReminders = !_showAllReminders;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text(
                                  _showAllReminders
                                      ? "collapse".tr()
                                      : "${"view_more".tr()} ${state.scheduleDetails.length - 2} ${"activity_label".tr()}",
                                  style: ReminderTypography.body2.copyWith(
                                    color: ReminderColors.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (state.scheduleDetails.isEmpty) _buildEmptyState(),
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     // Tất cả reminders (đã sắp xếp pending trước, completed sau)
                    //     const SizedBox(height: 8),
                    //     ...(_showAllReminders
                    //             ?  state.scheduleDetails
                    //             :  state.scheduleDetails.take(2))
                    //         .map((reminder) => WebReminderItem(
                    //               reminder: reminder,
                    //               onTap: () {},
                    //               onToggleDone: (isDone) =>
                    //                   _toggleReminderDone(reminder, isDone),
                    //               onEdit: () => _editReminder(reminder),
                    //               onDelete: () => _deleteReminder(reminder),
                    //             )),
                    //     if ( state.scheduleDetails.length > 2) ...[
                    //       const SizedBox(height: 6),
                    //       Center(
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             setState(() {
                    //               _showAllReminders = !_showAllReminders;
                    //             });
                    //           },
                    //           child: Container(
                    //             padding: const EdgeInsets.symmetric(
                    //                 horizontal: 8, vertical: 4),
                    //             child: Text(
                    //               _showAllReminders
                    //                   ? 'Thu gọn'
                    //                   : 'Xem thêm ${ state.scheduleDetails.length - 2} hoạt động',
                    //               style: ReminderTypography.body2.copyWith(
                    //                 color: ReminderColors.primary,
                    //                 fontWeight: FontWeight.w500,
                    //                 fontSize: 12,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],

                    //   ],
                    // ),

                    // remindersAsync.when(
                    //   data: (_) {
                    //     if ( state.scheduleDetails.isEmpty) {
                    //       return _buildEmptyState();
                    //     }

                    //     return Column(
                    //       children: [
                    //         // Tất cả reminders (đã sắp xếp pending trước, completed sau)
                    //         const SizedBox(height: 8),
                    //         ...(_showAllReminders
                    //                 ?  state.scheduleDetails
                    //                 :  state.scheduleDetails.take(2))
                    //             .map((reminder) => WebReminderItem(
                    //                   reminder: reminder,
                    //                   onTap: () {},
                    //                   onToggleDone: (isDone) =>
                    //                       _toggleReminderDone(reminder, isDone),
                    //                   onEdit: () => _editReminder(reminder),
                    //                   onDelete: () => _deleteReminder(reminder),
                    //                 )),
                    //         if ( state.scheduleDetails.length > 2) ...[
                    //           const SizedBox(height: 6),
                    //           Center(
                    //             child: GestureDetector(
                    //               onTap: () {
                    //                 setState(() {
                    //                   _showAllReminders = !_showAllReminders;
                    //                 });
                    //               },
                    //               child: Container(
                    //                 padding: const EdgeInsets.symmetric(
                    //                     horizontal: 8, vertical: 4),
                    //                 child: Text(
                    //                   _showAllReminders
                    //                       ? 'Thu gọn'
                    //                       : 'Xem thêm ${ state.scheduleDetails.length - 2} hoạt động',
                    //                   style: ReminderTypography.body2.copyWith(
                    //                     color: ReminderColors.primary,
                    //                     fontWeight: FontWeight.w500,
                    //                     fontSize: 12,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ],
                    //     );
                    //   },
                    //   loading: () => _buildLoadingState(),
                    //   error: (error, _) => _buildErrorState(),
                    // ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    if (count == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ReminderColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule_outlined,
              size: 28,
              color: ReminderColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'no_activity_yet'.tr(),
            style: ReminderTypography.body1.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'add_reminder_message'.tr(),
            style: ReminderTypography.caption.copyWith(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5C33F0)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 32,
            color: Colors.red,
          ),
          const SizedBox(height: 6),
          const Text(
            'Không thể tải nhắc hẹn',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _loadReminders,
            child: const Text('Thử lại', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  bool _isOverdue(ScheduleModel reminder) {
    if (reminder.isDone == true || reminder.endTime == null) return false;

    try {
      final endTime = DateTime.parse(reminder.endTime!);
      return DateTime.now().isAfter(endTime);
    } catch (e) {
      return false;
    }
  }

  bool _isToday(ScheduleModel reminder) {
    try {
      final startTime = DateTime.parse(reminder.startTime ?? '');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final reminderDate =
          DateTime(startTime.year, startTime.month, startTime.day);
      return reminderDate.isAtSameMomentAs(today);
    } catch (e) {
      return false;
    }
  }

  String _formatTime(Reminder reminder) {
    try {
      final startTime = DateTime.parse(reminder.startTime);
      final timeFormat = DateFormat('HH:mm');
      final dateFormat = DateFormat('dd/MM');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final reminderDate =
          DateTime(startTime.year, startTime.month, startTime.day);

      if (reminderDate.isAtSameMomentAs(today)) {
        return 'Hôm nay, ${timeFormat.format(startTime)}';
      } else if (reminderDate
          .isAtSameMomentAs(today.add(const Duration(days: 1)))) {
        return 'Ngày mai, ${timeFormat.format(startTime)}';
      } else {
        return '${dateFormat.format(startTime)}, ${timeFormat.format(startTime)}';
      }
    } catch (e) {
      return reminder.time;
    }
  }

  Color _getTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.call:
        return Colors.green;
      case ScheduleType.meeting:
        return Colors.blue;
      case ScheduleType.meal:
        return Colors.orange;
      case ScheduleType.video:
        return Colors.purple;
      case ScheduleType.event:
        return Colors.indigo;
      case ScheduleType.document:
        return Colors.brown;
      default:
        return const Color(0xFF5C33F0);
    }
  }
}
