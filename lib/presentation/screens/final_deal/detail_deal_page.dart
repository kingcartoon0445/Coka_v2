import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_action.dart';
import 'package:source_base/presentation/blocs/deal_activity/model/customer_detail_model.dart';

import 'package:source_base/presentation/blocs/deal_activity/model/order_detail_responese.dart';
import 'package:source_base/presentation/blocs/final_deal/final_deal_action.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_task_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_tag_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/product_selection_bottom_sheet.dart';

/// ---------------------------------------------
/// DetailDealPage (refactored for rebuild hygiene)
/// ---------------------------------------------
///
/// - BlocSelector slices to minimize rebuilds
/// - Extracted small widgets for independent rebuild
/// - Navigation in UI only; no imperative state mutation
/// - Fixed gender mapping + DOB update bug
/// - Safer color parsing + const everywhere possible
/// - Edit rows use internal state without mutating bloc models directly
///
class DetailDealPage extends StatelessWidget {
  const DetailDealPage({Key? key}) : super(key: key);

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: BlocSelector<DealActivityBloc, DealActivityState, String>(
          selector: (s) => s.task?.name ?? '',
          builder: (_, title) => Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: const [
          _HeaderSection(),
          _OrderSection(),
          _CustomerSection(),
        ],
      ),
    );
  }
}

