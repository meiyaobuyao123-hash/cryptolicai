import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/risk_tag.dart';
import '../../../shared/widgets/change_indicator.dart';
import '../../data_tab/models/yield_pool.dart';
import '../data/platform_yield_info.dart';
import 'yield_info_sheet.dart';

class ProductRow extends StatelessWidget {
  final YieldPool pool;
  final VoidCallback onTap;

  const ProductRow({super.key, required this.pool, required this.onTap});

  void _showYieldInfo(BuildContext context, String project) {
    showYieldInfoSheet(context, project);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Row 1: Asset name + tags
          Row(children: [
            Text(pool.symbol, style: AppTextStyles.headline),
            const SizedBox(width: 8),
            if (pool.isStablecoin) _Tag('稳定币', AppColors.accent),
            if (pool.isStablecoin) const SizedBox(width: 4),
            _Tag(pool.exposureLabel, AppColors.secondaryLabel),
            const Spacer(),
            RiskTag(level: pool.riskLevel),
          ]),
          const SizedBox(height: 4),
          // Row 2: Platform + Chain + yield info link
          Row(children: [
            Text('${pool.project} · ${pool.chain}', style: AppTextStyles.footnote),
            if (PlatformYieldInfo.get(pool.project) != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showYieldInfo(context, pool.project),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('收益机制 ›', style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ]),

          const SizedBox(height: 12),
          // Row 3: APY + trend
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              Formatters.apy(pool.apy),
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700,
                color: AppColors.green,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('APY', style: AppTextStyles.caption1),
            ),
            const SizedBox(width: 12),
            if (pool.apyPct7D != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: ChangeIndicator(value: pool.apyPct7D!, fontSize: 12, compact: true),
              ),
            if (pool.apyPct7D != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(' 7天', style: AppTextStyles.caption2),
              ),
            const Spacer(),
            if (pool.trendIcon.isNotEmpty)
              Text('${pool.trendIcon} ${pool.predictedTrend?.replaceAll('/', ' ') ?? ''}',
                style: AppTextStyles.caption1.copyWith(
                  color: pool.trendIcon == '↗' ? AppColors.green : (pool.trendIcon == '↘' ? AppColors.red : AppColors.secondaryLabel),
                )),
          ]),

          // Row 4: APY breakdown (if available)
          if (pool.apyBase != null && pool.apyBase! > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              Text('基础 ', style: AppTextStyles.caption1),
              Text('${pool.apyBase!.toStringAsFixed(1)}%',
                style: AppTextStyles.caption1.copyWith(color: AppColors.label, fontWeight: FontWeight.w500)),
              if (pool.apyReward != null && pool.apyReward! > 0) ...[
                Text('  +  奖励 ', style: AppTextStyles.caption1),
                Text('${pool.apyReward!.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption1.copyWith(
                    color: pool.isRewardHeavy ? AppColors.orange : AppColors.label,
                    fontWeight: FontWeight.w500,
                  )),
                if (pool.isRewardHeavy)
                  Text(' ⚠', style: TextStyle(fontSize: 11, color: AppColors.orange)),
              ],
            ]),
          ],

          const SizedBox(height: 10),
          // Row 5: Metrics line
          Container(height: 0.5, color: AppColors.separator),
          const SizedBox(height: 10),
          Row(children: [
            _MetricChip(CupertinoIcons.lock, Formatters.compactUsd(pool.tvlUsd)),
            const SizedBox(width: 12),
            if (pool.addressCount != null && pool.addressCount! > 0)
              _MetricChip(CupertinoIcons.person_2, '${_formatCount(pool.addressCount!)}人'),
            if (pool.addressCount != null && pool.addressCount! > 0)
              const SizedBox(width: 12),
            _MetricChip(
              pool.ilRisk == 'no' ? CupertinoIcons.checkmark_shield : CupertinoIcons.exclamationmark_triangle,
              pool.ilRisk == 'no' ? '无常损失: 无' : '有无常损失',
              color: pool.ilRisk == 'no' ? AppColors.green : AppColors.orange,
            ),
          ]),

          // Row 6: 30d mean + stability
          if (pool.apyMean30d != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Text('30天均值 ${pool.apyMean30d!.toStringAsFixed(1)}%', style: AppTextStyles.caption2),
              if (pool.stabilityLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('· ${pool.stabilityLabel}', style: AppTextStyles.caption2),
              ],
            ]),
          ],
          // Row 7: Risk summary
          const SizedBox(height: 8),
          Text(
            PlatformYieldInfo.productRiskSummary(
              riskLevel: pool.riskLevel,
              apy: pool.apy,
              ilRisk: pool.ilRisk,
              isStablecoin: pool.isStablecoin,
              exposure: pool.exposure,
              isRewardHeavy: pool.isRewardHeavy,
            ),
            style: AppTextStyles.caption2.copyWith(
              color: pool.riskLevel == '高' ? AppColors.orange : AppColors.secondaryLabel,
              height: 1.3,
            ),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _MetricChip(this.icon, this.text, {this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.secondaryLabel;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: c),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: c)),
    ]);
  }
}

String _formatCount(int n) {
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
