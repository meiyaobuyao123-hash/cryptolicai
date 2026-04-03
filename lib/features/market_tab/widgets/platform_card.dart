import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../providers/market_providers.dart';
import 'yield_info_sheet.dart';

class PlatformCard extends StatelessWidget {
  final MarketPlatformSummary platform;
  final VoidCallback onTap;
  final int index;

  const PlatformCard({super.key, required this.platform, required this.onTap, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.chartColors[index % AppColors.chartColors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(platform.displayName[0],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color))),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(platform.displayName,
                style: AppTextStyles.headline.copyWith(fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 2),
            Text(platform.category, style: AppTextStyles.caption2),
            const Spacer(),
            Text(Formatters.apy(platform.avgApy),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.green)),
            Text('平均 APY', style: AppTextStyles.caption2),
            const SizedBox(height: 4),
            Text(Formatters.compactUsd(platform.totalTvl), style: AppTextStyles.caption2),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => showYieldInfoSheet(context, platform.slug),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('了解收益 ›', style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
