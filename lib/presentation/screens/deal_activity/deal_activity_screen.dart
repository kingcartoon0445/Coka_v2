import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_action.dart';
import 'package:source_base/presentation/screens/deal_activity/widget/customer_journey_screen.dart';
import 'package:source_base/presentation/screens/final_deal/detail_deal_page.dart';
import 'package:source_base/presentation/widget/dialog_member.dart';

import 'widget/stage_progress_bar.dart';

class DealActivityScreen extends StatefulWidget {
  const DealActivityScreen({super.key});

  @override
  State<DealActivityScreen> createState() => _DealActivityScreenState();
}

class _DealActivityScreenState extends State<DealActivityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final DealActivityBloc _dealActivityBloc;

  @override
  void initState() {
    super.initState();
    _dealActivityBloc = context.read<DealActivityBloc>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<DealActivityBloc, DealActivityState>(
      listener: (context, state) {
        if (state.status == DealActivityStatus.error) {
          ShowdialogNouti(context,
              type: NotifyType.error,
              title: state.errorTitle ?? '',
              message: state.error ?? '',
              actionText: 'OK', onAction: () {
            Navigator.maybePop(context);
          });
        }
        if (state.status == DealActivityStatus.successEditOrder) {
          ShowdialogNouti(context,
              type: NotifyType.success,
              title: 'Thành công',
              message: 'Đã xử lý đơn hàng',
              actionText: 'OK', onAction: () {
            Navigator.maybePop(context);
          });
        }

        if (state.status == DealActivityStatus.successUpdateStatus) {
          _dealActivityBloc.add(RemoveState());

          Navigator.maybePop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: AppColors.secondary,
            onPressed: () {
              _dealActivityBloc.add(RemoveState());
              Navigator.maybePop(context);
            },
          ),
          centerTitle: true,
          title: InkWell(
            onTap: () {
              _dealActivityBloc.add(LoadDetailTask(
                organizationId: _dealActivityBloc.state.organizationId ?? '',
                taskId: _dealActivityBloc.state.task?.id ?? '',
                orderId: _dealActivityBloc.state.task?.orderId ?? '',
              ));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailDealPage(),
                ),
              );
            },
            child: Text(
              _dealActivityBloc.state.task?.name ?? 'Không có tiêu đề',
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              offset: const Offset(0, 0),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.public, size: 25),
                      const SizedBox(width: 8),
                      Text('public'.tr()),
                    ],
                  ),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.archive, size: 25),
                      const SizedBox(width: 8),
                      Text('archive'.tr()),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        _dealActivityBloc.add(EditOrder(
                          organizationId:
                              _dealActivityBloc.state.organizationId ?? '',
                          taskId: _dealActivityBloc.state.task?.id ?? '',
                          type: EditOrderType.archive,
                        ));
                        // Add your public action logic here
                      },
                    );
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.copy, size: 25),
                      const SizedBox(width: 8),
                      Text('copy'.tr()),
                    ],
                  ),
                  onTap: () {
                    // TODO: Implement duplicate action
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        _dealActivityBloc.add(EditOrder(
                          organizationId:
                              _dealActivityBloc.state.organizationId ?? '',
                          taskId: _dealActivityBloc.state.task?.id ?? '',
                          type: EditOrderType.duplicate,
                        ));
                        // Add your duplicate action logic here
                      },
                    );
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          color: Colors.red, size: 25),
                      const SizedBox(width: 8),
                      Text(
                        'delete'.tr(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('delete_message'.tr(namedArgs: {
                            'name': _dealActivityBloc.state.task?.name ?? ''
                          })),
                          content: Text('delete_message'.tr(namedArgs: {
                            'name': _dealActivityBloc.state.task?.name ?? ''
                          })),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('cancel'.tr()),
                            ),
                            TextButton(
                              onPressed: () {
                                _dealActivityBloc.add(EditOrder(
                                  organizationId:
                                      _dealActivityBloc.state.organizationId ??
                                          '',
                                  taskId:
                                      _dealActivityBloc.state.task?.id ?? '',
                                  type: EditOrderType.delete,
                                ));
                                // TODO: Implement delete action
                                Navigator.pop(context);
                              },
                              child: Text(
                                'delete'.tr(),
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<DealActivityBloc, DealActivityState>(
                  builder: (context, state) {
                int index = state.businessProcesses.indexWhere((element) =>
                    element.id == state.selectedBusinessProcess?.id);
                return StageProgressBar(
                  stages: state.businessProcesses,
                  currentStage: state.selectedBusinessProcess,
                  onNext: index < state.businessProcesses.length - 1
                      ? () {
                          _dealActivityBloc.add(ChangeStage(
                            businessProcess: state.businessProcesses[index + 1],
                          ));
                        }
                      : null,
                  onPrev: index > 0
                      ? () {
                          _dealActivityBloc.add(ChangeStage(
                            businessProcess: state.businessProcesses[index - 1],
                          ));
                        }
                      : null,
                );
              }),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionPill(
                        label: 'failed'.tr(),
                        color: Colors.red,
                        icon: Icons.close,
                        onTap: () {
                          context
                              .read<DealActivityBloc>()
                              .add(const UpdateStatus(
                                isSuccess: false,
                              ));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionPill(
                        label: 'success'.tr(),
                        color: const Color(0xFF22C55E),
                        icon: Icons.check,
                        onTap: () {
                          context
                              .read<DealActivityBloc>()
                              .add(const UpdateStatus(
                                isSuccess: true,
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  indicatorColor: theme.primaryColor,
                  labelColor: Colors.black,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.only(left: 16, right: 16),
                  tabAlignment: TabAlignment.start,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: 'activity'.tr()),
                    Tab(text: 'note_label'.tr()),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    CustomerJourneyScreen(),
                    CustomerJourneyScreen(onlyNote: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======= Action pills =======
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}

// ======= Timeline =======
class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});
  final List<_TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          _TimelineTile(
            item: items[i],
            isFirst: i == 0,
            isLast: i == items.length - 1,
          )
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });
  final _TimelineItem item;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: _TimelineRail(isFirst: isFirst, isLast: isLast),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(item.leading,
                        size: 18, color: const Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.time}  •  ${item.actor}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.isFirst, required this.isLast});
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: isFirst ? 20 : 0,
            bottom: isLast ? c.maxHeight - 20 : 0,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.circle, size: 6, color: Color(0xFF9CA3AF)),
          ),
        ],
      );
    });
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 2;

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y),
          Offset(size.width / 2, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineItem {
  final String time;
  final String actor;
  final String title;
  final IconData leading;
  _TimelineItem({
    required this.time,
    required this.actor,
    required this.title,
    required this.leading,
  });
}
