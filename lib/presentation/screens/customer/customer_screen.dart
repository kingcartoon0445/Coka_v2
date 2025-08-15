import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/switch_final_deal.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';

import '../../blocs/customer_service/customer_service_action.dart';
import '../../blocs/switch_final_deal/switch_final_deal_action.dart';

/// Refactor highlights
/// - Dùng BlocConsumer để gom builder + listener và kiểm soát rebuild qua `buildWhen`
/// - Dùng `context.select` / `BlocSelector` để lấy lát cắt (slice) state nhằm giảm rebuild không cần thiết
/// - Trích xuất widget con để chúng rebuild theo selector riêng
/// - Điều hướng/pop được thực hiện trong listener, UI chỉ phát event
/// - Loại bỏ lặp lại context.read nhiều lần/nested pop
class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({Key? key}) : super(key: key);

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
      body: SafeArea(
        child: BlocConsumer<CustomerServiceBloc, CustomerServiceState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            // Điều hướng & side-effects
            switch (state.status) {
              case CustomerServiceStatus.successStorageCustomer:
                // Sau khi convert/unarchive, thoát về list & reload
                context.pop();
                context.pop();
                context.read<CustomerServiceBloc>().add(LoadCustomerService(
                      organizationId: organizationId ?? '',
                      pagingRequest: null,
                    ));
                break;
              case CustomerServiceStatus.successDeleteReminder:
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
              prev.pagingRequest?.isArchive != curr.pagingRequest?.isArchive ||
              prev.status != curr.status,
          builder: (context, state) {
            final cs = state.customerService;

            if (state.status == CustomerServiceStatus.loading || cs == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Header(fullName: cs.fullName ?? ''),
                    const SizedBox(height: 12),

                    _ActionBar(
                      isArchive: state.pagingRequest?.isArchive ?? false,
                      onArchiveToggle: () {
                        if ((state.pagingRequest?.isArchive ?? false)) {
                          context.read<CustomerServiceBloc>().add(
                                StorageUnArchiveCustomer(
                                  customerId: cs.id ?? '',
                                  organizationId: organizationId ?? '',
                                ),
                              );
                        } else {
                          context.read<CustomerServiceBloc>().add(
                                StorageConvertToCustomer(
                                  customerId: cs.id ?? '',
                                  organizationId: organizationId ?? '',
                                ),
                              );
                        }
                      },
                      onDeleteTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _ConfirmDeleteDialog(
                            onConfirm: () =>
                                context.read<CustomerServiceBloc>().add(
                                      DeleteCustomer(
                                        customerId: cs.id ?? '',
                                        organizationId: organizationId ?? '',
                                      ),
                                    ),
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
                    _SectionTitle('detail'.tr()),
                    const SizedBox(height: 8),

                    _InfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'created_date'.tr(),
                        value: '16/05/2025'),
                    _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'classification'.tr(),
                        value: 'Nhập tay'),
                    _InfoRow(
                        icon: Icons.source,
                        label: 'source'.tr(),
                        value: 'Khách cũ'),
                    _InfoRow(
                      icon: Icons.label_outline,
                      label: 'label'.tr(),
                      customChild: Wrap(
                        spacing: 6,
                        children: const [
                          _InfoChip(text: 'V.I.P', color: Colors.blue),
                          _InfoChip(text: 'Hot', color: Colors.red),
                        ],
                      ),
                    ),

                    // Chỉ rebuild phần Assignees khi danh sách thay đổi
                    BlocSelector<CustomerServiceBloc, CustomerServiceState,
                        List<Assignees>>(
                      selector: (s) => s.customerService?.assignees ?? const [],
                      builder: (context, assignees) {
                        return _InfoRow(
                          icon: Icons.person_outline_sharp,
                          label: 'responsible'.tr(),
                          customChild: Column(
                            children: [
                              for (final assignee in assignees)
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
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle('customer'.tr()),
                    const SizedBox(height: 8),

                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'name'.tr(),
                        value: cs.fullName ?? ''),
                    const _InfoRow(icon: Icons.email_outlined, label: 'email'),
                    const _InfoRow(icon: Icons.phone_outlined, label: 'phone'),
                    _InfoRow(
                      icon: Icons.label_important_outline,
                      label: 'label'.tr(),
                      customChild: Wrap(
                        spacing: 6,
                        children: [
                          const _InfoChip(text: 'Cần bán', color: Colors.blue),
                          const _InfoChip(text: 'Cần mua', color: Colors.red),
                          const _InfoChip(text: 'Đã bán', color: Colors.green),
                          ActionChip(
                              label: const Text('+ Thêm nhãn'),
                              onPressed: () {}),
                        ],
                      ),
                    ),
                    const _InfoRow(icon: Icons.male_outlined, label: 'gender'),
                    const _InfoRow(
                        icon: Icons.cake_outlined, label: 'birthday'),
                    const _InfoRow(
                        icon: Icons.work_outline, label: 'occupation'),
                    const _InfoRow(icon: Icons.badge_outlined, label: 'ICD'),
                    const _InfoRow(
                        icon: Icons.location_on_outlined, label: 'location'),
                    const _InfoRow(icon: Icons.devices_other, label: 'device'),
                    const _InfoRow(icon: Icons.chat_outlined, label: 'Zalo'),
                    const _InfoRow(
                        icon: Icons.facebook_outlined, label: 'Facebook'),
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
  const _Header({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(fallbackText: fullName, size: 60),
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
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey[800], fontSize: 14)),
          ),
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
