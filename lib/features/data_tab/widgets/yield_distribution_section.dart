import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/skeleton.dart';
import '../data_definitions.dart';
import '../providers/providers.dart';

class YieldDistributionSection extends ConsumerWidget {
  const YieldDistributionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dist = ref.watch(yieldDistributionProvider);
    return SectionCard(
      title: '各赛道收益率分布',
      subtitle: 'DefiLlama · 最低/中位/最高 APY',
      icon: CupertinoIcons.chart_bar_square,
      iconColor: AppColors.indigo,
      iconBg: Color(0xFFE0E7FF),
      infoTitle: DataDefinitions.yieldDistTitle,
      infoSource: DataDefinitions.yieldDistSource,
      infoFields: DataDefinitions.yieldDistFields,
      child: dist.when(
        loading: () => const Skeleton(height: 220),
        error: (_, __) => SizedBox(height: 220, child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (cats) {
          if (cats.isEmpty) return const SizedBox(height: 220, child: Center(child: Text('暂无数据')));
          return SizedBox(height: 240, child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _maxY(cats),
            barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                '${['最低', '中位', '最高'][ri]}: ${rod.toY.toStringAsFixed(1)}%',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)))),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(), rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: AppTextStyles.caption2))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= cats.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 6), child: Text(cats[i].name, style: AppTextStyles.caption1));
                }))),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(drawVerticalLine: false, horizontalInterval: 10,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.separator, strokeWidth: 0.5)),
            barGroups: cats.asMap().entries.map((e) {
              final c = AppColors.chartColors[e.key % AppColors.chartColors.length];
              return BarChartGroupData(x: e.key, barRods: [
                BarChartRodData(toY: e.value.minApy.clamp(0, 100), color: c.withValues(alpha: 0.25), width: 10, borderRadius: BorderRadius.circular(3)),
                BarChartRodData(toY: e.value.medianApy.clamp(0, 100), color: c, width: 10, borderRadius: BorderRadius.circular(3)),
                BarChartRodData(toY: e.value.maxApy.clamp(0, 100), color: c.withValues(alpha: 0.5), width: 10, borderRadius: BorderRadius.circular(3)),
              ]);
            }).toList(),
          )));
        },
      ),
    );
  }
  double _maxY(List c) { double m = 0; for (final x in c) { if (x.maxApy > m) m = x.maxApy; } return (m * 1.2).clamp(10, 100); }
}
