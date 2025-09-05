import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';
import 'package:source_base/presentation/screens/customer/dialog_user.dart';
import 'package:source_base/presentation/screens/customers_service/switch_final_deal.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/customer_detail_model.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_bloc.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_event.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_state.dart';
import '../../blocs/switch_final_deal/switch_final_deal_action.dart';

/// Refactor highlights
/// - Dùng BlocConsumer để gom builder + listener và kiểm soát rebuild qua `buildWhen`
/// - Dùng `context.select` / `BlocSelector` để lấy lát cắt (slice) state nhằm giảm rebuild không cần thiết
/// - Trích xuất widget con để chúng rebuild theo selector riêng
/// - Điều hướng/pop được thực hiện trong listener, UI chỉ phát event
/// - Loại bỏ lặp lại context.read nhiều lần/nested pop
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({Key? key}) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool editLabel = false;
  @override
  Widget build(BuildContext context) {
    // Lấy organizationId một lần, chỉ rebuild khi organizationId thay đổi
    final organizationId = context.select<OrganizationBloc, String?>(
      (b) => b.state.organizationId,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: BlocConsumer<CustomerDetailBloc, CustomerDetailState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            // Điều hướng & side-effects
            switch (state.status) {
              case CustomerDetailStatus.successLinkToLead:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã liên kết khách hàng')),
                );
                context.read<CustomerDetailBloc>().add(LoadCustomerDetail(
                      organizationId: organizationId ?? '',
                      customerId: state.customerService?.id ?? '',
                      isCustomer: false,
                    ));
                break;
              case CustomerDetailStatus.successStorageCustomer:
                // Sau khi convert/unarchive, thoát về list & reload
                context.pop();
                context.pop();
                context.read<CustomerDetailBloc>().add(LoadCustomerDetailValue(
                      organizationId: organizationId ?? '',
                    ));
                break;
              case CustomerDetailStatus.successDeleteReminder:
                context.pop(); // đóng dialog
                context.pop(); // đóng detail
                context.pop(); // đóng customer
                context.pop(); // đóng list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa khách hàng')),
                );
                break;
              default:
                break;
            }
          },
          // Chỉ rebuild UI khi các phần dữ liệu hiển thị thay đổi
          buildWhen: (prev, curr) =>
              prev.customerService != curr.customerService ||
              prev.status != curr.status,
          builder: (context, state) {
            final cs = state.customerService;
            final leadInfo = state.leadDetail;
            final customerInfo = state.customerDetailModel;
            final List<PagingModel> labels = state.paginges;
            List<PagingModel> initLabels = state.initLabels;
            if (state.status == CustomerDetailStatus.loading || cs == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Header(
                      fullName: cs.fullName ?? '',
                      imgUrl: cs.avatar ?? "",
                    ),
                    const SizedBox(height: 12),
                    _ActionBar(
                      isArchive:
                          false, // CustomerDetailBloc không có pagingRequest
                      onArchiveToggle: () {
                        // Logic archive/unarchive có thể được thêm vào CustomerDetailBloc nếu cần
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Chức năng đang được phát triển')),
                        );
                      },
                      onDeleteTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _ConfirmDeleteDialog(
                            onConfirm: () {
                              // Có thể thêm DeleteCustomer event vào CustomerDetailBloc nếu cần
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Chức năng đang được phát triển')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _ConvertButton(
                      onTap: () {
                        context
                            .read<SwitchFinalDealBloc>()
                            .add(LoadCustomer(customerService: cs));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SwitchFinalDeal()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (leadInfo == null) ...[
                      // Opportunity/Deals section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Opportunity/Deals",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          showDialog<CustomerServiceModel>(
                            context: context,
                            builder: (_) =>
                                SelectUserDialog<CustomerServiceModel>(
                              items: state.customerServices ?? [],
                              displayName: (c) => c.fullName ?? '',
                              avatarUrl: (c) => c.avatar,
                            ),
                          ).then((selectedUser) {
                            context
                                .read<CustomerDetailBloc>()
                                .add(CancelSearch());
                            if (selectedUser != null) {
                              // linking now handled elsewhere

                              context.read<CustomerDetailBloc>().add(
                                    LinkToLeadEvent(
                                        conversationId:
                                            state.customerService?.id ?? "",
                                        leadId: selectedUser.id ?? "",
                                        organizationId: organizationId ?? ""),
                                  );
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          // height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Text("Opportunity/Deals"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.arrow_drop_down_rounded, size: 24),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Create new opportunity",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ] else ...[
                      _CustomerDetailInfoSection(
                        title: cs.title ?? '',
                        createdDate: DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(leadInfo.createdDate ??
                                DateTime.now().toString())),
                        classification: leadInfo.source?.first ?? '',
                        tags:
                            (leadInfo.tags ?? []).whereType<String>().toList(),
                        assignees: leadInfo.assignees ?? const [],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (customerInfo != null) ...[
                      _CustomerInfoSection(
                        email: customerInfo.email ?? '',
                        phone: customerInfo.phone ?? '',
                        gender: customerInfo.gender == 1
                            ? 'male'.tr()
                            : 'female'.tr(),
                        birthday: customerInfo.dob ?? '',
                        job: customerInfo.work ?? '',
                        cid: customerInfo.physicalId ?? '',
                        address: customerInfo.address ?? '',
                      ),
                    ] else ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Opportunity/Deals",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          showDialog<CustomerPaging>(
                            context: context,
                            builder: (_) => SelectUserDialog<CustomerPaging>(
                              items: state.customerPaginges ?? [],
                              displayName: (c) => c.name ?? '',
                              avatarUrl: (c) => c.name,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          // height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Text("Opportunity/Deals"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.arrow_drop_down_rounded, size: 24),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Create new opportunity",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Customer info is now rendered inside _CustomerDetailInfoSection
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String fullName;
  final String imgUrl;
  const _Header({required this.fullName, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          fallbackText: fullName,
          size: 60,
          imageUrl: imgUrl,
        ),
        const SizedBox(height: 12),
        Text(fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool isArchive;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDeleteTap;
  const _ActionBar(
      {required this.isArchive,
      required this.onArchiveToggle,
      required this.onDeleteTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SquareIconButton(
          icon: Icons.phone_outlined,
          onPressed: () {},
        ),
        const SizedBox(width: 12),
        _SquareIconButton(
          icon:
              isArchive ? Icons.file_upload_outlined : Icons.system_update_alt,
          onPressed: onArchiveToggle,
        ),
        const SizedBox(width: 12),
        _SquareIconButton(
          icon: Icons.more_horiz,
          onPressed: onDeleteTap,
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _SquareIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }
}

class _ConvertButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ConvertButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handshake_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'convert_to_customer'.tr(),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? customChild;
  const _InfoRow(
      {required this.icon, required this.label, this.value, this.customChild});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey[800], fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: customChild ??
                  Text(value ?? 'Chưa có',
                      style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CustomerDetailInfoSection extends StatelessWidget {
  final String title;
  final String createdDate;
  final String classification;
  final List<String> tags;
  final List<Assignees> assignees;

  const _CustomerDetailInfoSection({
    required this.title,
    required this.createdDate,
    required this.classification,
    required this.tags,
    required this.assignees,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('detail'.tr()),
        const SizedBox(height: 8),
        _InfoRow(
            icon: Icons.featured_play_list_outlined,
            label: 'title'.tr(),
            value: title),
        _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'created_date'.tr(),
            value: createdDate),
        _InfoRow(
            icon: Icons.category_outlined,
            label: 'classification'.tr(),
            value: classification),
        _InfoRow(icon: Icons.source, label: 'source'.tr(), value: ''),
        _InfoRow(
          icon: Icons.label_outline,
          label: 'label'.tr(),
          customChild: Wrap(
            spacing: 6,
            children: [
              for (final item in tags) ...[
                _InfoChip(text: item, color: AppColors.primary),
              ]
            ],
          ),
        ),
        _InfoRow(
          icon: Icons.person_outline_outlined,
          label: 'assignee_label'.tr(),
          customChild: Wrap(
            spacing: 6,
            children: [
              for (final assignee in assignees)
                if (assignee.type == "OWNER") ...[
                  Row(
                    children: [
                      AppAvatar(
                        fallbackText: assignee.profileName ?? '',
                        imageUrl: assignee.avatar ?? '',
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        assignee.profileName ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ]
            ],
          ),
        ),

        _InfoRow(
          icon: Icons.person_outline_outlined,
          label: 'follower'.tr(),
          customChild: Wrap(
            spacing: 6,
            children: [
              for (final assignee in assignees)
                if (assignee.type == "FOLLOWER") ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Row(
                      children: [
                        AppAvatar(
                          fallbackText: assignee.profileName ?? '',
                          imageUrl: assignee.avatar ?? '',
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          assignee.profileName ?? '',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ]
            ],
          ),
        ),

        // const SizedBox(height: 16),
        // _SectionTitle('follower'.tr()),
        // const SizedBox(height: 8),
        // Column(
        //   children: [
        //     for (final assignee in assignees)
        //       if (assignee.type == "FOLLOWER") ...[
        //         Padding(
        //           padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        //           child: Row(
        //             children: [
        //               AppAvatar(
        //                 fallbackText: assignee.profileName ?? '',
        //                 imageUrl: assignee.avatar ?? '',
        //                 size: 24,
        //               ),
        //               const SizedBox(width: 8),
        //               Text(
        //                 assignee.profileName ?? '',
        //                 style: const TextStyle(
        //                     fontSize: 14, fontWeight: FontWeight.w400),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ]
        //   ],
        // ),
      ],
    );
  }
}

class _CustomerInfoSection extends StatelessWidget {
  final String email;
  final String phone;
  final String gender;
  final String birthday;
  final String job;
  final String cid;
  final String address;

  const _CustomerInfoSection({
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
    required this.job,
    required this.cid,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('customer'.tr()),
        const SizedBox(height: 8),
        _InfoRow(icon: Icons.email_outlined, label: 'email'.tr(), value: email),
        _InfoRow(icon: Icons.phone_outlined, label: 'phone'.tr(), value: phone),
        _InfoRow(
            icon: Icons.male_outlined, label: 'gender'.tr(), value: gender),
        _InfoRow(
            icon: Icons.cake_outlined, label: 'birthday'.tr(), value: birthday),
        _InfoRow(icon: Icons.work_outline, label: 'job'.tr(), value: job),
        _InfoRow(icon: Icons.badge_outlined, label: 'CID'.tr(), value: cid),
        _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'location'.tr(),
            value: address),
      ],
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _ConfirmDeleteDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xóa khách hàng?'),
      content: const Text('Hành động này không thể hoàn tác.'),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Xóa', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
