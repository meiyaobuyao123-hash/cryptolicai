import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/skeleton.dart';
import '../data_definitions.dart';
import '../providers/providers.dart';

class CefiDefiComparisonSection extends ConsumerWidget {
  const CefiDefiComparisonSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(marketOverviewProvider);
    return overview.when(
      loading: () => const Skeleton(height: 300, borderRadius: 16),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final defi = data.totalDefiTvl;
        const cefi = 230e9;
        final total = defi + cefi;
        final dPct = defi / total * 100;
        final cPct = cefi / total * 100;

        return SectionCard(
          title: 'CeFi vs DeFi',
          subtitle: 'DefiLlama · 行业报告',
          icon: CupertinoIcons.arrow_2_squarepath,
          iconColor: AppColors.purple,
          iconBg: AppColors.iconBgPurple,
          infoTitle: DataDefinitions.cefiDefiTitle,
          infoSource: DataDefinitions.cefiDefiSource,
          infoFields: DataDefinitions.cefiDefiFields,
          child: Column(children: [
            // Stacked bar (like the reference screenshot)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 16,
                child: Row(children: [
                  Expanded(flex: dPct.round(), child: Container(color: AppColors.accent)),
                  Expanded(flex: cPct.round(), child: Container(color: AppColors.purple)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${dPct.toStringAsFixed(1)}% DeFi', style: AppTextStyles.caption1.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
              Text('${cPct.toStringAsFixed(1)}% CeFi', style: AppTextStyles.caption1.copyWith(color: AppColors.purple, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 20),
            // Comparison table
            _TableRow('', 'DeFi', 'CeFi', isHeader: true),
            Container(height: 0.5, color: AppColors.separator, margin: const EdgeInsets.symmetric(vertical: 8)),
            _TableRow('锁仓量', Formatters.compactUsd(defi), Formatters.compactUsd(cefi)),
            _TableRow('收益范围', '2-8%', '2-14%'),
            _TableRow('安全模式', '自托管', '平台托管'),
            _TableRow('入门门槛', '较高', '较低'),
            _TableRow('透明度', '链上可审计', '部分不透明'),
          ]),
        );
      },
    );
  }
}

class _TableRow extends StatelessWidget {
  final String label, left, right;
  final bool isHeader;
  const _TableRow(this.label, this.left, this.right, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final style = isHeader
      ? AppTextStyles.caption1.copyWith(fontWeight: FontWeight.w600)
      : AppTextStyles.footnote;
    final valStyle = isHeader
      ? AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label)
      : AppTextStyles.body.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(flex: 3, child: Text(label, style: style)),
        Expanded(flex: 3, child: Text(left, style: valStyle, textAlign: TextAlign.center)),
        Expanded(flex: 3, child: Text(right, style: valStyle, textAlign: TextAlign.center)),
      ]),
    );
  }
}
