import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:source_base/data/models/schedule_response.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/models/stage.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_action.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_action.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_state.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/journey_item.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/reminder/add_reminder_dialog.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/stage_select.dart';
import 'package:url_launcher/url_launcher.dart';

import 'activy_widget.dart';

/// Refactored & optimized version of CustomerJourneyScreen
/// - Extracted widgets
/// - Heavier use of consts
/// - Reduced rebuilds via smaller widgets & Bloc selectors
/// - Safer scroll pagination (guarded & debounced)
/// - Cleaner date grouping/formatting
class CustomerJourneyScreen extends StatefulWidget {
  final bool onlyNote;
  const CustomerJourneyScreen({super.key, this.onlyNote = false});

  @override
  State<CustomerJourneyScreen> createState() => _CustomerJourneyScreenState();
}

class _CustomerJourneyScreenState extends State<CustomerJourneyScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Stage? _selectedStage;
  bool _isInputFocused = false;
  late final AnimationController _iconAnim;

  // paging
  int _currentOffset = 0;
  static const int _pageSize = 20;
  bool _isPaginating = false;
  DateTime _lastLoadMore = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _scrollCtrl.addListener(_onScroll);
    _iconAnim = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    _noteCtrl.dispose();
    _iconAnim.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused && _selectedStage == null) {
      setState(() => _isInputFocused = true);
      _iconAnim.forward();
    } else {
      setState(() => _isInputFocused = focused);
      if (!focused) _iconAnim.reverse();
    }
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    // Debounce: at most once every 350ms
    final now = DateTime.now();
    if (now.difference(_lastLoadMore).inMilliseconds < 350) return;
    _lastLoadMore = now;

    final state = context.read<CustomerServiceBloc>().state;
    if (!state.hasMoreServiceDetails ||
        state.status == CustomerServiceStatus.loadingMore ||
        _isPaginating) return;

    _isPaginating = true;
    _currentOffset += _pageSize;

    final currentScroll = _scrollCtrl.position.pixels;

    context.read<CustomerServiceBloc>().add(
          LoadMoreServiceDetails(
            organizationId:
                context.read<OrganizationBloc>().state.organizationId ?? '',
            limit: _pageSize,
            offset: _currentOffset,
            type: widget.onlyNote ? 'create_note' : null,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(currentScroll);
      }
      _isPaginating = false;
    });
  }

  Future<void> _openDialer(String? rawPhone) async {
    if (rawPhone == null || rawPhone.isEmpty) return;
    final phone =
        rawPhone.startsWith('84') ? rawPhone.replaceFirst('84', '0') : rawPhone;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Map<DateTime, List<ServiceDetailModel>> _groupJourneysByDate(
    List<ServiceDetailModel> items,
  ) {
    final map = <DateTime, List<ServiceDetailModel>>{};
    for (final j in items) {
      if (j.createdDate == null) continue;
      final d = DateTime.parse(j.createdDate!);
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(j);
    }
    return map;
  }

  String _dateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'today'.tr();
    if (date == yesterday) return 'yesterday'.tr();

    final weekDays = [
      'sunday'.tr(),
      'monday'.tr(),
      'tuesday'.tr(),
      'wednesday'.tr(),
      'thursday'.tr(),
      'friday'.tr(),
      'saturday'.tr(),
    ];
    final weekDay = weekDays[date.weekday % 7];
    return '$weekDay, ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardVisible = viewInsets.bottom > 0;

    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DealActivityBloc>().add(
                      LoadDealActivity(
                        organizationId: context
                                .read<OrganizationBloc>()
                                .state
                                .organizationId ??
                            '',
                        task: null,
                        workspaceId: null,
                      ),
                    );
              },
              child: BlocBuilder<DealActivityBloc, DealActivityState>(
                buildWhen: (prev, next) =>
                    prev.scheduleModels != next.scheduleModels ||
                    prev.status != next.status,
                builder: (context, state) {
                  final noteSimpleModels = state.noteSimpleModels;

                  return ListView(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.only(bottom: _isInputFocused ? 240 : 140),
                    children: [
                      if (!widget.onlyNote) ...[
                        ActivityWidget(
                          onAddReminder: () {
                            _showAddReminderDialog(null);
                          },
                          onToggleDone: (reminder, isDone) {},
                          onEdit: (reminder) {
                            _showAddReminderDialog(reminder);
                          },
                          onDelete: (reminder) {
                            context.read<DealActivityBloc>().add(
                                  DeleteReminderWorkspace(
                                    reminderId: reminder.id ?? '',
                                  ),
                                );
                          },
                          scheduleDetails: state.scheduleModels,
                          isLoading: state.status == DealActivityStatus.loading,
                          isError: state.status == DealActivityStatus.error,
                          onReload: () {
                            context
                                .read<DealActivityBloc>()
                                .add(LoadDealActivity(
                                  organizationId: context
                                          .read<OrganizationBloc>()
                                          .state
                                          .organizationId ??
                                      '',
                                  task: null,
                                  workspaceId: null,
                                ));
                          },
                        )
                      ] else ...[
                        _NoteComposer(
                          focusNode: _focusNode,
                          controller: _noteCtrl,
                          isInputFocused: _isInputFocused,
                          iconAnim: _iconAnim,
                          onPhoneTap: () async {
                            // Replace with real customer data
                            await _openDialer(null);
                          },
                          onSend: () {
                            if (!_isInputFocused) return;

                            final note = _noteCtrl.text.trim();
                            if (_selectedStage == null && note.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'please_select_stage_or_note'.tr())),
                              );
                              return;
                            }

                            context.read<CustomerServiceBloc>().add(
                                  PostCustomerNote(
                                    customerId: context
                                            .read<CustomerServiceBloc>()
                                            .state
                                            .customerService
                                            ?.id ??
                                        '',
                                    customerName: context
                                            .read<OrganizationBloc>()
                                            .state
                                            .user
                                            ?.fullName ??
                                        '',
                                    note: note,
                                    organizationId: context
                                            .read<OrganizationBloc>()
                                            .state
                                            .organizationId ??
                                        '',
                                  ),
                                );

                            _noteCtrl.clear();
                            setState(() {
                              _selectedStage = null;
                              _isInputFocused = false;
                            });
                            _iconAnim.reverse();
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ],
                      const _HistoryHeader(),
                      if (noteSimpleModels.isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Chưa có hành trình nào'),
                        ))
                      else
                        ..._buildGroupedJourneys(noteSimpleModels),
                      // if (state.hasMoreServiceDetails)
                      //   Padding(
                      //     padding: const EdgeInsets.all(16),
                      //     child: Center(
                      //       child: state.status ==
                      //               CustomerServiceStatus.loadingMore
                      //           ? const Column(
                      //               children: [
                      //                 SizedBox(
                      //                     width: 20,
                      //                     height: 20,
                      //                     child: CircularProgressIndicator(
                      //                         strokeWidth: 2)),
                      //                 SizedBox(height: 8),
                      //                 Text('Đang tải thêm...',
                      //                     style: TextStyle(
                      //                         fontSize: 12,
                      //                         color: Colors.grey)),
                      //               ],
                      //             )
                      //           : const SizedBox.shrink(),
                      //     ),
                      //   ),
                    ],
                  );
                },
              ),
            ),
          ),

          // white background to cover bottom gap
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: viewInsets.bottom + 20,
            child: const ColoredBox(color: Colors.white),
          ),

          // Bottom area: stage select + divider
          Positioned(
            bottom: viewInsets.bottom + 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInputFocused)
                  BlocBuilder<OrganizationBloc, OrganizationState>(
                    buildWhen: (p, n) => p.organizationId != n.organizationId,
                    builder: (context, state) {
                      return StageSelect(
                        stage: _selectedStage,
                        setStage: (s) => setState(() => _selectedStage = s),
                        orgId: state.organizationId ?? '',
                        workspaceId: '',
                      );
                    },
                  )
                else
                  Divider(height: 1, color: Colors.black.withOpacity(0.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(ScheduleModel? editingReminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        onCreateReminder: (reminderBody) {
          context.read<DealActivityBloc>().add(CreateReminderWorkspace(
                reminder: reminderBody!,
              ));
        },
        onUpdateReminder: (reminderBody) {
          context.read<DealActivityBloc>().add(UpdateReminderWorkspace(
                reminder: reminderBody!,
              ));
        },
        organizationId:
            context.read<OrganizationBloc>().state.organizationId.toString(),
        workspaceId: context.read<DealActivityBloc>().state.workspaceId ?? '',
        contactId: '',
        editingReminder: editingReminder,
        contactData: null,
      ),
    ).then((_) {
      // Reload reminders after dialog closes
      // _loadReminders();
    });
  }

  List<Widget> _buildGroupedJourneys(
      List<ServiceDetailModel> noteSimpleModels) {
    final grouped = _groupJourneysByDate(noteSimpleModels);
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final widgets = <Widget>[];
    for (var i = 0; i < dates.length; i++) {
      final day = dates[i];
      widgets.add(_DateDivider(title: _dateTitle(day)));

      final items = grouped[day]!;
      for (var j = 0; j < items.length; j++) {
        final isLastOverall = i == dates.length - 1 && j == items.length - 1;
        widgets.add(JourneyItem(dataItem: items[j], isLast: isLastOverall));
      }
    }
    return widgets;
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF5C33F0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                const Icon(Icons.history, size: 16, color: Color(0xFF5C33F0)),
          ),
          const SizedBox(width: 8),
          Text(
            'history_label'.tr(),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2329)),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String title;
  const _DateDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
              child:
                  Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8))),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(
              child:
                  Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8))),
        ],
      ),
    );
  }
}

class _NoteComposer extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool isInputFocused;
  final AnimationController iconAnim;
  final VoidCallback onSend;
  final VoidCallback onPhoneTap;

  const _NoteComposer({
    required this.focusNode,
    required this.controller,
    required this.isInputFocused,
    required this.iconAnim,
    required this.onSend,
    required this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 238, 231),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            cursorColor: Colors.black,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onTap: () {},
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              hintText: 'note_placeholder'.tr(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () => isInputFocused ? onSend() : onPhoneTap(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: isInputFocused
                    ? SvgPicture.asset('assets/icons/send_1_icon.svg',
                        key: const ValueKey('send'),
                        color: const Color(0xFF5C33F0))
                    : const Icon(Icons.phone_outlined,
                        key: ValueKey('phone'),
                        color: Color(0xFF5C33F0),
                        size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
