import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'providers/customer_detail_provider.dart'; // Tạm thời comment lại
// import 'providers/customer_activity_provider.dart'; // Tạm thời comment lại
import 'package:shimmer/shimmer.dart'; // Thêm import shimmer
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/customer/customer_screen.dart';
import 'package:source_base/presentation/screens/customers_service/customer_service_detail/widgets/customer_journey.dart';

import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import '../../../blocs/customer_service/customer_service_action.dart';
import 'widgets/assign_to_bottomsheet.dart';
// import '../../../../../../shared/widgets/avatar_widget.dart'; // Remove duplicate import

class CustomerDetailPage extends StatefulWidget {
  // final String organizationId;
  // final String workspaceId;
  // final String customerId;

  const CustomerDetailPage({
    super.key,
    // required this.organizationId,
    // required this.workspaceId,
    // required this.customerId,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Future.microtask(() {
    //   // ref
    //   //     .read(customerDetailProvider(widget.customerId).notifier)
    //   //     .loadCustomerDetail(widget.organizationId, widget.workspaceId)
    //   //     .then((customerDetail) {
    //   //   if (customerDetail == null && mounted) {
    //   //     // Lỗi sẽ được hiển thị trong phần error của widget, không cần xử lý thêm ở đây
    //   //   }
    //   // }).catchError((e) {
    //   //   if (mounted) {
    //   //     ScaffoldMessenger.of(context).showSnackBar(
    //   //       SnackBar(
    //   //         content: Text('Lỗi: ${e.toString()}'),
    //   //       ),
    //   //     );
    //   //     context.go('/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers');
    //   //   }
    //   // });
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAssigneeInfo(CustomerServiceModel customerDetail) {
    final assignToUser = customerDetail.assignees;
    final assignToUsers = customerDetail.assignees;
    // final teamResponse = customerDetail.assignees;

    void showAssignBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AssignToBottomSheet(
          organizationId: "",
          workspaceId: "",
          customerId: "",
          defaultAssignees: customerDetail.assignees ?? [],
          onSelected: (assignData) {
            // Callback này không còn được sử dụng vì đã xử lý trực tiếp trong bottomsheet
          },
        ),
      );
    }

    // Trường hợp có nhiều người phụ trách
    final hasAssignToUsers = assignToUsers != null && assignToUsers.isNotEmpty;

    if (hasAssignToUsers) {
      final displayUsers =
          assignToUsers.take(3).toList(); // Chỉ hiển thị 3 trong AppBar
      final stackWidth = 16.0 +
          (displayUsers.length > 1 ? (displayUsers.length - 1) * 10.0 : 0);

      return GestureDetector(
        onTap: showAssignBottomSheet,
        child: Row(
          children: [
            Text(
              '${"assignee_label".tr()}: ',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            SizedBox(
              width: stackWidth,
              height: 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: displayUsers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  return Positioned(
                    left: index * 10.0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: AppAvatar(
                          size: 14,
                          shape: AvatarShape.circle,
                          imageUrl: user.avatar,
                          fallbackText: user.profileName,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 4),
            if (assignToUsers.length > 3)
              Text(
                '+${assignToUsers.length - 3}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
          ],
        ),
      );
    }

    // Trường hợp có một người phụ trách duy nhất hoặc team
    String assigneeName = '';
    String? avatarUrl;
    bool isTeam = false;

    if (assignToUser != null) {
      //   assigneeName = assignToUser['fullName'] ?? '';
      //   avatarUrl = assignToUser['avatar'];
      // } else if (teamResponse != null && teamResponse['name'] != null) {
      //   assigneeName = teamResponse['name'];
      //   isTeam = true;
    }

    if (assigneeName.isEmpty) {
      return GestureDetector(
        // onTap: showAssignBottomSheet,
        child: Text(
          'Phụ trách: Chưa phân công',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: showAssignBottomSheet,
      child: Row(
        children: [
          Text(
            'Phụ trách: ',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          if (isTeam)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5C33F0).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.group,
                size: 8,
                color: Color(0xFF5C33F0),
              ),
            )
          else
            AppAvatar(
              size: 12,
              shape: AvatarShape.circle,
              imageUrl: avatarUrl,
              fallbackText: assigneeName,
            ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              assigneeName,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoTab(CustomerServiceState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cơ bản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2329),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard([
            _buildInfoRow(
                'Họ và tên', state.customerService?.fullName ?? 'N/A'),
            _buildInfoRow('Tiêu đề', state.customerService?.title ?? 'N/A'),
            _buildInfoRow('ID', state.customerService?.id ?? 'N/A'),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Thông tin bổ sung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2329),
            ),
          ),
          const CustomerJourney(onlyNote: true),
        ],
      ),
    );
  }

  Widget _buildActivityTab(CustomerServiceState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: Color(0xFF667085),
          ),
          const SizedBox(height: 16),
          Text(
            "no_activity".tr(),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "no_activity_message".tr(),
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF667085),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF667085),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2329),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final customerDetailAsync = ref.watch(customerDetailProvider(widget.customerId));

    return BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
        bloc: context.read<CustomerServiceBloc>(),
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: state.status == CustomerServiceStatus.loadingUserInfo
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Row(children: [
                        Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Container(
                                  width: 120, height: 16, color: Colors.white),
                              const SizedBox(height: 4),
                              Container(
                                  width: 80, height: 14, color: Colors.white)
                            ])),
                      ]),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerDetailScreen(),
                          ),
                        );
                        // context.push(
                        //   '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers/${widget.customerId}/basic-info',
                        //   extra: customerDetail,
                        // );
                      },
                      child: Row(
                        children: [
                          AppAvatar(
                            // imageUrl: state.customerService?.avatar,
                            fallbackText: state.customerService?.fullName ?? '',
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state.customerService?.fullName ?? '',
                                    style: const TextStyle(
                                        color: Color(0xFF1F2329),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                _buildCompactAssigneeInfo(
                                    state.customerService!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1F2329),
                unselectedLabelColor: const Color(0xFF667085),
                indicatorColor: const Color(0xFF5C33F0),
                onTap: (value) {
                  if (value == 0) {
                    context.read<CustomerServiceBloc>().add(LoadJourneyPaging(
                          organizationId: context
                                  .read<OrganizationBloc>()
                                  .state
                                  .organizationId ??
                              '',
                        ));
                  } else if (value == 1) {
                    context.read<CustomerServiceBloc>().add(LoadJourneyPaging(
                          organizationId: context
                                  .read<OrganizationBloc>()
                                  .state
                                  .organizationId ??
                              '',
                          type: 'create_note',
                        ));
                  }
                },
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(text: "activity_label".tr()),
                  Tab(text: "note_label".tr()),
                  // Tab(text: 'Hoạt động'),
                ],
              ),
              // actions: [
              //   MenuAnchor(
              //     style: MenuStyle(
              //       backgroundColor: const WidgetStatePropertyAll(Colors.white),
              //       elevation: const WidgetStatePropertyAll(4),
              //       shadowColor: WidgetStatePropertyAll(
              //           Colors.black.withValues(alpha: 0.08)),
              //       shape: WidgetStatePropertyAll(
              //         RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //           side: const BorderSide(
              //             color: Color(0xFFE4E7EC),
              //             width: 1,
              //           ),
              //         ),
              //       ),
              //       padding: const WidgetStatePropertyAll(
              //           EdgeInsets.symmetric(vertical: 8)),
              //     ),
              //     builder: (context, controller, child) {
              //       return IconButton(
              //         icon: const Icon(Icons.more_vert),
              //         onPressed: () {
              //           if (controller.isOpen) {
              //             controller.close();
              //           } else {
              //             controller.open();
              //           }
              //         },
              //       );
              //     },
              //     menuChildren: [
              //       MenuItemButton(
              //         style: const ButtonStyle(
              //           padding: WidgetStatePropertyAll(
              //               EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              //           minimumSize: WidgetStatePropertyAll(Size.zero),
              //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //         ),
              //         leadingIcon: const Icon(
              //           Icons.swap_horiz,
              //           size: 20,
              //           color: Color(0xFF667085),
              //         ),
              //         onPressed: () {
              //           showModalBottomSheet(
              //             context: context,
              //             isScrollControlled: true,
              //             backgroundColor: Colors.transparent,
              //             builder: (context) => AssignToBottomSheet(
              //               organizationId: context
              //                       .read<OrganizationBloc>()
              //                       .state
              //                       .organizationId ??
              //                   '',
              //               workspaceId: '',
              //               customerId: state.customerService?.id ?? '',
              //               defaultAssignees:
              //                   state.customerService?.assignees != null
              //                       ? List<Assignees>.from(
              //                           state.customerService?.assignees ?? [])
              //                       : [],
              //               onSelected: (assignData) {
              //                 // Callback này không còn được sử dụng vì đã xử lý trực tiếp trong bottomsheet
              //               },
              //             ),
              //           );
              //         },
              //         child: const Text(
              //           'Chuyển phụ trách',
              //           style: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400,
              //             color: Color(0xFF101828),
              //           ),
              //         ),
              //       ),
              //       MenuItemButton(
              //         style: const ButtonStyle(
              //           padding: WidgetStatePropertyAll(
              //               EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              //           minimumSize: WidgetStatePropertyAll(Size.zero),
              //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //         ),
              //         leadingIcon: const Icon(
              //           Icons.edit_outlined,
              //           size: 20,
              //           color: Color(0xFF667085),
              //         ),
              //         onPressed: () {
              //           // context.push(
              //           //   '/organization/${state.organizationId}/workspace/${state.workspaceId}/customers/${state.customerService?.id}/edit',
              //           //   extra: customerDetail,
              //           // );
              //         },
              //         child: const Text(
              //           'Chỉnh sửa khách hàng',
              //           style: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400,
              //             color: Color(0xFF101828),
              //           ),
              //         ),
              //       ),
              //       MenuItemButton(
              //         style: const ButtonStyle(
              //           padding: WidgetStatePropertyAll(
              //               EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              //           minimumSize: WidgetStatePropertyAll(Size.zero),
              //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //         ),
              //         leadingIcon: const Icon(
              //           Icons.delete_outline,
              //           size: 20,
              //           color: Colors.red,
              //         ),
              //         onPressed: () {
              //           showDialog(
              //             context: context,
              //             builder: (context) => AlertDialog(
              //               title: const Text('Xóa khách hàng?'),
              //               content:
              //                   const Text('Hành động này không thể hoàn tác.'),
              //               actions: [
              //                 TextButton(
              //                     onPressed: () => context.pop(),
              //                     child: const Text('Hủy')),
              //                 TextButton(
              //                   onPressed: () async {
              //                     try {
              //                       // await ref.read(customerDetailProvider(widget.customerId).notifier).deleteCustomer(widget.organizationId, widget.workspaceId);
              //                       // ref.read(customerListProvider.notifier).removeCustomer(widget.customerId);

              //                       // // Trigger refresh cho customers list
              //                       // ref.read(customerListRefreshProvider.notifier).notifyCustomerListChanged();

              //                       if (!context.mounted) return;
              //                       context.pop();
              //                       context.pop();
              //                       ScaffoldMessenger.of(context).showSnackBar(
              //                           const SnackBar(
              //                               content:
              //                                   Text('Đã xóa khách hàng')));
              //                     } catch (e) {
              //                       if (!context.mounted) return;
              //                       ScaffoldMessenger.of(context).showSnackBar(
              //                           SnackBar(content: Text(e.toString())));
              //                     }
              //                   },
              //                   child: const Text('Xóa',
              //                       style: TextStyle(color: Colors.red)),
              //                 ),
              //               ],
              //             ),
              //           );
              //         },
              //         child: const Text(
              //           'Xóa khách hàng',
              //           style: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400,
              //             color: Colors.red,
              //           ),
              //         ),
              //       ),
              //     ],
              //   )
              // ],
            ),
            body: state.status == CustomerServiceStatus.loading
                ? _buildLoadingSkeleton()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Hành trình
                      CustomerJourney(),

                      // Tab 2: Thông tin
                      CustomerJourney(onlyNote: true),

                      // Tab 3: Hoạt động
                      // _buildActivityTab(state),
                    ],
                  ),
          );
        });
  }
}
