import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:source_base/data/models/service_detail_response.dart';
import 'package:source_base/data/models/stage.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/reminder/customer_reminder_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../blocs/customer_service/customer_service_action.dart';
import '../../../../blocs/organization/organization_action_bloc.dart';
import 'stage_select.dart';
import 'journey_item.dart';

class CustomerJourney extends StatefulWidget {
  final bool onlyNote;
  const CustomerJourney({super.key, this.onlyNote = false});

  @override
  State<CustomerJourney> createState() => _CustomerJourneyState();
}

class _CustomerJourneyState extends State<CustomerJourney>
    with SingleTickerProviderStateMixin {
  final TextEditingController chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Stage? selectedStage;
  final _focusNode = FocusNode();
  bool _isInputFocused = false;
  late AnimationController _iconAnimationController;
  int _currentOffset = 0;
  static const int _pageSize = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _scrollController.addListener(_onScroll);
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  // Hàm nhóm các journey theo ngày
  Map<String, List<dynamic>> _groupJourneysByDate(
      List<ServiceDetailModel> journeys) {
    final Map<String, List<dynamic>> groupedJourneys = {};

    for (final journey in journeys) {
      if (journey.createdDate == null) continue;

      final date = DateTime.parse(journey.createdDate ?? '');
      final dateKey =
          DateTime(date.year, date.month, date.day).toIso8601String();

      if (!groupedJourneys.containsKey(dateKey)) {
        groupedJourneys[dateKey] = [];
      }
      groupedJourneys[dateKey]!.add(journey);
    }

    return groupedJourneys;
  }

  // Hàm tạo title cho ngày
  String _getDateTitle(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return "today".tr();
    } else if (date.isAtSameMomentAs(yesterday)) {
      return "yesterday".tr();
    } else {
      final weekDays = [
        "sunday".tr(),
        "monday".tr(),
        "tuesday".tr(),
        "wednesday".tr(),
        "thursday".tr(),
        "friday".tr(),
        "saturday".tr()
      ];
      final weekDay = weekDays[date.weekday % 7];
      return "$weekDay, ${date.day}/${date.month}/${date.year}";
    }
  }

  // Widget tạo divider với time title
  Widget _buildDateDivider(String dateTitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE8E8E8),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateTitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE8E8E8),
            ),
          ),
        ],
      ),
    );
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && selectedStage == null) {
      setState(() {
        _isInputFocused = true;
      });
      _iconAnimationController.forward();
    } else {
      setState(() {
        _isInputFocused = _focusNode.hasFocus;
      });
      if (!_focusNode.hasFocus) {
        _iconAnimationController.reverse();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = context.read<CustomerServiceBloc>().state;
    if (state.hasMoreServiceDetails &&
        state.status != CustomerServiceStatus.loadingMore &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      _currentOffset += _pageSize;

      // Lưu vị trí scroll hiện tại
      final currentScrollPosition = _scrollController.position.pixels;

      context.read<CustomerServiceBloc>().add(
            LoadMoreServiceDetails(
              organizationId:
                  context.read<OrganizationBloc>().state.organizationId ?? '',
              limit: _pageSize,
              offset: _currentOffset,
              type: widget.onlyNote ? 'create_note' : null,
            ),
          );

      // Khôi phục vị trí scroll sau khi state được cập nhật
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            currentScrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        _isLoadingMore = false;
      });
    }
  }

  void _showCallMethodBottomSheet() {
    final params = GoRouterState.of(context).pathParameters;
    // final customerId = params['customerId']!;
    final customerState = {};

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 60,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "call_method".tr(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final customerData = customerState;
                        if (customerData != null) {
                          final phone = customerData['phone'] as String?;
                          if (phone != null) {
                            final phoneNumber = phone.startsWith("84")
                                ? phone.replaceFirst("84", "0")
                                : phone;
                            final url = Uri.parse("tel:$phoneNumber");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          }
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF43B41F),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.call,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Gọi điện",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardVisible = viewInsets.bottom > 0;

    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerServiceBloc>().add(
                      LoadJourneyPaging(
                        organizationId: context
                                .read<OrganizationBloc>()
                                .state
                                .organizationId ??
                            "",
                      ),
                    );
              },
              child: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
                  bloc: context.read<CustomerServiceBloc>(),
                  builder: (context, state) {
                    final journeyList = state.serviceDetails;
                    return ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: _isInputFocused ? 240 : 140,
                      ),
                      children: [
                        if (!widget.onlyNote) ...[
                          CustomerReminderCard(
                            customerData: state.customerService,
                            onAddReminder: () {
                              // Có thể thêm logic để scroll đến reminder section hoặc highlight
                            },
                          ),
                        ] else ...[
                          Container(
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 240, 238, 231),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    focusNode: _focusNode,
                                    cursorColor: Colors.black,

                                    controller: chatController,
                                    maxLines: 5,
                                    // minLines: 1,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    onTap: () {
                                      setState(() {
                                        _isInputFocused = true;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      hintText: "note_placeholder".tr(),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: IconButton(
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    onPressed: () async {
                                      if (!_isInputFocused) {
                                        _showCallMethodBottomSheet();
                                      } else {
                                        if (selectedStage == null &&
                                            chatController.text
                                                .trim()
                                                .isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'please_select_stage_or_note'
                                                      .tr()),
                                            ),
                                          );
                                          return;
                                        }

                                        try {
                                          final noteContent =
                                              chatController.text.trim();
                                          final stageId =
                                              selectedStage?.id ?? '';

                                          print(
                                              'Sending journey update with stageId: $stageId, note: $noteContent');
                                          context
                                              .read<CustomerServiceBloc>()
                                              .add(
                                                PostCustomerNote(
                                                    customerId: context
                                                            .read<
                                                                CustomerServiceBloc>()
                                                            .state
                                                            .customerService
                                                            ?.id ??
                                                        '',
                                                    customerName: context
                                                            .read<
                                                                OrganizationBloc>()
                                                            .state
                                                            .user
                                                            ?.fullName ??
                                                        '',
                                                    note: noteContent,
                                                    organizationId: context
                                                            .read<
                                                                OrganizationBloc>()
                                                            .state
                                                            .organizationId ??
                                                        ''),
                                              );
                                          setState(() {});

                                          chatController.clear();
                                          setState(() {
                                            selectedStage = null;
                                            _isInputFocused = false;
                                          });
                                          _iconAnimationController.reverse();
                                          FocusScope.of(context).unfocus();
                                        } catch (e) {
                                          print(
                                              'Error sending journey update: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Có lỗi xảy ra khi gửi ghi chú: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    icon: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: !_isInputFocused
                                          ? const Icon(
                                              Icons.phone_outlined,
                                              key: ValueKey('phone'),
                                              color: Color(0xFF5C33F0),
                                              size: 24,
                                            )
                                          : SvgPicture.asset(
                                              "assets/icons/send_1_icon.svg",
                                              key: const ValueKey('send'),
                                              color: const Color(0xFF5C33F0),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (journeyList.isEmpty) ...[
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5C33F0)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    size: 16,
                                    color: Color(0xFF5C33F0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "history_label".tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2329),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text('Chưa có hành trình nào'),
                            ),
                          ),
                        ] else ...[
                          ...() {
                            final groupedJourneys =
                                _groupJourneysByDate(journeyList);
                            final sortedKeys = groupedJourneys.keys.toList()
                              ..sort((a, b) => DateTime.parse(b)
                                  .compareTo(DateTime.parse(a)));

                            List<Widget> widgets = [];

                            // Thêm header "Lịch sử" nếu có journey
                            if (sortedKeys.isNotEmpty) {
                              widgets.add(
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 20, 16, 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5C33F0)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.history,
                                          size: 16,
                                          color: Color(0xFF5C33F0),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "history_label".tr(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2329),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            for (int i = 0; i < sortedKeys.length; i++) {
                              final dateKey = sortedKeys[i];
                              final journeys = groupedJourneys[dateKey]!;
                              final dateTitle = _getDateTitle(dateKey);

                              // Thêm divider với time title
                              widgets.add(_buildDateDivider(dateTitle));

                              // Thêm các journey items của ngày đó
                              for (int j = 0; j < journeys.length; j++) {
                                final isLastItemOfDay =
                                    j == journeys.length - 1;
                                final isLastItemOverall =
                                    i == sortedKeys.length - 1 &&
                                        isLastItemOfDay;

                                widgets.add(
                                  JourneyItem(
                                    dataItem: journeys[j],
                                    isLast: isLastItemOverall,
                                  ),
                                );
                              }
                            }

                            return widgets;
                          }(),

                          // Loading indicator cho load more
                          if (state.hasMoreServiceDetails)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: state.status ==
                                        CustomerServiceStatus.loadingMore
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
                                            'Đang tải thêm...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ],
                    );
                  }),
            ),
          ),
          // Background trắng che phần trống 20px ở dưới
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: viewInsets.bottom + 20,
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: viewInsets.bottom + 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInputFocused)
                  GestureDetector(
                    onTap: () {
                      // Ngăn chặn sự kiện tap truyền xuống GestureDetector bên dưới
                    },
                    child: BlocBuilder<OrganizationBloc, OrganizationState>(
                        bloc: context.read<OrganizationBloc>(),
                        builder: (context, state) {
                          return StageSelect(
                            stage: selectedStage,
                            setStage: (stage) {
                              setState(() {
                                selectedStage = stage;
                              });
                            },
                            orgId: state.organizationId ?? "",
                            workspaceId: "",
                          );
                        }),
                  ),
                if (!_isInputFocused)
                  Divider(
                      height: 1, color: Colors.black.withValues(alpha: 0.1)),
                // Container(
                //   color: Colors.white,
                //   padding: const EdgeInsets.only(
                //       top: 8, bottom: 12, left: 16, right: 8),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: TextFormField(
                //           focusNode: _focusNode,
                //           cursorColor: Colors.black,
                //           controller: chatController,
                //           maxLines: 5,
                //           minLines: 1,
                //           keyboardType: TextInputType.multiline,
                //           textCapitalization: TextCapitalization.sentences,
                //           onTap: () {
                //             setState(() {
                //               _isInputFocused = true;
                //             });
                //           },
                //           decoration: InputDecoration(
                //             isDense: true,
                //             contentPadding: const EdgeInsets.symmetric(
                //               horizontal: 14,
                //               vertical: 10,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(18),
                //               borderSide: BorderSide.none,
                //             ),
                //             filled: true,
                //             fillColor: const Color(0x66F3EEEE),
                //             hintText: "Nhập nội dung ghi chú",
                //           ),
                //         ),
                //       ),
                //       Container(
                //         margin: const EdgeInsets.only(left: 8, right: 8),
                //         child: IconButton(
                //           padding: const EdgeInsets.all(8),
                //           constraints: const BoxConstraints(
                //             minWidth: 40,
                //             minHeight: 40,
                //           ),
                //           onPressed: () async {
                //             if (!_isInputFocused) {
                //               _showCallMethodBottomSheet();
                //             } else {
                //               if (selectedStage == null &&
                //                   chatController.text.trim().isEmpty) {
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   const SnackBar(
                //                     content: Text(
                //                         'Vui lòng chọn trạng thái hoặc nhập nội dung ghi chú'),
                //                   ),
                //                 );
                //                 return;
                //               }

                //               try {
                //                 final noteContent = chatController.text.trim();
                //                 final stageId = selectedStage?.id ?? '';

                //                 print(
                //                     'Sending journey update with stageId: $stageId, note: $noteContent');
                //                 context.read<CustomerServiceBloc>().add(
                //                       PostCustomerNote(
                //                           customerId: context
                //                                   .read<CustomerServiceBloc>()
                //                                   .state
                //                                   .customerService
                //                                   ?.id ??
                //                               '',
                //                           customerName: context
                //                                   .read<OrganizationBloc>()
                //                                   .state
                //                                   .user
                //                                   ?.fullName ??
                //                               '',
                //                           note: noteContent,
                //                           organizationId: context
                //                                   .read<OrganizationBloc>()
                //                                   .state
                //                                   .organizationId ??
                //                               ''),
                //                     );
                //                 setState(() {});

                //                 chatController.clear();
                //                 setState(() {
                //                   selectedStage = null;
                //                   _isInputFocused = false;
                //                 });
                //                 _iconAnimationController.reverse();
                //                 FocusScope.of(context).unfocus();
                //               } catch (e) {
                //                 print('Error sending journey update: $e');
                //                 if (context.mounted) {
                //                   ScaffoldMessenger.of(context).showSnackBar(
                //                     SnackBar(
                //                       content: Text(
                //                           'Có lỗi xảy ra khi gửi ghi chú: $e'),
                //                     ),
                //                   );
                //                 }
                //               }
                //             }
                //           },
                //           icon: AnimatedSwitcher(
                //             duration: const Duration(milliseconds: 300),
                //             transitionBuilder: (child, animation) {
                //               return ScaleTransition(
                //                 scale: animation,
                //                 child: FadeTransition(
                //                   opacity: animation,
                //                   child: child,
                //                 ),
                //               );
                //             },
                //             child: !_isInputFocused
                //                 ? const Icon(
                //                     Icons.phone_outlined,
                //                     key: ValueKey('phone'),
                //                     color: Color(0xFF5C33F0),
                //                     size: 24,
                //                   )
                //                 : SvgPicture.asset(
                //                     "assets/icons/send_1_icon.svg",
                //                     key: const ValueKey('send'),
                //                     color: const Color(0xFF5C33F0),
                //                   ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