// --------------------------- Sections ----------------------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocSelector<DealActivityBloc, DealActivityState, TaskModel?>(
          selector: (s) => s.task,
          builder: (context, cs) {
            final created = cs?.createdDate ?? DateTime.now();
            return Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'created_date'.tr(),
                  value: DetailDealPage._dateFmt.format(created),
                ),
                _TagsRow(tags: cs?.tags ?? const []),
                _AssigneesRow(assignees: cs?.assignedTo ?? const []),
                const _Line12(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection();
  void _showProductSelectionBottomSheet(
      BuildContext context, List<CustomerOrderDetailModel> orderDetails) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BlocSelector<FinalDealBloc, FinalDealState, List<ProductModel>?>(
              selector: (s) => s.products,
              builder: (context, products) {
                final selectedProducts = orderDetails
                    .map((e) => SelectedProduct(
                          product:
                              products!.firstWhere((p) => p.id == e.productId),
                          quantity: int.parse(e.quantity.toString()),
                        ))
                    .toList();
                return ProductSelectionBottomSheet(
                  products: products ?? [],
                  initialSelected: selectedProducts,
                );
              }),
    ).then((value) {
      if (value != null) {
        context.read<DealActivityBloc>().add(
              UpdateOrderList(
                organizationId:
                    context.read<OrganizationBloc>().state.organizationId ?? '',
                taskId: context.read<DealActivityBloc>().state.task?.id ?? '',
                products: value,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DealActivityBloc, DealActivityState,
        CustomerOrderDataModel?>(
      selector: (s) => s.customerOrderDataModel,
      builder: (context, orders) {
        final items =
            orders?.orderDetails ?? const <CustomerOrderDetailModel>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _SectionTitle('Sản phẩm'),
                IconButton(
                  onPressed: () =>
                      _showProductSelectionBottomSheet(context, items),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in items)
              _InfoRow(
                icon: Icons.shopping_bag_outlined,
                leading: Text(
                  'x${item.quantity ?? 0}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                label: item.product?.name ?? '',
                value: Helpers.formatCurrency(item.product?.price ?? 0),
              ),
            Row(
              children: [
                const _SectionTitle('Tổng cộng'),
                const SizedBox(width: 45),
                Text(
                  Helpers.formatCurrency(orders?.totalPrice ?? 0),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const _Line12(),
          ],
        );
      },
    );
  }
}

class _CustomerSection extends StatefulWidget {
  const _CustomerSection();

  @override
  State<_CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<_CustomerSection> {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<DealActivityBloc, DealActivityState, LeadDetailModel?>(
      selector: (s) => s.customerDataModel,
      builder: (context, customer) {
        final orgId = context.select<DealActivityBloc, String?>(
          (b) => b.state.organizationId,
        );

        final isCustomer = context.select<DealActivityBloc, bool?>(
          (b) =>
              b.state.customerOrderDataModel?.customerId != null &&
              b.state.customerOrderDataModel?.customerId != '',
        );
        Future<bool> dispatch(
            String field, dynamic value, bool isCustomer) async {
          final completer = Completer<bool>();
          context.read<DealActivityBloc>().add(UpdateCustomer(
                organizationId: orgId ?? '',
                id: customer?.id ?? '',
                fieldName: field,
                value: value,
                isCustomer: isCustomer,
                completer: completer,
              ));
          return completer.future.then((c) => c);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditInfoRow(
              icon: Icons.phone_outlined,
              label: 'Số điện thoại',
              value: customer?.phone ?? '',
              onUpdate: (v) {
                dispatch(
                  'phone',
                  v,
                  isCustomer ?? false,
                ).then((value) {
                  if (value) {
                    setState(() {
                      customer?.phone = v;
                    });
                  }
                });
              },
            ),
            EditInfoRow(
              icon: Icons.mail_outline,
              label: 'email'.tr(),
              value: customer?.email ?? '',
              onUpdate: (v) {
                dispatch('email', v, isCustomer ?? false).then((value) {
                  if (value) {
                    setState(() {
                      customer?.email = v;
                    });
                  }
                });
              },
            ),
            EditInfoRow(
              icon: Icons.male_outlined,
              isGender: true,
              label: 'gender',
              value: customer?.gender,
              onUpdate: (v) {
                dispatch('gender', v, isCustomer ?? false).then((value) {
                  if (value) {
                    setState(() {
                      customer?.gender = int.parse(v);
                    });
                  }
                });
              },
            ),
            EditInfoRow(
              icon: Icons.cake_outlined,
              label: 'birthday',
              isDate: true,
              value: customer?.dob != null
                  ? DateTime.parse(customer?.dob ?? '')
                  : null,
              onUpdate: (v) {
                dispatch('dob', v, isCustomer ?? false).then((value) {
                  if (value) {
                    setState(() {
                      customer?.dob = v;
                    });
                  }
                });
              },
            ),
            EditInfoRow(
              icon: Icons.work_outline,
              label: 'Nghề nghiệp',
              value: customer?.work ?? '',
              onUpdate: (v) {
                dispatch('work', v, isCustomer ?? false).then((value) {
                  if (value) {
                    setState(() {
                      customer?.work = v;
                    });
                  }
                });
              },
            ),
            EditInfoRow(
              icon: Icons.badge_outlined,
              label: 'CCCD',
              value: customer?.physicalId ?? '',
              onUpdate: (v) {
                dispatch('physicalId', v, isCustomer ?? false).then((value) {
                  if (value) {
                    setState(() {
                      customer?.physicalId = v;
                    });
                  }
                });
              },
            ),
            EditInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Địa chỉ',
              value: customer?.address ?? '',
              onUpdate: (v) {
                dispatch('address', v, isCustomer ?? false).then((value) {
                  if (value) {
                    setState(() {
                      customer?.address = v;
                    });
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}

// --------------------------- Pieces ----------------------------
class _TagsRow extends StatelessWidget {
  final List<TagModel> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      icon: Icons.label_outline,
      label: 'label'.tr(),
      customChild: Wrap(
        spacing: 6,
        children: [
          for (final label in tags)
            _InfoChip(
              text: label.name ?? '',
              color: _parseHexColor(label.backgroundColor),
            ),
        ],
      ),
    );
  }
}

class _AssigneesRow extends StatelessWidget {
  final List<AssignedTo> assignees;
  const _AssigneesRow({required this.assignees});

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      icon: Icons.person_outline_sharp,
      label: 'Phụ trách'.tr(),
      customChild: Column(
        children: [
          for (final a in assignees)
            Row(
              children: [
                AppAvatar(
                  fallbackText: a.name ?? '',
                  imageUrl: a.avatar ?? '',
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  a.name ?? '',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Line12 extends StatelessWidget {
  const _Line12();
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.grey[300],
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      );
}

class _InfoRow extends StatelessWidget {
  final Widget? leading;
  final IconData icon;
  final String label;
  final String? value;
  final Widget? customChild;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.customChild,
    this.leading,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          leading ?? Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey[800], fontSize: 14)),
          ),
          Expanded(
            child: customChild ??
                Text(
                  value ?? 'Chưa có',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textTertiary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// --------------------------- Editable Row ----------------------------
class EditInfoRow extends StatefulWidget {
  final Widget? leading;
  final IconData icon;
  final String label;
  final dynamic value; // String | DateTime?
  final Widget? customChild;
  final bool isDate;
  final bool isGender; // when true, emits '0' or '1'
  final Function(dynamic) onUpdate;

  const EditInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.customChild,
    this.leading,
    this.isDate = false,
    this.isGender = false,
    required this.onUpdate,
  });

  @override
  State<EditInfoRow> createState() => _EditInfoRowState();
}

class _EditInfoRowState extends State<EditInfoRow> {
  final TextEditingController controller = TextEditingController();
  bool showEdit = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isDate && !widget.isGender && widget.value is String) {
      controller.text = widget.value as String;
    }
  }

  @override
  void didUpdateWidget(covariant EditInfoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isDate && !widget.isGender && widget.value is String) {
      final newText = widget.value as String;
      if (newText != controller.text) controller.text = newText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => showEdit = !showEdit),
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            widget.leading ??
                Icon(widget.icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Text(widget.label,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis)),
            ),
            if (showEdit) ...[
              if (widget.isDate)
                Expanded(child: _buildDateEditor(context))
              else if (widget.isGender)
                Expanded(child: _buildGenderEditor())
              else
                Expanded(child: _buildTextEditor())
            ] else ...[
              Expanded(
                child: widget.customChild ??
                    Text(
                      _displayValue(),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
              ),
              IconButton(
                onPressed: () => setState(() => showEdit = !showEdit),
                icon: Icon(Icons.edit, size: 20, color: Colors.grey[400]),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _displayValue() {
    if (widget.isDate) {
      final dt = widget.value is DateTime ? widget.value as DateTime? : null;
      return dt != null ? DetailDealPage._dateFmt.format(dt) : 'Chưa có';
    }
    if (widget.isGender) return (widget.value == 1) ? 'Nữ' : 'Nam';
    return (widget.value?.toString().isNotEmpty ?? false)
        ? widget.value.toString()
        : 'Chưa có';
  }

  Widget _buildTextEditor() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => showEdit = false);
            widget.onUpdate(controller.text.trim());
          },
          icon: Icon(Icons.check, size: 20, color: Colors.green[700]),
        ),
        IconButton(
          onPressed: () => setState(() => showEdit = false),
          icon: Icon(Icons.close, size: 20, color: Colors.red[700]),
        ),
      ],
    );
  }

  Widget _buildGenderEditor() {
    final current = controller.text.isNotEmpty
        ? controller.text
        : (widget.value == '1' ? '1' : '0');
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: current,
            items: const [
              DropdownMenuItem(value: '0', child: Text('Nam')),
              DropdownMenuItem(value: '1', child: Text('Nữ')),
            ],
            onChanged: (v) => setState(() => controller.text = v ?? '0'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => showEdit = false);
            widget
                .onUpdate(controller.text.isEmpty ? current : controller.text);
          },
          icon: Icon(Icons.check, size: 20, color: Colors.green[700]),
        ),
        IconButton(
          onPressed: () => setState(() => showEdit = false),
          icon: Icon(Icons.close, size: 20, color: Colors.red[700]),
        ),
      ],
    );
  }

  Widget _buildDateEditor(BuildContext context) {
    final DateTime? initial =
        (widget.value is DateTime) ? widget.value as DateTime? : null;
    final String display =
        initial != null ? DetailDealPage._dateFmt.format(initial) : '';
    if (controller.text.isEmpty) controller.text = display;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: initial ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.text = picked.toString();
                setState(() {});
              }
            },
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                alignment: Alignment.center,
                child: Text(
                  DetailDealPage._dateFmt.format(
                      DateTime.parse(controller.text) ?? DateTime.now()),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => showEdit = false);
            // Keep emitting a display string (dd/MM/yyyy) to backend as in original
            // If backend expects ISO-8601, convert here instead
            widget.onUpdate(controller.text);
          },
          icon: Icon(Icons.check, size: 20, color: Colors.green[700]),
        ),
        IconButton(
          onPressed: () => setState(() => showEdit = false),
          icon: Icon(Icons.close, size: 20, color: Colors.red[700]),
        ),
      ],
    );
  }
}

// --------------------------- Utils ----------------------------
Color _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xff000000);
  final cleaned =
      hex.replaceFirst('#', '').padLeft(8, 'f'); // ensure ARGB if needed
  final value = int.tryParse('0xff$cleaned');
  return Color(value ?? 0xff000000);
}
