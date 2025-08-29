import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/routes.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/presentation/blocs/chat/chat_aciton.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_action.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/context_menu.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

class CustomerListItem extends StatelessWidget {
  final CustomerServiceModel customer;
  final String organizationId;
  final bool isArchive;
  const CustomerListItem({
    super.key,
    required this.customer,
    required this.organizationId,
    this.isArchive = false,
  });

  Widget _buildAssigneeInfo() {
    // final assignToUser = customer.assignees;
    final assignToUsers = customer.assignees;
    // final teamResponse = customer['teamResponse'];

    // Trường hợp có nhiều người phụ trách
    final hasAssignToUsers = assignToUsers != null && assignToUsers.isNotEmpty;

    if (hasAssignToUsers) {
      final displayUsers = assignToUsers.take(3).toList();
      final stackWidth = 20.0 +
          (displayUsers.length > 1 ? (displayUsers.length - 1) * 12.0 : 0);

      return Row(
        children: [
          // Hiển thị avatar chồng lên nhau (tối đa 3 avatar)
          SizedBox(
            width: stackWidth,
            height: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: displayUsers.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                return Positioned(
                  left: index * 10.0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: AppAvatar(
                        size: 17,
                        shape: AvatarShape.circle,
                        imageUrl: user.avatar,
                        fallbackText: user.avatar,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          if (assignToUsers.length > 3)
            Text(
              '+${assignToUsers.length - 3}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF828489),
              ),
            ),
        ],
      );
    }

    // Trường hợp có một người phụ trách duy nhất
    // if (assignToUser != null) {
    //   return Row(
    //     children: [
    //       AppAvatar(
    //         size: 16,
    //         shape: AvatarShape.circle,
    //         imageUrl: assignToUser['avatar'],
    //         fallbackText: assignToUser['fullName'],
    //       ),
    //       const SizedBox(width: 4),
    //       Flexible(
    //         child: Text(
    //           assignToUser['fullName'] ?? '',
    //           style: const TextStyle(
    //             fontSize: 10,
    //             color: Color(0xFF828489),
    //           ),
    //           overflow: TextOverflow.ellipsis,
    //         ),
    //       ),
    //     ],
    //   );
    // }

    // Trường hợp có team phụ trách
    // if (teamResponse != null && teamResponse['name'] != null) {
    //   return Row(
    //     children: [
    //       Container(
    //         width: 16,
    //         height: 16,
    //         decoration: BoxDecoration(
    //           shape: BoxShape.circle,
    //           color: AppColors.primary.withValues(alpha: 0.1),
    //         ),
    //         child: Icon(
    //           Icons.group,
    //           size: 10,
    //           color: AppColors.primary,
    //         ),
    //       ),
    //       const SizedBox(width: 4),
    //       Flexible(
    //         child: Text(
    //           teamResponse['name'],
    //           style: const TextStyle(
    //             fontSize: 10,
    //             color: Color(0xFF828489),
    //           ),
    //           overflow: TextOverflow.ellipsis,
    //         ),
    //       ),
    //     ],
    //   );
    // }

    // Trường hợp chưa phân công
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'unassigned'.tr(),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF828489),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context, Widget ref, RenderBox itemBox) {
    final items = [
      ContextMenuItem(
        icon: Icons.swap_horiz,
        title: 'Chuyển phụ trách',
        onTap: () {
          // Future.delayed(
          //   const Duration(milliseconds: 100),
          //   () => showModalBottomSheet(
          //     context: context,
          //     isScrollControlled: true,
          //     shape: const RoundedRectangleBorder(
          //       borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          //     ),
          //     builder: (context) => AssignToBottomSheet(
          //       organizationId: organizationId,
          //       workspaceId: workspaceId,
          //       customerId: customer['id'],
          //       defaultAssignees: customer['assignToUsers'] != null
          //           ? List<Map<String, dynamic>>.from(customer['assignToUsers'])
          //           : [],
          //       onSelected: (selectedUser) {
          //         // Callback được xử lý trong bottomsheet
          //       },
          //     ),
          //   ),
          // );
        },
      ),
      ContextMenuItem(
        icon: Icons.edit_outlined,
        title: 'Chỉnh sửa khách hàng',
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => context.push(
              '/organization/$organizationId/customers/${customer.id}/edit',
              // '/organization/$organizationId/workspace/$workspaceId/customers/${customer.id}/edit',
              extra: customer,
            ),
          );
        },
      ),
      ContextMenuItem(
        icon: Icons.delete_outline,
        title: 'Xóa khách hàng',
        iconColor: Colors.red,
        textColor: Colors.red,
        onTap: () {
          // context
          //     .read<CustomerServiceBloc>()
          //     .add(DeleteCustomer(customerId: customer.id!));
          context.pop();
          context.pop();
          // Future.delayed(
          //   const Duration(milliseconds: 100),
          //   () => showDialog(
          //     context: context,
          //     builder: (context) => CustomAlertDialog(
          //       title: 'Xóa khách hàng?',
          //       subtitle: 'Bạn có chắc muốn xóa khách hàng "${customer['fullName']}"? Hành động này không thể hoàn tác.',
          //       onSubmit: () async {
          //         Navigator.pop(context);
          //         try {
          //           await ref
          //               .read(customerDetailProvider(customer['id']).notifier)
          //               .deleteCustomer(organizationId, workspaceId);

          //           // Trigger refresh cho customers list
          //           ref.read(customerListRefreshProvider.notifier).notifyCustomerListChanged();

          //           if (context.mounted) {
          //             ScaffoldMessenger.of(context).showSnackBar(
          //               SnackBar(content: Text('Đã xóa khách hàng "${customer['fullName']}" thành công')),
          //             );
          //           }
          //         } catch (e) {
          //           if (context.mounted) {
          //             ScaffoldMessenger.of(context).showSnackBar(
          //               SnackBar(content: Text('Có lỗi xảy ra: $e')),
          //             );
          //           }
          //         }
          //       },
          //       onCancel: () => Navigator.pop(context),
          //     ),
          //   ),
          // );
        },
      ),
    ];

