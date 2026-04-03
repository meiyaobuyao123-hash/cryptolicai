import 'package:fl_chart/fl_chart.dart';
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
import '../providers/providers.dart';

class TvlTrendSection extends ConsumerWidget {
  const TvlTrendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(tvlPeriodProvider);
    final tvlData = ref.watch(tvlHistoryProvider);

    return SectionCard(
      title: 'TVL 趋势',
      subtitle: 'DefiLlama · 全链汇总',
      icon: CupertinoIcons.graph_square,
      iconColor: AppColors.teal,
      iconBg: AppColors.iconBgTeal,
      infoTitle: DataDefinitions.tvlTrendTitle,
      infoSource: DataDefinitions.tvlTrendSource,
      infoFields: DataDefinitions.tvlTrendFields,
      trailing: SegmentedControl(
        items: const ['7天', '30天', '90天', '1年'],
        selected: period,
        onChanged: (v) => ref.read(tvlPeriodProvider.notifier).update(v),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: tvlData.when(
        loading: () => const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Skeleton(height: 200)),
        error: (_, __) => SizedBox(height: 200, child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (data) {
          if (data.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('暂无数据')));
          final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.tvl / 1e9)).toList();
          final ys = spots.map((s) => s.y).toList();
          final minY = ys.reduce((a, b) => a < b ? a : b);
          final maxY = ys.reduce((a, b) => a > b ? a : b);
          final pad = (maxY - minY) * 0.1;
          final cMin = (minY - pad).clamp(0.0, double.infinity);
          final cMax = maxY + pad;
          final yInt = ((cMax - cMin) / 4).ceilToDouble().clamp(1.0, double.infinity);

          return SizedBox(height: 200, child: Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: LineChart(LineChartData(
              minY: cMin, maxY: cMax, clipData: const FlClipData.all(),
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: yInt,
                getDrawingHorizontalLine: (_) => FlLine(color: AppColors.separator, strokeWidth: 0.5)),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(), rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44, interval: yInt,
                  getTitlesWidget: (v, _) => Text('\$${v.toStringAsFixed(0)}B', style: AppTextStyles.caption2))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
                  interval: data.length > 10 ? (data.length / 4).ceilToDouble() : 1,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 6),
                      child: Text(Formatters.shortDate(data[i].date), style: AppTextStyles.caption2));
                  })),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [LineChartBarData(
                spots: spots, isCurved: true, preventCurveOverShooting: true,
                color: AppColors.accent, barWidth: 1.5, dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppColors.accent.withValues(alpha: 0.12), AppColors.accent.withValues(alpha: 0.0)])),
              )],
              lineTouchData: LineTouchData(handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  getTooltipItems: (s) => s.map((sp) => LineTooltipItem('\$${sp.y.toStringAsFixed(1)}B',
                    const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))).toList()),
                getTouchedSpotIndicator: (_, idxs) => idxs.map((_) => TouchedSpotIndicatorData(
                  FlLine(color: AppColors.accent.withValues(alpha: 0.3), strokeWidth: 1),
                  FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                    radius: 4, color: AppColors.accent, strokeWidth: 2, strokeColor: AppColors.cardBg)))).toList()),
            )),
          ));
        },
      ),
    );
  }
}
