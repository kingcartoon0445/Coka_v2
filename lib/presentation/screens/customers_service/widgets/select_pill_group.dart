import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/models/business_process_template_response.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/switch_final_deal_state.dart';
import 'package:source_base/presentation/screens/shared/widgets/chip_input.dart';

import '../../../blocs/final_deal/final_deal_action.dart'
    show BlocBuilder, ReadContext, BlocSelector;
import '../../../blocs/switch_final_deal/switch_final_deal_action.dart';
import '../../../blocs/switch_final_deal/switch_final_deal_bloc.dart';

/// -------------------------------------------
/// Generic SelectPillGroup
/// -------------------------------------------
class SelectPillGroup<T extends ChipData> extends StatelessWidget {
  const SelectPillGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.labelBuilder,
    this.spacing = 12,
    this.runSpacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.selectedBgColor,
    this.selectedFgColor,
    this.unselectedBgColor,
    this.unselectedBorderColor,
    this.unselectedFgColor,
    this.allowDeselect = false,
    this.selectedPredicate, // NEW: so sánh tùy biến (vd theo id)
  });

  /// Data source
  final List<T> items;

  /// Currently selected value (nullable)
  final T? selected;

  /// Called with the new value (or null if deselected and [allowDeselect] == true)
  final ValueChanged<T?> onChanged;

  /// Builds the label widget for each item. Defaults to `Text(item.name)`.
  final Widget Function(BuildContext context, T item)? labelBuilder;

  /// Layout and style
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? selectedBgColor;
  final Color? selectedFgColor;
  final Color? unselectedBgColor;
  final Color? unselectedBorderColor;
  final Color? unselectedFgColor;
  final bool allowDeselect;

  /// Cách xác định selected. Mặc định dùng `==`
  final bool Function(T? selected, T item)? selectedPredicate;

  bool _isSelected(T item) {
    if (selectedPredicate != null) return selectedPredicate!(selected, item);
    return selected != null && selected == item;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selBg = selectedBgColor ?? theme.colorScheme.primary;
    final selFg = selectedFgColor ?? theme.colorScheme.onPrimary;
    final unselBg = unselectedBgColor ?? theme.colorScheme.surface;
    final unselBorder =
        unselectedBorderColor ?? theme.colorScheme.outlineVariant;
    final unselFg = unselectedFgColor ?? theme.colorScheme.onSurfaceVariant;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final item in items)
          _Pill(
            isSelected: _isSelected(item),
            onTap: () {
              final currentlySelected = _isSelected(item);
              if (allowDeselect && currentlySelected) {
                onChanged(null); // deselect
              } else {
                onChanged(item); // select
              }
            },
            padding: padding,
            borderRadius: borderRadius,
            selectedBg: selBg,
            selectedFg: selFg,
            unselectedBg: unselBg,
            unselectedBorder: unselBorder,
            unselectedFg: unselFg,
            child: DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              child: labelBuilder?.call(context, item) ??
                  Text(item.name.toString(),
                      style: TextStyle(
                          fontSize: 12,
                          color: _isSelected(item)
                              ? Colors.white
                              : AppColors.text)),
            ),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.isSelected,
    required this.onTap,
    required this.child,
    required this.padding,
    required this.borderRadius,
    required this.selectedBg,
    required this.selectedFg,
    required this.unselectedBg,
    required this.unselectedBorder,
    required this.unselectedFg,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color selectedBg;
  final Color selectedFg;
  final Color unselectedBg;
  final Color unselectedBorder;
  final Color unselectedFg;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? selectedBg : unselectedBg;
    final fg = isSelected ? selectedFg : unselectedFg;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: isSelected
              ? BorderSide(
                  color: selectedBg, width: 0) // no border when selected
              : BorderSide(color: unselectedBorder, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding,
            child: IconTheme(
              data: IconThemeData(color: fg),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: fg),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// -------------------------------------------
/// Demo screen (dùng Bloc state làm nguồn chân lý)
/// -------------------------------------------

final _inputDecoration = InputDecoration(
  hintText: "Chọn template",
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

class StageSelectorDemo extends StatelessWidget {
  const StageSelectorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchFinalDealBloc, SwitchFinalDealState>(
      // Giới hạn rebuild chỉ khi các field liên quan đổi
      buildWhen: (prev, curr) {
        final a = prev.selectWorkSpaceModel != curr.selectWorkSpaceModel;
        final b = prev.businessProcess != curr.businessProcess;
        final c = prev.selectBusinessProcess != curr.selectBusinessProcess;
        final d = prev.businessProcessTemplate != curr.businessProcessTemplate;
        final e = prev.selectBusinessProcessTemplate !=
            curr.selectBusinessProcessTemplate;
        return a || b || c || d || e;
      },
      builder: (context, stateBloc) {
        // Workspace chưa sẵn sàng
        if (stateBloc.selectWorkSpaceModel == null) {
          return const SizedBox();
        }

        // Nếu chưa có businessProcess -> hiển thị chọn template
        final businessProcess = stateBloc.businessProcess ?? [];
        if (businessProcess.isEmpty) {
          final businessProcessTemplate =
              stateBloc.businessProcessTemplate ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn template *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ChipsInput<BusinessProcessTemplateModel>(
                key: const ValueKey("Chọn template"),
                initialValue: stateBloc.selectBusinessProcessTemplate == null
                    ? []
                    : [stateBloc.selectBusinessProcessTemplate!],
                allowInputText: false,
                suggestions: businessProcessTemplate,
                decoration: _inputDecoration,
                isOnlyOne: true,
                onChanged: (data) {
                  if (data.isNotEmpty) {
                    context.read<SwitchFinalDealBloc>().add(
                          SwicthSelected(
                            businessProcessTemplate: data.last,
                            organizationId: context
                                    .read<OrganizationBloc>()
                                    .state
                                    .organizationId ??
                                '',
                          ),
                        );
                  } else {
                    context.read<SwitchFinalDealBloc>().add(
                          const RemoveSelected(
                              removeSelectBusinessProcessTemplate: true),
                        );
                  }
                },
                chipBuilder: BuildChip,
                suggestionBuilder: (context, sta, source) =>
                    BuildSuggestion(context, sta, source, false),
              ),
              const SizedBox(height: 20),
            ],
          );
        }

        // Có businessProcess -> hiển thị chọn giai đoạn
        final selected = stateBloc.selectBusinessProcess; // dùng state của Bloc
        final needSelect = selected == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn giai đoạn *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: needSelect ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 16),

            /// Lưu ý: so sánh selected theo id để không phụ thuộc tham chiếu
            SelectPillGroup<BusinessProcessModel>(
              items: businessProcess,
              selected: selected,
              onChanged: (value) {
                // Cập nhật vào Bloc (và cho phép bỏ chọn)
                context.read<SwitchFinalDealBloc>().add(
                      SwicthSelected(
                        businessProcess: value, // cần hỗ trợ trong event
                        organizationId: context
                                .read<OrganizationBloc>()
                                .state
                                .organizationId ??
                            '',
                      ),
                    );
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              selectedBgColor: const Color(0xFF4F46E5),
              selectedFgColor: Colors.white,
              unselectedBgColor: Colors.white,
              unselectedBorderColor: const Color(0xFFE5E7EB),
              unselectedFgColor: const Color(0xFF374151),
              allowDeselect: true,
              selectedPredicate: (sel, item) {
                // Nếu model có id, so sánh theo id; nếu sel null -> false
                if (sel == null) return false;
                try {
                  return (sel as dynamic).id == (item as dynamic).id;
                } catch (_) {
                  // fallback: so sánh tham chiếu
                  return sel == item;
                }
              },
            ),

            if (needSelect) ...[
              const SizedBox(height: 16),
              const Text(
                'Hãy chọn giai đoạn trước',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            ],
          ],
        );
      },
    );
  }
}
