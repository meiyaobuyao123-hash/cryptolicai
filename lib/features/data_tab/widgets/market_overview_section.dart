import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/change_indicator.dart';
import '../../../shared/widgets/info_tooltip.dart';
import '../../../shared/widgets/skeleton.dart';
import '../data_definitions.dart';
import '../models/market_overview.dart';
import '../providers/providers.dart';

class MarketOverviewSection extends ConsumerWidget {
  const MarketOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(marketOverviewProvider);
    return overview.when(
      loading: () => const Skeleton(height: 140),
      error: (_, __) => _buildError(ref),
      data: (data) => _buildContent(data),
    );
  }

  Widget _buildContent(MarketOverview data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — compact
        Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.iconBgBlue, borderRadius: BorderRadius.circular(7)),
              child: const Icon(CupertinoIcons.chart_bar_alt_fill, size: 14, color: AppColors.accent),
            ),
            const SizedBox(width: 8),
            Text('市场概览', style: AppTextStyles.headline.copyWith(fontSize: 15)),
            const SizedBox(width: 6),
            Text('${Formatters.time(data.updatedAt)}', style: AppTextStyles.caption1),
            const Spacer(),
            InfoTooltipButton(
              title: DataDefinitions.marketOverviewTitle,
              dataSource: DataDefinitions.marketOverviewSource,
              fields: DataDefinitions.marketOverviewFields,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Metrics row — all same weight, balanced
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TVL — primary but not overwhelming
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DeFi TVL', style: AppTextStyles.caption1),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.compactUsd(data.totalDefiTvl),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                      letterSpacing: -0.8,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            // Market cap
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('总市值', style: AppTextStyles.caption1),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.compactUsd(data.totalMarketCap),
                    style: AppTextStyles.numericSmall,
                  ),
                ],
              ),
            ),
            // DeFi dominance
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DeFi占比', style: AppTextStyles.caption1),
                  const SizedBox(height: 4),
                  Text(
                    '${data.defiDominance.toStringAsFixed(1)}%',
                    style: AppTextStyles.numericSmall,
                  ),
                ],
              ),
            ),
            // 24h change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('24h', style: AppTextStyles.caption1),
                const SizedBox(height: 4),
                ChangeIndicator(value: data.marketCapChange24h, fontSize: 15),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.separator),
      ],
    );
  }

  Widget _buildError(WidgetRef ref) {
    return SizedBox(
      height: 100,
      child: Center(child: GestureDetector(
        onTap: () => ref.invalidate(marketOverviewProvider),
        child: Text('加载失败，点击重试', style: AppTextStyles.footnote.copyWith(color: AppColors.accent)),
      )),
    );
  }
}
