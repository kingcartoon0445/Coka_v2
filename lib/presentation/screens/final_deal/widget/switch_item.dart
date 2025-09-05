import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart'; 
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';

import '../../../blocs/final_deal/final_deal_action.dart';

class SwitchItem extends StatefulWidget {
  final String taskId;
  const SwitchItem({
    super.key,
    required this.taskId,
  });

  @override
  State<SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<SwitchItem> {
  String idSelected = "";
  @override
  void initState() {
    super.initState();
    idSelected =
        context.read<FinalDealBloc>().state.selectedBusinessProcess?.id ?? '';
  }

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'change_stage'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Stages List
          Expanded(
            child: BlocSelector<FinalDealBloc, FinalDealState,
                List<BusinessProcessModel>?>(
              selector: (s) => s.businessProcesses,
              builder: (context, businessProcesses) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: businessProcesses?.length ?? 0,
                  itemBuilder: (context, businessProcesse) {
                    final stage = businessProcesses![businessProcesse];
                    bool isSelected = stage.id == idSelected;
                    return InkWell(
                      onTap: () {
                        // Update selected stage
                        context.read<FinalDealBloc>().add(
                              ChangeStage(
                                organizationId: context
                                        .read<OrganizationBloc>()
                                        .state
                                        .organizationId ??
                                    '',
                                businessProcess: stage,
                                taskId: widget.taskId,
                              ),
                            );
                        Navigator.pop(context);
                        // log('Changed stage to: ${stage['name']} for transaction at index: $index');
                        // TODO: Implement actual stage change logic
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              stage.name ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 24,
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
