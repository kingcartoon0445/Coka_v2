import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/switch_final_deal.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';

import '../../blocs/customer_service/customer_service_action.dart';
import '../../blocs/final_deal/final_deal_action.dart';
import '../../blocs/switch_final_deal/switch_final_deal_action.dart';
import '../customers_service/customer_service_detail/widgets/assign_to_bottomsheet.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerServiceBloc, CustomerServiceState>(
      listener: (context, state) {
        if (state.status == CustomerServiceStatus.successStorageCustomer) {
          context.pop();
          context.pop();
          context.read<CustomerServiceBloc>().add(LoadCustomerService(
                organizationId:
                    context.read<OrganizationBloc>().state.organizationId ?? '',
                pagingRequest: null,
              ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
              builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppAvatar(
                      // imageUrl: state.customerService?.avatar,
                      fallbackText: state.customerService?.fullName ?? '',
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.customerService?.fullName ?? '',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.phone_outlined,
                                color: AppColors.primary),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                                state.pagingRequest?.isArchive ?? false
                                    ? Icons.file_upload_outlined
                                    : Icons.system_update_alt,
                                color: AppColors.primary),
                            onPressed: () {
                              if (state.pagingRequest?.isArchive ?? false) {
                                context.read<CustomerServiceBloc>().add(
                                    StorageUnArchiveCustomer(
                                        customerId:
                                            state.customerService?.id ?? '',
                                        organizationId: context
                                                .read<OrganizationBloc>()
                                                .state
                                                .organizationId ??
                                            ''));
                              } else {
                                context.read<CustomerServiceBloc>().add(
                                    StorageConvertToCustomer(
                                        customerId:
                                            state.customerService?.id ?? '',
                                        organizationId: context
                                                .read<OrganizationBloc>()
                                                .state
                                                .organizationId ??
                                            ''));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz,
                                color: AppColors.primary),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xóa khách hàng?'),
                                  content: const Text(
                                      'Hành động này không thể hoàn tác.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => context.pop(),
                                        child: const Text('Hủy')),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          // await ref.read(customerDetailProvider(widget.customerId).notifier).deleteCustomer(widget.organizationId, widget.workspaceId);
                                          // ref.read(customerListProvider.notifier).removeCustomer(widget.customerId);

                                          // // Trigger refresh cho customers list
                                          // ref.read(customerListRefreshProvider.notifier).notifyCustomerListChanged();

                                          if (!context.mounted) return;
                                          context
                                              .read<CustomerServiceBloc>()
                                              .add(DeleteCustomer(
                                                  customerId: state
                                                          .customerService
                                                          ?.id ??
                                                      '',
                                                  organizationId: context
                                                          .read<
                                                              OrganizationBloc>()
                                                          .state
                                                          .organizationId ??
                                                      ''));
                                          context.pop();
                                          context.pop();
                                          context.pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Đã xóa khách hàng')));
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(e.toString())));
                                        }
                                      },
                                      child: const Text('Xóa',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      // width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                  
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SwitchFinalDeal()));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.handshake_outlined,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text("convert_to_customer".tr(),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('detail'.tr()),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'created_date'.tr(),
                        value: '16/05/2025'),
                    _buildInfoRow(
                        icon: Icons.category_outlined,
                        label: 'classification'.tr(),
                        value: 'Nhập tay'),
                    _buildInfoRow(
                        icon: Icons.source,
                        label: 'source'.tr(),
                        value: 'Khách cũ'),
                    _buildInfoRow(
                      icon: Icons.label_outline,
                      label: 'label'.tr(),
                      customChild: Wrap(
                        spacing: 6,
                        children: [
                          _buildChip('V.I.P', Colors.blue),
                          _buildChip('Hot', Colors.red),
                        ],
                      ),
                    ),
                    _buildInfoRow(
                      icon: Icons.person_outline_sharp,
                      label: 'responsible'.tr(),
                      customChild: Column(
                        children: [
                          for (Assignees assignee
                              in state.customerService?.assignees ?? []) ...[
                            Row(
                              children: [
                                AppAvatar(
                                  fallbackText: assignee.profileName ?? '',
                                  imageUrl: assignee.avatar ?? '',
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(assignee.profileName ?? '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('customer'.tr()),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'name'.tr(),
                        value: state.customerService?.fullName ?? ''),
                    _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'email'.tr(),
                        value: "Chưa có"),
                    _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'phone'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                      icon: Icons.label_important_outline,
                      label: 'label'.tr(),
                      customChild: Wrap(
                        spacing: 6,
                        children: [
                          _buildChip('Cần bán', Colors.blue),
                          _buildChip('Cần mua', Colors.red),
                          _buildChip('Đã bán', Colors.green),
                          ActionChip(
                              label: const Text('+ Thêm nhãn'),
                              onPressed: () {}),
                        ],
                      ),
                    ),
                    _buildInfoRow(
                        icon: Icons.male_outlined,
                        label: 'gender'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.cake_outlined,
                        label: 'birthday'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.work_outline,
                        label: 'occupation'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'ICD'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'location'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.devices_other,
                        label: 'device'.tr(),
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.chat_outlined,
                        label: 'Zalo',
                        value: 'Chưa có'),
                    _buildInfoRow(
                        icon: Icons.facebook_outlined,
                        label: 'Facebook',
                        value: 'Chưa có'),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon,
      required String label,
      String? value,
      Widget? customChild}) {
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
                Text(value ?? '', style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Chip(
      label:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
