import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/presentation/blocs/final_deal/model/business_process_response.dart';

class StageProgressBar extends StatelessWidget {
  const StageProgressBar({
    super.key,
    required this.stages,
    required this.currentStage,
    this.onPrev,
    this.onNext,
  });

  final List<BusinessProcessModel> stages;
  final BusinessProcessModel? currentStage;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    // final primary = const Color(0xFF5B4BEB);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.textTertiary.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        children: [
          _NavButton(icon: Icons.chevron_left, onTap: onPrev),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Text(
                    currentStage?.name ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (int i = 0; i < stages.length; i++)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              right: i == stages.length - 1 ? 0 : 4),
                          height: 5,
                          decoration: BoxDecoration(
                            color: stages[i].id == currentStage?.id
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
          _NavButton(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, this.onTap, this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          color:
              onTap == null ? const Color(0xFF6B7280) : color ?? Colors.black,
        ),
      ),
    );
  }
}
