import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/data/models/member_response.dart';
import 'package:source_base/presentation/blocs/final_deal/model/workspace_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_tag_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/customer_paging_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/product_response.dart';
import 'package:source_base/presentation/screens/customers_service/widgets/select_pill_group.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/widget/dialog_member.dart';

import '../../blocs/switch_final_deal/switch_final_deal_action.dart';
import '../shared/widgets/chip_input.dart';
import '../shared/widgets/product_selection_bottom_sheet.dart';
import 'package:source_base/presentation/screens/home/widget/assignee_selection_dialog.dart';

import 'widgets/dialog_add_tem.dart';

class SwitchFinalDeal extends StatefulWidget {
  const SwitchFinalDeal({super.key});

  @override
  State<SwitchFinalDeal> createState() => _SwitchFinalDealState();
}

class _SwitchFinalDealState extends State<SwitchFinalDeal> {
  final TextEditingController _customerNameController =
      TextEditingController(text: 'Luu Thanh Long');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _transactionValueController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  static final _inputDecoration = InputDecoration(
    hintText: 'all'.tr(),
    suffixIcon:
        const Icon(Icons.keyboard_arrow_down, color: AppColors.text, size: 20),
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
  String _selectedPersonInCharge = '1 thành viên';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<SwitchFinalDealBloc>().add(SwitchFinalDealInitialized(
        organizationId:
            context.read<OrganizationBloc>().state.organizationId ?? ''));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<SwitchFinalDealBloc>().state;
      if (currentState.note != null && currentState.note!.isNotEmpty) {
        _noteController.text = currentState.note!;
      }
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _titleController.dispose();
    _productController.dispose();
    _transactionValueController.dispose();
    _noteController.dispose();
    // context.read<SwitchFinalDealBloc>().add(ClearSelected());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SwitchFinalDealBloc, SwitchFinalDealState>(
        listener: (context, state) {
      if (state.status == SwitchFinalDealStatus.orderSuccess) {
        ShowdialogNouti(context,
                type: NotifyType.success, title: 'Đã tạo đơn hàng thành công')
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else if (state.status == SwitchFinalDealStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.error ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }, builder: (context, state) {
      List<CustomerPaging> customers = state.customers ?? [];
      CustomerPaging? customerPaging = state.selectedCustomer;
      List<WorkspaceModel> listWorkSpace = state.workSpaceModels ?? [];
      WorkspaceModel? workSpaceModel = state.selectWorkSpaceModel;
      String? customerName = state.customerService?.fullName ?? "";
      return WillPopScope(
        onWillPop: () async {
          context.read<SwitchFinalDealBloc>().add(ClearSelected());
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.text),
              onPressed: () {
                context.read<SwitchFinalDealBloc>().add(ClearSelected());
                Navigator.pop(context);
                // return true;
              },
            ),
            title: const Text('Chuyển sang chốt khách',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text)),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  context.read<SwitchFinalDealBloc>().add(
                      ConfirmSwitchFinalDeal(
                          organizationId: context
                                  .read<OrganizationBloc>()
                                  .state
                                  .organizationId ??
                              '',
                          stageId:
                              context.read<OrganizationBloc>().state.user?.id ??
                                  '',
                          title: _titleController.text,
                          transactionValue: _transactionValueController.text));
                },
                icon: const Icon(Icons.check, color: AppColors.primary),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên khách hàng
                _buildLabel('Tên khách hàng'),
                const SizedBox(height: 8),
                _buildText(
                  hintText: customerName,
                ),
                const SizedBox(height: 20),

                // Tiêu đề giao dịch
                _buildLabel('Tiêu đề giao dịch', isRequired: true),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hintText: 'Nhập tiêu đề',
                ),
                const SizedBox(height: 20),

                // Tổ chức
                _buildLabel('Tổ chức'),
                const SizedBox(height: 8),
                ChipsInput<CustomerPaging>(
                  key: const ValueKey("Chọn tổ chức"),
                  initialValue: customerPaging == null ? [] : [customerPaging],
                  allowInputText: false,
                  suggestions: customers,
                  decoration: _inputDecoration,
                  isOnlyOne: true,
                  onChanged: (data) {
                    if (data.isNotEmpty) {
                      context.read<SwitchFinalDealBloc>().add(SwicthSelected(
                          customerPaging: data.last,
                          organizationId: context
                                  .read<OrganizationBloc>()
                                  .state
                                  .organizationId ??
                              ''));
                    } else {
                      context.read<SwitchFinalDealBloc>().add(
                          const RemoveSelected(removeSelectCustomer: true));
                    }
                  },
                  chipBuilder: BuildChip,
                  suggestionBuilder: (context, sta, source) =>
                      BuildSuggestion(context, sta, source, false),
                ),

                const SizedBox(height: 20),

                // Chọn không gian làm việc
                _buildLabel('Chọn không gian làm việc', isRequired: true),
                const SizedBox(height: 8),
                ChipsInput<WorkspaceModel>(
                  key: const ValueKey("Chọn không gian làm việc"),
                  initialValue: workSpaceModel == null ? [] : [workSpaceModel],
                  allowInputText: false,
                  suggestions: listWorkSpace,
                  decoration: _inputDecoration,
                  isOnlyOne: true,
                  onChanged: (data) {
                    if (data.isNotEmpty) {
                      context.read<SwitchFinalDealBloc>().add(SwicthSelected(
                          workspaceModel: data.last,
                          organizationId: context
                                  .read<OrganizationBloc>()
                                  .state
                                  .organizationId ??
                              ''));
                    } else {
                      context
                          .read<SwitchFinalDealBloc>()
                          .add(const RemoveSelected(removeSelectWork: true));
                      setState(() {
                        workSpaceModel = null;
                      });
                    }
                  },
                  chipBuilder: BuildChip,
                  suggestionBuilder: (context, sta, source) =>
                      BuildSuggestion(context, sta, source, false),
                ),
                const SizedBox(height: 20),
                const StageSelectorDemo(),

                // Sản phẩm
                _buildLabel('Sản phẩm'),
                const SizedBox(height: 8),
                InkWell(
                    onTap: () {
                      _showProductSelectionBottomSheet();
                    },
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (state.selectedProducts.isNotEmpty) ...[
                                    for (var product
                                        in state.selectedProducts) ...[
                                      Container(
                                        // width: 200,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.primary),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(product.product.name ?? ""),
                                            const SizedBox(width: 8),
                                            Text(Helpers.formatCurrency(
                                                product.product.price ?? 0)),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ] else ...[
                                    const Text("Chọn sản phẩm")
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey),
                          ],
                        )
                        //  Row(
                        //   children: [
                        //     if (state.selectedProducts.isNotEmpty) ...[
                        //       for (var product in state.selectedProducts) ...[
                        //         Container(
                        //           width: 200,
                        //           padding: const EdgeInsets.symmetric(
                        //               horizontal: 10, vertical: 10),
                        //           decoration: BoxDecoration(
                        //             border: Border.all(color: AppColors.primary),
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           child: Row(
                        //             children: [
                        //               Text(product.product.name ?? ""),
                        //               const SizedBox(width: 8),
                        //               Text(Helpers.formatCurrency(
                        //                   product.product.price ?? 0)),
                        //             ],
                        //           ),
                        //         ),
                        //       ]
                        //     ] else ...[
                        //       const Text("Chọn sản phẩm")
                        //     ],
                        //     const Spacer(),
                        //     const Icon(Icons.keyboard_arrow_down,
                        //         color: Colors.grey),
                        //   ],
                        // )),
                        )),
                const SizedBox(height: 20),

                // Giá trị giao dịch
                _buildLabel('Giá trị giao dịch'),
                const SizedBox(height: 8),
                _buildText(
                  hintText: Helpers.formatCurrency(state.selectedProducts
                      .fold(0.0, (sum, product) => sum + product.totalPrice)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Chọn người phụ trách
                _buildLabel('Chọn người phụ trách'),
                const SizedBox(height: 8),
                _buildFilterSection(
                  title: 'Chọn người phụ trách',
                  selectedItems: [],
                  onItemSelected: (item) {},
                  onItemRemoved: (item) {},
                ),
                // Chọn không gian làm việc
                _buildLabel('Chọn nhãn', isRequired: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // WorkspaceModel ChipsInput

                    Expanded(
                      flex: 3,
                      child: ChipsInput<TagModel>(
                        key: const ValueKey("Chọn nhãn"),
                        initialValue: state.selectedBusinessProcessTag ?? [],
                        allowInputText: false,
                        suggestions: state.businessProcessTag ?? [],
                        decoration:
                            _inputDecoration.copyWith(hintText: "Chọn nhãn"),
                        isOnlyOne: false,
                        onChanged: (data) {
                          if (data.isNotEmpty) {
                            context.read<SwitchFinalDealBloc>().add(
                                SwicthSelected(
                                    businessProcessTag: data,
                                    organizationId: context
                                            .read<OrganizationBloc>()
                                            .state
                                            .organizationId ??
                                        ''));
                          } else {
                            context.read<SwitchFinalDealBloc>().add(
                                const RemoveSelected(
                                    removeSelectBusinessProcessTag: true));
                          }
                          // Xử lý khi chọn nhãn, nếu cần thiết có thể dispatch event ở đây
                          // Ví dụ: context.read<SwitchFinalDealBloc>().add(UpdateSelectedTags(tags: data));
                        },
                        chipBuilder: (context, stateTag, tagModel) {
                          return InputChip(
                            label: Text(tagModel.name),
                            backgroundColor: Color(
                              int.tryParse(tagModel.backgroundColor
                                      .replaceFirst('#', '0xff')) ??
                                  0xffe0e0e0,
                            ),
                            labelStyle: TextStyle(
                              color: Color(
                                int.tryParse(tagModel.textColor
                                        .replaceFirst('#', '0xff')) ??
                                    0xff000000,
                              ),
                            ),
                            onDeleted: () {
                              stateTag.deleteChip(tagModel);
                            },
                          );
                        },
                        suggestionBuilder: (context, stateTag, source) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(
                                int.tryParse(source.backgroundColor
                                        .replaceFirst('#', '0xff')) ??
                                    0xffe0e0e0,
                              ),
                            ),
                            title: Text(source.name),
                            onTap: () => stateTag.selectSuggestion(source),
                          );
                        },
                        onAddTag: () async {
                          final result = await showDialog<LabelData>(
                            context: context,
                            builder: (_) => const CreateLabelDialog(),
                          );

                          if (result != null) {
                            final hex =
                                '#${result.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

                            print('Tên: ${result.name}, Màu: ${hex}');
                            context.read<SwitchFinalDealBloc>().add(
                                AddBusinessProcessTag(
                                    organizationId: context
                                            .read<OrganizationBloc>()
                                            .state
                                            .organizationId ??
                                        '',
                                    name: result.name,
                                    backgroundColor: hex,
                                    textColor: "#FFFFFF",
                                    workspaceId: workSpaceModel?.id ?? ''));
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Ghi chú
                _buildLabel('Ghi chú'),
                const SizedBox(height: 8),
                _buildNoteTextField(),
                const SizedBox(height: 40),
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

  Widget _buildText({
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(hintText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            )),
        // trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        // onTap: () {
        //   _showProductSelectionBottomSheet();
        // },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNoteTextField() {
    return BlocBuilder<SwitchFinalDealBloc, SwitchFinalDealState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Nhập ghi chú...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) {
              context.read<SwitchFinalDealBloc>().add(NoteChanged(note: value));
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<MemberModel> selectedItems,
    required Function(MemberModel) onItemSelected,
    required Function(MemberModel) onItemRemoved,
  }) {
    return BlocBuilder<SwitchFinalDealBloc, SwitchFinalDealState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final selectedAssignees = await AssigneeSelectionDialog.show(
                  context,
                  context.read<OrganizationBloc>().state.organizationId ?? '',
                  state.selectedAssignees ?? []);
              if (selectedAssignees != null && mounted) {
                context.read<SwitchFinalDealBloc>().add(SwicthSelected(
                    assignees: selectedAssignees,
                    organizationId:
                        context.read<OrganizationBloc>().state.organizationId ??
                            ''));
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D5DD)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<List<MemberModel>>(
                      key: const ValueKey("assignees"),
                      valueListenable: ValueNotifier<List<MemberModel>>(
                          state.selectedAssignees ?? []),
                      builder: (context, assignees, _) {
                        return assignees.isEmpty
                            ? Text(
                                'all'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.text,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: assignees.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F4F7),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppAvatar(
                                          size: 16,
                                          shape: AvatarShape.circle,
                                          imageUrl: item.avatar,
                                          fallbackText: item.name,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.name ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF344054),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () {
                                            onItemRemoved(item);
                                            setState(() {
                                              List<MemberModel> assignees =
                                                  state.selectedAssignees ?? [];
                                              assignees.remove(item);
                                              context
                                                  .read<SwitchFinalDealBloc>()
                                                  .add(SwicthSelected(
                                                      assignees: assignees,
                                                      organizationId: context
                                                              .read<
                                                                  OrganizationBloc>()
                                                              .state
                                                              .organizationId ??
                                                          ''));
                                              // _assigneesNotifier.value =
                                              //     List.from(_selectedAssignees);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Color(0xFF667085),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                      },
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.text,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showProductSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductSelectionBottomSheet(),
    ).then((selectedProducts) {
      // if (selectedProducts != null && selectedProducts.isNotEmpty) {
      //   // Handle the selected products
      //   setState(() {
      //     // Update the product controller with the first product name
      //     _productController.text = selectedProducts.first.name;
      //   });
      // }
    });
  }

  Widget buildSuggestionProduct(
    BuildContext context,
    ChipsInputState<ProductModel> state,
    ProductModel data,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        if (isSelected) {
          state.deleteChip(data);
        } else {
          state.selectSuggestion(data);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? const Color(0xFFF9FAFB) : Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.name,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
            Text(
              Helpers.formatCurrency(data.price),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInChargeField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(
            Icons.person,
            size: 20,
            color: Colors.grey,
          ),
        ),
        title: Text(
          _selectedPersonInCharge,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
        onTap: () {
          // Hiển thị dialog chọn người phụ trách
          _showPersonInChargeDialog();
        },
      ),
    );
  }

  void _showPersonInChargeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn người phụ trách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('1 thành viên'),
              onTap: () {
                setState(() {
                  _selectedPersonInCharge = '1 thành viên';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
