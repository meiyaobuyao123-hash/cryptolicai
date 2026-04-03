import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/skeleton.dart';
import '../data_definitions.dart';
import '../models/platform_tvl_apy.dart';
import '../providers/providers.dart';

class PlatformTvlApySection extends ConsumerStatefulWidget {
  const PlatformTvlApySection({super.key});

  @override
  ConsumerState<PlatformTvlApySection> createState() => _State();
}

class _State extends ConsumerState<PlatformTvlApySection> {
  String _view = '本金';

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(platformTvlApyProvider);

    return SectionCard(
      title: '平台资金与收益',
      subtitle: 'DefiLlama · Top 10 DeFi 平台',
      icon: CupertinoIcons.money_dollar_circle,
      iconColor: AppColors.teal,
      iconBg: AppColors.iconBgTeal,
      infoTitle: DataDefinitions.platformTvlApyTitle,
      infoSource: DataDefinitions.platformTvlApySource,
      infoFields: DataDefinitions.platformTvlApyFields,
      trailing: SegmentedControl(
        items: const ['本金', '收益', '集中度'],
        selected: _view,
        onChanged: (v) => setState(() => _view = v),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: data.when(
        loading: () => const Skeleton(height: 250),
        error: (_, __) => SizedBox(height: 200, child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (platforms) => switch (_view) {
          '本金' => _TvlView(platforms: platforms),
          '收益' => _ApyView(platforms: platforms),
          '集中度' => _ConcentrationView(platforms: platforms),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

// ── 本金分布 ──
class _TvlView extends StatelessWidget {
  final List<PlatformTvlApy> platforms;
  const _TvlView({required this.platforms});

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) return const SizedBox.shrink();
    final total = platforms.fold<double>(0, (s, p) => s + p.totalTvl);
    final maxTvl = platforms.first.totalTvl;

    return Column(children: [
      // Stacked bar
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(height: 24, child: Row(
          children: platforms.asMap().entries.map((e) {
            final pct = (e.value.totalTvl / total * 100).round().clamp(1, 100);
            final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
            return Expanded(flex: pct, child: Container(color: color.withValues(alpha: 0.7)));
          }).toList(),
        )),
      ),
      const SizedBox(height: 16),
      ...platforms.asMap().entries.map((e) {
        final p = e.value;
        final pct = p.totalTvl / total * 100;
        final bar = p.totalTvl / maxTvl;
        final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text(p.project, style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(child: Stack(children: [
            Container(height: 6, decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(3))),
            FractionallySizedBox(widthFactor: bar.clamp(0.02, 1.0),
              child: Container(height: 6, decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(3)))),
          ])),
          const SizedBox(width: 8),
          SizedBox(width: 56, child: Text(Formatters.compactUsd(p.totalTvl),
            style: AppTextStyles.caption1.copyWith(color: AppColors.label), textAlign: TextAlign.right)),
          SizedBox(width: 38, child: Text('${pct.toStringAsFixed(0)}%',
            style: AppTextStyles.caption2, textAlign: TextAlign.right)),
        ]));
      }),
    ]);
  }
}

// ── 收益分布 ──
class _ApyView extends StatelessWidget {
  final List<PlatformTvlApy> platforms;
  const _ApyView({required this.platforms});

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) return const SizedBox.shrink();
    final sorted = List<PlatformTvlApy>.from(platforms)
      ..sort((a, b) => b.weightedAvgApy.compareTo(a.weightedAvgApy));
    final globalMax = sorted.fold<double>(0, (m, p) => p.maxApy > m ? p.maxApy : m).clamp(1, 50);

    return Column(children: [
      Row(children: [
        SizedBox(width: 80, child: Text('平台', style: AppTextStyles.caption1)),
        Expanded(child: Text('APY 范围', style: AppTextStyles.caption1, textAlign: TextAlign.center)),
        SizedBox(width: 50, child: Text('加权均值', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
      ]),
      const SizedBox(height: 10),
      ...sorted.asMap().entries.map((e) {
        final p = e.value;
        final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
        final minPct = (p.minApy / globalMax).clamp(0.0, 1.0);
        final maxPct = (p.maxApy / globalMax).clamp(0.0, 1.0);
        final avgPct = (p.weightedAvgApy / globalMax).clamp(0.0, 1.0);
        return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
          SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.project, style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${p.poolCount}个池子', style: AppTextStyles.caption2),
          ])),
          Expanded(child: SizedBox(height: 20, child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            return Stack(children: [
              Positioned.fill(child: Container(decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(3)))),
              Positioned(left: minPct * w, width: ((maxPct - minPct) * w).clamp(2, w), top: 5, bottom: 5,
                child: Container(decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)))),
              Positioned(left: avgPct * w - 4, top: 2, child: Container(width: 8, height: 16,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
            ]);
          }))),
          const SizedBox(width: 6),
          SizedBox(width: 50, child: Text('${p.weightedAvgApy.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green,
              fontFeatures: const [FontFeature.tabularFigures()]), textAlign: TextAlign.right)),
        ]));
      }),
    ]);
  }
}