    ContextMenu.show(
      context: context,
      itemBox: itemBox,
      items: items,
    );
  }

  void _handleTap(
    BuildContext context,
  ) {
    // if (!isRead) {
    //   context.read<CustomerServiceBloc>().add(
    //       ChangeStatusRead(organizationId: organizationId, conversationId: id));
    // }
    // context.read<ChatBloc>().add(LoadFacebookChat(facebookChat: facebookChat));
    context.read<CustomerServiceBloc>().add(LoadFacebookChat(
          conversationId: customer.id ?? '',
          facebookChat: null,
        ));
    context.read<ChatBloc>().add(ToolListenFirebase(
          organizationId: organizationId ?? '',
          conversationId: customer.id ?? '',
        ));
    context.push(AppPaths.chatDetail(customer.id ?? '')).then((v) {
      context.read<CustomerServiceBloc>().add(LoadFacebookChat(
            conversationId: customer.id ?? '',
            facebookChat: null,
          ));
      // ignore: use_build_context_synchronously
      context.read<ChatBloc>().add(DisableFirebaseListener());
    });
    // Kiểm tra conversation trong state tương ứng và cập nhật selected conversation
    // if (platform == 'FACEBOOK') {
    //   if (ref
    //       .read(facebookMessageProvider)
    //       .conversations
    //       .any((c) => c.id == id)) {
    //     if (!isRead) {
    //       ref
    //           .read(facebookMessageProvider.notifier)
    //           .updateStatusRead(organizationId, id);
    //       ref
    //           .read(allMessageProvider.notifier)
    //           .updateStatusRead(organizationId, id);
    //     }
    //     ref.read(facebookMessageProvider.notifier).selectConversation(id);
    //     ref.read(allMessageProvider.notifier).selectConversation(id);
    //   } else if (ref
    //       .read(allMessageProvider)
    //       .conversations
    //       .any((c) => c.id == id)) {
    //     if (!isRead) {
    //       ref
    //           .read(allMessageProvider.notifier)
    //           .updateStatusRead(organizationId, id);
    //     }
    //     ref.read(allMessageProvider.notifier).selectConversation(id);
    //   }
    // }
    // if (platform == 'ZALO') {
    //   if (ref.read(zaloMessageProvider).conversations.any((c) => c.id == id)) {
    //     if (!isRead) {
    //       ref
    //           .read(zaloMessageProvider.notifier)
    //           .updateStatusRead(organizationId, id);
    //     }
    //     ref.read(zaloMessageProvider.notifier).selectConversation(id);
    //   } else {
    //     if (ref.read(allMessageProvider).conversations.any((c) => c.id == id)) {
    //       if (!isRead) {
    //         ref
    //             .read(allMessageProvider.notifier)
    //             .updateStatusRead(organizationId, id);
    //       }
    //       ref.read(allMessageProvider.notifier).selectConversation(id);
    //     }
    //     // Nếu không tìm thấy conversation trong state, có thể là do chưa tải dữ liệu
    //     // Bạn có thể thêm logic để tải dữ liệu nếu cần thiết
    //     print('Conversation with id $id not found in allMessageProvider');
    //   }
    // }

    // Điều hướng đến trang chi tiết
    // context.push('/organization/$organizationId/messages/detail/$id');
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    // final stage = customer.status;
    final createdDate = customer.createdDate!;
    final timeAgo = timeago.format(
      createdDate,
      locale: context.locale.languageCode,
    );
    // final isNewStage = stage?['name'] == 'Mới';

    return Builder(
      builder: (BuildContext context) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                if (customer.channel == 'FACEBOOK' ||
                    customer.channel == 'ZALO') {
                  _handleTap(context);
                  return;
                }
                context.read<CustomerServiceBloc>().add(LoadJourneyPaging(
                      organizationId: organizationId,
                      customerService: customer,
                    ));
                context.push(
                  AppPaths.customerService,
                );
                //đây
              },
              onLongPress: () {
                // Debug message
                print('Long press detected on customer: ${customer.fullName}');

                // Thêm haptic feedback
                HapticFeedback.mediumImpact();

                // Lấy RenderBox của item hiện tại
                final RenderBox itemBox =
                    context.findRenderObject() as RenderBox;
                // _showContextMenu(context, ref, itemBox);
              },
              splashColor: AppColors.primary.withValues(alpha: 0.1),
              highlightColor: AppColors.primary.withValues(alpha: 0.05),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: AppAvatar(
                            size: 48,
                            shape: AvatarShape.circle,
                            // imageUrl: customer.ava,
                            fallbackText: customer.fullName,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      customer.fullName ?? 'Không có tên',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeAgo,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF828489),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 10,
                                    color: Color(0xFF828489),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      customer.snippet ?? '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF828489),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAssigneeInfo(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      // shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color.fromARGB(
                                              255, 181, 180, 180)
                                          .withValues(alpha: 0.2),
                                    ),
                                    child: Text(
                                      customer.channel ?? '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.withValues(alpha: 0.6),
            )
          ],
        );
      },
    );
  }
}
