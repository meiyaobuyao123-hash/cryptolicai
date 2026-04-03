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

class ChainDistributionSection extends ConsumerWidget {
  const ChainDistributionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chains = ref.watch(chainDistributionProvider);
    return SectionCard(
      title: '链上资产分布',
      subtitle: 'DefiLlama · CoinGecko · 市值 vs TVL',
      icon: CupertinoIcons.circle_grid_hex,
      iconColor: AppColors.green,
      iconBg: AppColors.iconBgGreen,
      infoTitle: DataDefinitions.chainDistTitle,
      infoSource: DataDefinitions.chainDistSource,
      infoFields: DataDefinitions.chainDistFields,
      child: chains.when(
        loading: () => Column(children: List.generate(5, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12), child: Skeleton(height: 18)))),
        error: (_, __) => SizedBox(height: 200, child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (data) {
          final top = data.take(8).toList();
          final totalTvl = data.fold<double>(0, (s, c) => s + c.tvl);
          final totalMcap = top.fold<double>(0, (s, c) => s + (c.marketCap ?? 0));
          final maxPct = top.isNotEmpty ? top.first.tvl / totalTvl : 1.0;

          return Column(children: [
            // Table header
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Expanded(flex: 3, child: Text('链', style: AppTextStyles.caption1)),
                SizedBox(width: 56, child: Text('市值', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
                SizedBox(width: 32, child: Text('%', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
                SizedBox(width: 50, child: Text('TVL', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
                SizedBox(width: 32, child: Text('%', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
              ]),
            ),
            ...top.asMap().entries.map((e) {
              final chain = e.value;
              final tvlPct = chain.tvl / totalTvl;
              final mcapPct = (chain.marketCap != null && totalMcap > 0) ? chain.marketCap! / totalMcap : 0.0;
              final bar = tvlPct / maxPct;
              final color = AppColors.chartColors[e.key % AppColors.chartColors.length];

              return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(
                children: [
                  Row(children: [
                    Expanded(flex: 3, child: Text(chain.name,
                      style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    SizedBox(width: 56, child: Text(
                      chain.marketCap != null ? Formatters.compactUsd(chain.marketCap!) : '-',
                      style: AppTextStyles.caption1.copyWith(color: AppColors.label),
                      textAlign: TextAlign.right)),
                    SizedBox(width: 32, child: Text(
                      chain.marketCap != null ? '${(mcapPct * 100).toStringAsFixed(0)}%' : '-',
                      style: AppTextStyles.caption2,
                      textAlign: TextAlign.right)),
                    SizedBox(width: 50, child: Text(
                      Formatters.compactUsd(chain.tvl),
                      style: AppTextStyles.caption1.copyWith(color: AppColors.label),
                      textAlign: TextAlign.right)),
                    SizedBox(width: 32, child: Text(
                      '${(tvlPct * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.caption2,
                      textAlign: TextAlign.right)),
                  ]),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(children: [
                      Container(height: 4, decoration: BoxDecoration(
                        color: AppColors.fill, borderRadius: BorderRadius.circular(2))),
                      FractionallySizedBox(widthFactor: bar.clamp(0.02, 1.0),
                        child: Container(height: 4, decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2)))),
                    ]),
                  ),
                ],
              ));
            }),
          ]);
        },
      ),
    );
  }
}