// ── 集中度分析 ──
class _ConcentrationView extends StatelessWidget {
  final List<PlatformTvlApy> platforms;
  const _ConcentrationView({required this.platforms});

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) return const SizedBox.shrink();

    return Column(children: [
      // Table header
      Row(children: [
        SizedBox(width: 72, child: Text('平台', style: AppTextStyles.caption1)),
        SizedBox(width: 46, child: Text('Top3\n集中', style: AppTextStyles.caption2, textAlign: TextAlign.center)),
        SizedBox(width: 50, child: Text('头部\n资产', style: AppTextStyles.caption2, textAlign: TextAlign.center)),
        Expanded(child: Text('收益分布（按TVL）', style: AppTextStyles.caption2, textAlign: TextAlign.center)),
        SizedBox(width: 28, child: Text('集中', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
      ]),
      const SizedBox(height: 10),
      ...platforms.asMap().entries.map((e) {
        final p = e.value;
        final concColor = switch (p.concentrationLevel) {
          '高' => AppColors.red,
          '中' => AppColors.orange,
          _ => AppColors.green,
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Platform name
            SizedBox(width: 72, child: Text(p.project,
              style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
            // Top 3 concentration
            SizedBox(width: 46, child: Text('${(p.top3TvlPct * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: p.top3TvlPct > 0.8 ? AppColors.red : p.top3TvlPct > 0.5 ? AppColors.orange : AppColors.green,
                fontFeatures: const [FontFeature.tabularFigures()]),
              textAlign: TextAlign.center)),
            // Top asset
            SizedBox(width: 50, child: Column(children: [
              Text(p.topAsset, style: AppTextStyles.caption1.copyWith(color: AppColors.label, fontWeight: FontWeight.w500)),
              Text('${(p.topAssetPct * 100).toStringAsFixed(0)}%', style: AppTextStyles.caption2),
            ])),
            // Yield distribution stacked bar
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(height: 14, child: Row(children: [
                  if (p.lowApyTvlPct > 0)
                    Expanded(flex: (p.lowApyTvlPct * 100).round().clamp(1, 100),
                      child: Container(color: AppColors.accent.withValues(alpha: 0.3))),
                  if (p.midApyTvlPct > 0)
                    Expanded(flex: (p.midApyTvlPct * 100).round().clamp(1, 100),
                      child: Container(color: AppColors.green.withValues(alpha: 0.5))),
                  if (p.highApyTvlPct > 0)
                    Expanded(flex: (p.highApyTvlPct * 100).round().clamp(1, 100),
                      child: Container(color: AppColors.orange.withValues(alpha: 0.6))),
                ])),
              ),
            )),
            // Concentration level
            SizedBox(width: 28, child: Text(p.concentrationLevel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: concColor),
              textAlign: TextAlign.right)),
          ]),
        );
      }),
      const SizedBox(height: 8),
      // Legend
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Legend(AppColors.accent.withValues(alpha: 0.3), '<5%'),
        const SizedBox(width: 12),
        _Legend(AppColors.green.withValues(alpha: 0.5), '5-15%'),
        const SizedBox(width: 12),
        _Legend(AppColors.orange.withValues(alpha: 0.6), '>15%'),
      ]),
    ]);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.caption2),
    ]);
  }
}
