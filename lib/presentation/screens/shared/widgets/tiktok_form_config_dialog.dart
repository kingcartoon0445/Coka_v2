import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/connection_channel_action.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/model/account_tiktok_model.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/model/form_account_tiktok_reponse.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';

class TiktokFormConfigDialog extends StatefulWidget {
  final String? title;

  const TiktokFormConfigDialog({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  State<TiktokFormConfigDialog> createState() => _TiktokFormConfigDialogState();
}

class _TiktokFormConfigDialogState extends State<TiktokFormConfigDialog> {
  String? _selectedAccount;
  String? _selectedForm;
  String? _tiktokField;
  String? _cokaField;

  List<AccountTiktokModel>? _accountOptions = [];

  List<FormAccountTiktokModel>? _formOptions = [];

  final List<String> _fieldOptions = [
    'Fullname',
    'Email',
    'Phone',
    'Gender',
    'Note',
    'Dob',
    'PhysicalId',
    'DateOfIssue',
    'Address',
    'Rating',
    'Work',
    'Avatar',
    'AssignTo',
  ];
  @override
  void initState() {
    // TODO: implement initState
    context.read<ConnectionChannelBloc>().add(GetTiktokLeadConnectionsEvent(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? '',
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionChannelBloc, ConnectionChannelState>(
        builder: (context, state) {
      if (state.status ==
          ConnectionChannelStatus.getTiktokLeadConnectionsSuccess) {
        _accountOptions = state.accountTiktok ?? [];
      }
      if (state.status == ConnectionChannelStatus.getTiktokItemListSuccess) {
        _formOptions = state.formAccountTiktok ?? [];
      }
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with better spacing
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title ?? 'Cấu hình Tiktok Form',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _onSave,
                          child: const Text(
                            'Lưu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Account Section
                    _buildAccountField(),
                    const SizedBox(height: 28),

                    // Form Section
                    _buildFormField(),
                    const SizedBox(height: 28),

                    // Configuration Section
                    _buildConfigurationField(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Chọn tài khoản Tiktok', isRequired: true),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: _selectedAccount,
          hintText: 'Chọn tài khoản',
          items: _accountOptions?.map((e) => e.name ?? '').toList() ?? [],
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _selectedAccount = val;
            });
            final account = _accountOptions?.firstWhere((e) => e.name == val);
            context.read<ConnectionChannelBloc>().add(GetTiktokItemListEvent(
                  organizationId:
                      context.read<OrganizationBloc>().state.organizationId ??  
                          '',
                  subscribedId: account?.id ?? '',
                  isConnect: 'false',
                ));
          },
        ),
        const SizedBox(height: 16),
        _buildAddAccountButton(),
      ],
    );
  }

  Widget _buildFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Chọn Form', isRequired: true),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: _selectedForm,
          hintText: 'Chọn form kết nối',
          items: _formOptions?.map((e) => e.title ?? '').toList() ?? [],
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _selectedForm = val;
            });
            context
                .read<ConnectionChannelBloc>()
                .add(GetTiktokConfigurationEvent(
                  organizationId:
                      context.read<OrganizationBloc>().state.organizationId ??
                          '',
                  connectionId: _selectedAccount ?? '',
                  pageId: _selectedForm ?? '',
                ));
          },
        ),
      ],
    );
  }

  Widget _buildConfigurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Cấu hình', isRequired: true),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tiktok field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Tiktok field'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: _buildTextField(
                      controller: TextEditingController(text: _tiktokField),
                      hintText: 'Nhập tên field',
                      onChanged: (value) {
                        setState(() {
                          _tiktokField = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Connection arrow with better styling
            const SizedBox(width: 8),
            // Coka field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Coka field'),
                  const SizedBox(height: 8),
                  _buildSmallDropdownField(
                    value: _cokaField,
                    hintText: 'Chọn field',
                    items: _fieldOptions,
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _cokaField = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1.5,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((s) => DropdownMenuItem<String>(
                  value: s,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
              size: 18,
            ),
          ),
        ),
        icon: const SizedBox.shrink(),
        dropdownColor: Colors.white,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        menuMaxHeight: 200,
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        elevation: 8,
        focusColor: Colors.transparent,
        focusNode: FocusNode(),
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildSmallDropdownField({
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1.5,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((s) => DropdownMenuItem<String>(
                  value: s,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
              size: 16,
            ),
          ),
        ),
        icon: const SizedBox.shrink(),
        dropdownColor: Colors.white,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        menuMaxHeight: 200,
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        elevation: 8,
        focusColor: Colors.transparent,
        focusNode: FocusNode(),
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!, width: 1.5),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return InkWell(
      onTap: () {
        // TODO: Implement add account logic
        Helpers().connectTiktokPage(context).then((value) {
          context
              .read<ConnectionChannelBloc>()
              .add(GetTiktokLeadConnectionsEvent(
                organizationId:
                    context.read<OrganizationBloc>().state.organizationId ?? '',
              ));
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[600]!, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Thêm tài khoản',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    // Validate required fields
    if (_selectedAccount == null || _selectedForm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // TODO: Implement save logic
    Navigator.of(context).pop({
      'account': _selectedAccount,
      'form': _selectedForm,
      'tiktokField': _tiktokField,
      'cokaField': _cokaField,
    });
  }
}

// Helper function to show the dialog
Future<Map<String, dynamic>?> showTiktokFormConfigDialog(
  BuildContext context, {
  String? title,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => TiktokFormConfigDialog(
      title: title,
    ),
  );
}
