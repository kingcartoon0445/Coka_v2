import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/journey_item.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/models/stage.dart';
// import 'journey_item.dart';

/// A decoupled version of the CustomerJourney widget with **no Bloc** dependency.
///
/// Parent is responsible for providing data and handling events.
/// - Provide [items], [hasMore], [isLoadingMore].
/// - Handle [onRefresh], [onLoadMore], [onSendNote].
/// - Optionally provide [reminderHeader] (e.g., your existing CustomerReminderCard) when [onlyNote] is false.
/// - Optionally provide [stagePickerBuilder] to render a stage picker when the input is focused.
/// - All labels can be customized via the [labels] map.
class CustomerJourneyView extends StatefulWidget {
  const CustomerJourneyView({
    super.key,
    this.onlyNote = false,
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onSendNote,
    this.stagePickerBuilder,
    this.reminderHeader,
    this.customerPhone,
    this.labels = const {},
  });

  /// Show only note composer (and history) if true. Otherwise show [reminderHeader] above.
  final bool onlyNote;

  /// Journey items to render.
  final List<ServiceDetailModel> items;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Whether a load-more request is in progress.
  final bool isLoadingMore;

  /// Pull-to-refresh handler.
  final Future<void> Function() onRefresh;

  /// Called when reaching near the bottom of the list.
  final VoidCallback onLoadMore;

  /// Called when user taps send. Note text and selected stage are provided.
  final void Function(String note, Stage? selectedStage) onSendNote;

  /// Builder to render the stage picker when the input is focused.
  /// Receives the current selected stage and a setter.
  final Widget Function(Stage? selected, ValueChanged<Stage?> setSelected)?
      stagePickerBuilder;

  /// Optional widget shown at the top (e.g., CustomerReminderCard) when [onlyNote] is false.
  final Widget? reminderHeader;

  /// Optional phone number used by the phone button when input is not focused.
  final String? customerPhone;

  /// Optional labels override. Keys:
  ///   today, yesterday, history_label, note_placeholder,
  ///   please_select_stage_or_note, loading_more, empty_journey,
  ///   cannot_open_dialer
  final Map<String, String> labels;

  @override
  State<CustomerJourneyView> createState() => _CustomerJourneyViewState();
}

class _CustomerJourneyViewState extends State<CustomerJourneyView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Stage? _selectedStage;
  bool _isInputFocused = false;
  late final AnimationController _iconAnim;

  // local debounce for scroll load-more
  DateTime _lastLoadMore = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _scrollCtrl.addListener(_onScroll);
    _iconAnim = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
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

  // ===== Labels helper =====
  String _l(String key, String fallback) => widget.labels[key] ?? fallback;

  // ===== Handlers =====
  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    setState(() => _isInputFocused = focused);
    if (focused) {
      _iconAnim.forward();
    } else {
      _iconAnim.reverse();
    }
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;

    // KHÔNG load-more nếu chưa có gì để scroll
    final canScroll = pos.maxScrollExtent > 0;
    if (!canScroll) return;

    final nearBottom = (pos.maxScrollExtent - pos.pixels) <= 200;
    if (nearBottom) _maybeLoadMore();
  }

  void _maybeLoadMore() {
    final now = DateTime.now();
    if (now.difference(_lastLoadMore).inMilliseconds < 350) return; // debounce
    _lastLoadMore = now;

    if (!widget.hasMore || widget.isLoadingMore) return;
    widget.onLoadMore();
  }

  Future<void> _openDialer(String? rawPhone) async {
    final p = rawPhone?.trim();
    if (p == null || p.isEmpty) return;

    final normalized = p.startsWith('+') ? p : (p.startsWith('84') ? '+$p' : p);

    final url = Uri(scheme: 'tel', path: normalized);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l('cannot_open_dialer', 'Cannot open dialer'))),
      );
    }
  }

  Map<DateTime, List<ServiceDetailModel>> _groupByDate(
      List<ServiceDetailModel> items) {
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
    if (date == today) return _l('today', 'Today');
    if (date == yesterday) return _l('yesterday', 'Yesterday');
    const weekDays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final weekDay = weekDays[date.weekday % 7];
    return '$weekDay, ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: (_isInputFocused ? 240 : 140) +
                      MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  if (!widget.onlyNote)
                    widget.reminderHeader ?? const SizedBox.shrink()
                  else
                    _NoteComposer(
                      focusNode: _focusNode,
                      controller: _noteCtrl,
                      isInputFocused: _isInputFocused,
                      iconAnim: _iconAnim,
                      hintText: _l('note_placeholder', 'Add a note...'),
                      onPhoneTap: () async => _openDialer(widget.customerPhone),
                      onSend: () {
                        if (!_isInputFocused) return;
                        final note = _noteCtrl.text.trim();
                        if (_selectedStage == null && note.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(_l('please_select_stage_or_note',
                                    'Please select a stage or enter a note'))),
                          );
                          return;
                        }
                        widget.onSendNote(note, _selectedStage);
                        _noteCtrl.clear();
                        setState(() {
                          _selectedStage = null;
                          _isInputFocused = false;
                        });
                        _iconAnim.reverse();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  _HistoryHeader(title: _l('history_label', 'History')),
                  if (widget.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                          child: Text(_l('empty_journey', 'No journeys yet'))),
                    )
                  else
                    ..._buildGrouped(widget.items),
                  if (widget.hasMore)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: widget.isLoadingMore
                            ? Column(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _l('loading_more', 'Loading more...'),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom area: stage picker or divider (wrapped in SafeArea)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: viewInsets.bottom > 0 ? 8 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isInputFocused && widget.stagePickerBuilder != null)
                      widget.stagePickerBuilder!(_selectedStage,
                          (s) => setState(() => _selectedStage = s))
                    else
                      const Divider(height: 1, color: Color(0x1A000000)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGrouped(List<ServiceDetailModel> items) {
    final grouped = _groupByDate(items);
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final widgets = <Widget>[];
    for (var i = 0; i < dates.length; i++) {
      final day = dates[i];
      widgets.add(_DateDivider(title: _dateTitle(day)));

      final dayItems = grouped[day]!;
      for (var j = 0; j < dayItems.length; j++) {
        final isLastOverall = i == dates.length - 1 && j == dayItems.length - 1;
        widgets.add(JourneyItem(dataItem: dayItems[j], isLast: isLastOverall));
      }
    }
    return widgets;
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.title});
  final String title;

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
            title,
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
  const _DateDivider({required this.title});
  final String title;

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
  const _NoteComposer({
    required this.focusNode,
    required this.controller,
    required this.isInputFocused,
    required this.iconAnim,
    required this.onSend,
    required this.onPhoneTap,
    required this.hintText,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final bool isInputFocused;
  final AnimationController iconAnim;
  final VoidCallback onSend;
  final VoidCallback onPhoneTap;
  final String hintText;

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
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
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
              hintText: hintText,
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
                    ? SvgPicture.asset(
                        'assets/icons/send_1_icon.svg',
                        key: const ValueKey('send'),
                        color: const Color(0xFF5C33F0),
                      )
                    : const Icon(
                        Icons.phone_outlined,
                        key: ValueKey('phone'),
                        color: Color(0xFF5C33F0),
                        size: 24,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
