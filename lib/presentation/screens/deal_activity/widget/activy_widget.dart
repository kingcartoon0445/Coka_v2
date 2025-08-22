import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/schedule_response.dart'; 
import 'package:source_base/presentation/screens/customers_service/widgets/web_reminder_item.dart';
import 'package:source_base/presentation/screens/theme/reminder_theme.dart';

/// Decoupled CustomerReminderCard (không phụ thuộc Bloc):
/// - Nhận dữ liệu & callback từ cha.
/// - Không gọi context.read / BlocBuilder / BlocConsumer.
/// - Màn cha chịu trách nhiệm mở dialog, gọi API, phát event Bloc (nếu dùng).
class ActivityWidget extends StatefulWidget {
  const ActivityWidget({
    super.key,
    this.customerData,
    required this.scheduleDetails,
    required this.isLoading,
    required this.isError,
    required this.onReload,
    required this.onAddReminder,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  /// Tuỳ chọn: chuyển qua cha nếu AddReminderDialog cần dùng dữ liệu khách hàng
  final CustomerServiceModel? customerData;

  /// Danh sách nhắc hẹn để render
  final List<ScheduleModel> scheduleDetails;

  /// Trạng thái tải
  final bool isLoading;
  final bool isError;

  /// Callback khi cần reload (ví dụ bấm "Thử lại" hoặc sau khi đóng dialog ở cha)
  final VoidCallback onReload;

  /// Callback bấm "Thêm" – màn cha tự mở AddReminderDialog (nếu muốn)
  final VoidCallback onAddReminder;

  /// Callback khi toggle done
  final void Function(ScheduleModel reminder, bool isDone) onToggleDone;

  /// Callback khi edit 1 reminder
  final void Function(ScheduleModel reminder) onEdit;

  /// Callback khi delete 1 reminder
  final void Function(ScheduleModel reminder) onDelete;

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  bool _showAllReminders = false;

  @override
  void initState() {
    super.initState();
    // Nếu muốn tự load lần đầu, gọi widget.onReload() tại đây.
    // Nhưng thường màn cha chủ động gọi trước khi build widget này.
    // WidgetsBinding.instance.addPostFrameCallback((_) => widget.onReload());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildLoadingState();
    if (widget.isError) return _buildErrorState();

    final scheduleDetails = widget.scheduleDetails;
    final todayReminders = scheduleDetails.where((r) => _isToday(r)).toList();
    final overdueReminders =
        scheduleDetails.where((r) => _isOverdue(r)).toList();

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
                          if (scheduleDetails.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ReminderColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${scheduleDetails.length}',
                                style: ReminderTypography.caption.copyWith(
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
                    onTap: widget.onAddReminder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
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
                  const SizedBox(height: 8),
                  ...(_showAllReminders
                          ? scheduleDetails
                          : scheduleDetails.take(2))
                      .map(
                    (reminder) => WebReminderItem(
                      reminder: reminder,
                      onTap:
                          () {}, // nếu muốn mở chi tiết, truyền callback khác
                      onToggleDone: (isDone) =>
                          widget.onToggleDone(reminder, isDone),
                      onEdit: () => widget.onEdit(reminder),
                      onDelete: () => _confirmDelete(reminder),
                    ),
                  ),
                  if (scheduleDetails.length > 2) ...[
                    const SizedBox(height: 6),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _showAllReminders = !_showAllReminders;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                            _showAllReminders
                                ? "collapse".tr()
                                : "${"view_more".tr()} ${scheduleDetails.length - 2} ${"activity_label".tr()}",
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
                  if (scheduleDetails.isEmpty) _buildEmptyState(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- helpers & UI parts ----------------

  void _confirmDelete(ScheduleModel reminder) {
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
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(reminder);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
            'Chưa có hoạt động nào',
            style: ReminderTypography.body1.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn "Thêm" để tạo nhắc hẹn mới',
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
            onPressed: widget.onReload,
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
    } catch (_) {
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
    } catch (_) {
      return false;
    }
  }
}
