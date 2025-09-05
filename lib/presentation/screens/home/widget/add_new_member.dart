import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/data/models/paging_response.dart';
import 'package:source_base/data/models/utm_member_response.dart';
import 'package:source_base/presentation/blocs/filter_item/filter_item_aciton.dart';
import 'package:source_base/presentation/blocs/filter_item/model/create_model.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';
import 'package:source_base/presentation/screens/home/widget/filter_modal.dart';
import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

/// GỌI DIALOG
Future<bool> showOpportunityCreateDialog(BuildContext context) async {
  return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const _OpportunityCreateDialog(),
      ) ??
      false;
}

class _OpportunityCreateDialog extends StatefulWidget {
  const _OpportunityCreateDialog({super.key});

  @override
  State<_OpportunityCreateDialog> createState() =>
      _OpportunityCreateDialogState();
}

class _OpportunityCreateDialogState extends State<_OpportunityCreateDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtl = TextEditingController(text: "");
  final _phoneCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _titleCtl = TextEditingController();
  final _ownerCtl = TextEditingController();

  CustomerPaging? _customerPaging;
  MemberModel? _memberModel;
  List<PagingModel>? _label;
  Category? _category;
  UtmSourceModel? _utmSource;
  String? _customerType; // Loại khách hàng

  String? error;

  static InputDecoration _inputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText ?? 'all'.tr(),
      suffixIcon: const Icon(Icons.keyboard_arrow_down,
          color: AppColors.text, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _emailCtl.dispose();
    _titleCtl.dispose();
    _ownerCtl.dispose();
    super.dispose();
  }

  initState() {
    super.initState();
    context.read<FilterItemBloc>().add(LoadFilterItem(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? "",
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<FilterItemBloc, FilterItemState>(
        builder: (context, state) {
      final List<CustomerPaging> customerPaginges = state.customerPaging;
      final List<MemberModel> memberModels = state.members;
      final List<PagingModel> labels = state.paginges;
      final List<UtmSourceModel> utmSources = state.utmSources;
      // final List<String> labels = state. ;
      return Dialog(
        backgroundColor: const Color(0xFFF9FAFB),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: BlocListener<FilterItemBloc, FilterItemState>(
          listener: (context, state) {
            if (state.status == FilterItemStatus.createSuccess) {
              Navigator.of(context).pop(true);
            }
            if (state.status == FilterItemStatus.error) {
              setState(() {
                error = state.error;
              });
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tạo mới cơ hội',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Đóng',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildPagingModelSection(
                            keyboardType: TextInputType.text,
                            readOnly: false,
                            onTap: () {},
                            title: 'Tên khách hàng',
                            controller: _nameCtl,
                            hint: 'Nhập tên khách hàng',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bắt buộc'
                                : null,
                          ),
                          _buildLabel('Tổ chức'),
                          const SizedBox(height: 8),
                          ChipsInput<CustomerPaging>(
                            key: const ValueKey("Chọn tổ chức"),
                            initialValue: _customerPaging == null
                                ? []
                                : [_customerPaging!],
                            allowInputText: false,
                            suggestions: customerPaginges,
                            decoration: _inputDecoration("Chọn tổ chức"),
                            isOnlyOne: true,
                            onChanged: (data) {
                              if (data.isNotEmpty) {
                                setState(() {
                                  _customerPaging = data.last;
                                });
                              }
                            },
                            chipBuilder: BuildChip,
                            suggestionBuilder: (context, sta, source) =>
                                BuildSuggestion(context, sta, source, false),
                          ),
                          const SizedBox(height: 12),
                          _buildPagingModelSection(
                            keyboardType: TextInputType.phone,
                            readOnly: false,
                            onTap: () {},
                            title: 'Số điện thoại',
                            controller: _phoneCtl,
                            hint: 'Nhập số điện thoại',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bắt buộc'
                                : null,
                          ),
                          _buildPagingModelSection(
                            keyboardType: TextInputType.phone,
                            readOnly: false,
                            onTap: () {},
                            title: 'Email',
                            controller: _emailCtl,
                            hint: 'Nhập email',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bắt buộc'
                                : null,
                          ),

                          _buildPagingModelSection(
                            keyboardType: TextInputType.phone,
                            readOnly: false,
                            onTap: () {},
                            title: 'Tiêu đề',
                            controller: _titleCtl,
                            hint: 'Nhập tiêu đề',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bắt buộc'
                                : null,
                          ),
                          _buildLabel('Người phụ trách'),
                          const SizedBox(height: 8),
                          ChipsInput<MemberModel>(
                            key: const ValueKey("Người phụ trách"),
                            initialValue:
                                _memberModel == null ? [] : [_memberModel!],
                            allowInputText: false,
                            suggestions: memberModels,
                            decoration:
                                _inputDecoration("Chọn người phụ trách"),
                            isOnlyOne: true,
                            onChanged: (data) {
                              if (data.isNotEmpty) {
                                setState(() {
                                  _memberModel = data.last;
                                });
                              }
                            },
                            chipBuilder: BuildChip,
                            suggestionBuilder: (context, sta, source) =>
                                BuildSuggestion(context, sta, source, false),
                          ),
                          const SizedBox(height: 12),
                          _buildLabel('Chọn nhãn'),
                          const SizedBox(height: 8),
                          ChipsInput<PagingModel>(
                            key: const ValueKey("Chọn nhãn"),
                            initialValue: _label == null ? [] : _label!,
                            allowInputText: false,
                            suggestions: labels,
                            decoration: _inputDecoration("Chọn nhãn"),
                            isOnlyOne: false,
                            onChanged: (data) {
                              if (data.isNotEmpty) {
                                setState(() {
                                  _label = data;
                                });
                              }
                            },
                            chipBuilder: BuildChip,
                            suggestionBuilder: (context, sta, source) =>
                                BuildSuggestion(context, sta, source, false),
                          ),
                          const SizedBox(height: 12),
                          _buildLabel('Loại khách hàng'),
                          const SizedBox(height: 8),
                          ChipsInput<Category>(
                            key: const ValueKey("Loại khách hàng"),
                            initialValue: _category == null ? [] : [_category!],
                            allowInputText: false,
                            suggestions: categories,
                            decoration:
                                _inputDecoration("Chọn loại khách hàng"),
                            isOnlyOne: true,
                            onChanged: (data) {
                              if (data.isNotEmpty) {
                                setState(() {
                                  _category = data.last;
                                });
                              }
                            },
                            chipBuilder: BuildChip,
                            suggestionBuilder: (context, sta, source) =>
                                BuildSuggestion(context, sta, source, false),
                          ),
                          const SizedBox(height: 12),
                          _buildLabel('Nguồn khách hàng'),
                          const SizedBox(height: 8),
                          ChipsInput<UtmSourceModel>(
                            key: const ValueKey("Nguồn khách hàng"),
                            initialValue:
                                _utmSource == null ? [] : [_utmSource!],
                            allowInputText: false,
                            suggestions: utmSources,
                            decoration:
                                _inputDecoration("Chọn nguồn khách hàng"),
                            isOnlyOne: true,
                            onChanged: (data) {
                              if (data.isNotEmpty) {
                                setState(() {
                                  _utmSource = data.last;
                                });
                              }
                            },
                            chipBuilder: BuildChip,
                            suggestionBuilder: (context, sta, source) =>
                                BuildSuggestion(context, sta, source, false),
                          ),
                          const SizedBox(height: 12),

                          // // Phone row (type + number)
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       flex: 7,
                          //       child: _dropdown<String>(
                          //         label: 'Số điện thoại',
                          //         value: _phoneType,
                          //         items: const ['Liên hệ chính', 'Khác'],
                          //         onChanged: (v) =>
                          //             setState(() => _phoneType = v ?? _phoneType),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     Expanded(
                          //       flex: 13,
                          //       child: _textField(
                          //         label: '',
                          //         controller: _phoneCtl,
                          //         hint: 'Điền số điện thoại',
                          //         keyboardType: TextInputType.phone,
                          //         validator: (v) {
                          //           if (v == null || v.isEmpty)
                          //             return null; // optional
                          //           final ok =
                          //               RegExp(r'^[0-9+]{8,15}\$').hasMatch(v);
                          //           return ok ? null : 'Số không hợp lệ';
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // // Email row (type + email)
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       flex: 7,
                          //       child: _dropdown<String>(
                          //         label: 'Email',
                          //         value: _emailType,
                          //         items: const ['Email chính', 'Khác'],
                          //         onChanged: (v) =>
                          //             setState(() => _emailType = v ?? _emailType),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     Expanded(
                          //       flex: 13,
                          //       child: _textField(
                          //         label: '',
                          //         controller: _emailCtl,
                          //         hint: 'Điền email',
                          //         keyboardType: TextInputType.emailAddress,
                          //         validator: (v) {
                          //           if (v == null || v.isEmpty)
                          //             return null; // optional
                          //           final ok =
                          //               RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\$')
                          //                   .hasMatch(v);
                          //           return ok ? null : 'Email không hợp lệ';
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // _textField(
                          //   label: 'Title',
                          //   controller: _titleCtl,
                          //   hint: 'Điền giao dịch của khách hàng',
                          // ),

                          // // 2 columns area: Người phụ trách / Chọn nhãn
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: _textField(
                          //         label: 'Người phụ trách',
                          //         controller: _ownerCtl,
                          //         hint: 'Chọn thành viên...',
                          //         readOnly: true,
                          //         onTap: () {}, // TODO: mở picker thành viên
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     Expanded(
                          //       child: _dropdown<String>(
                          //         label: 'Chọn nhãn',
                          //         value: _label,
                          //         items: const [
                          //           'Cần bán',
                          //           'Cần mua',
                          //           'Đã bán',
                          //           'Khách cũ'
                          //         ],
                          //         onChanged: (v) => setState(() => _label = v),
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: _dropdown<String>(
                          //         label: 'Loại khách hàng',
                          //         value: _customerType,
                          //         items: const ['Nhập vào', 'Tiềm năng', 'VIP'],
                          //         onChanged: (v) =>
                          //             setState(() => _customerType = v),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 12),
                          //     Expanded(
                          //       child: _dropdown<String>(
                          //         label: 'Nguồn khách hàng',
                          //         value: _leadSource,
                          //         items: const [
                          //           'Chọn nguồn',
                          //           'Facebook',
                          //           'Zalo',
                          //           'Giới thiệu',
                          //           'Khác'
                          //         ],
                          //         onChanged: (v) => setState(() =>
                          //             _leadSource = v == 'Chọn nguồn' ? null : v),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),
                // FOOTER
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    children: [
                      if (error != null)
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            error!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text(
                              'Hủy',
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _onSubmit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Tạo mới'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  void _onSubmit() {
    setState(() {
      error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    if (_customerPaging == null) {
      setState(() {
        error = 'Vui lòng chọn tổ chức';
      });
      return;
    }
    if (_memberModel == null) {
      setState(() {
        error = 'Vui lòng chọn người phụ trách';
      });
      return;
    }
    if (_label == null) {
      setState(() {
        error = 'Vui lòng chọn nhãn';
      });
      return;
    }
    if (_category == null) {
      setState(() {
        error = 'Vui lòng chọn loại khách hàng';
      });
      return;
    }
    if (_utmSource == null) {
      setState(() {
        error = 'Vui lòng chọn nguồn khách hàng';
      });
      return;
    }

    // Ví dụ dữ liệu gom lại:
    final payload = CreateLeadModel(
      fullName: _nameCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      email: _emailCtl.text.trim(),
      title: _titleCtl.text.trim(),
      sourceId: _utmSource?.id,
      utmSource: _utmSource?.name,
      isBusiness: _customerType == 'Nhập vào' ? false : true,
      tags: _label?.map((e) => e.name).toList(),
      assignees: _memberModel?.id == null ? [] : [_memberModel!.id],
      companyId: _customerPaging?.id,
    );
    context.read<FilterItemBloc>().add(CreateLead(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? "",
          data: payload,
        ));
  }
}

// ---------------- UI HELPERS ----------------

Widget _buildPagingModelSection({
  required String title,
  required TextEditingController controller,
  required String hint,
  required TextInputType keyboardType,
  required bool readOnly,
  required void Function() onTap,
  String? Function(String?)? validator,
}) {
  return StatefulBuilder(
    builder: (context, setState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.transparent,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD0D5DD),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _dropdown<T>({
  required String label,
  required T? value,
  required List<T> items,
  required ValueChanged<T?> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<T>(
      value: value ??
          (items.contains('Không chọn' as T) ? 'Không chọn' as T : null),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(e.toString()),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );
}
