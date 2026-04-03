import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/market_providers.dart';

class MarketFilterBar extends ConsumerWidget {
  const MarketFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risk = ref.watch(marketRiskFilterProvider);
    final asset = ref.watch(marketAssetFilterProvider);

    return Column(children: [
      // Row 1: Risk + Asset
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _ChipGroup(
            label: '风险',
            items: const ['全部', '低', '中', '高'],
            selected: risk,
            onChanged: (v) => ref.read(marketRiskFilterProvider.notifier).update(v),
          ),
          const SizedBox(width: 16),
          _ChipGroup(
            label: '资产',
            items: const ['全部', '稳定币', 'ETH', 'BTC'],
            selected: asset,
            onChanged: (v) => ref.read(marketAssetFilterProvider.notifier).update(v),
          ),
        ]),
      ),
    ]);
  }
}

class _ChipGroup extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onChanged;

  const _ChipGroup({
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:', style: AppTextStyles.caption1),
        const SizedBox(width: 6),
        ...items.map((item) {
          final isActive = item == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => onChanged(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? AppColors.accent : AppColors.border,
                    width: isActive ? 1 : 0.5,
                  ),
                ),
                child: Text(item, style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.accent : AppColors.secondaryLabel,
                )),
              ),
            ),
          );
        }),
      ],
    );
  }
}
