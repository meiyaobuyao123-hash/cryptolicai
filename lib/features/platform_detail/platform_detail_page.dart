import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/skeleton.dart';
import 'models/platform_detail.dart';
import 'providers/platform_detail_provider.dart';

class PlatformDetailPage extends ConsumerWidget {
  final String slug;
  final String name;

  const PlatformDetailPage({super.key, required this.slug, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(platformDetailProvider(slug));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(name),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
            previousPageTitle: '数据',
          ),
          detail.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(delegate: SliverChildListDelegate([
                const Skeleton(height: 100), const SizedBox(height: 20),
                const Skeleton(height: 200), const SizedBox(height: 20),
                const Skeleton(height: 200),
              ])),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(CupertinoIcons.exclamationmark_circle, color: AppColors.tertiaryLabel, size: 32),
                const SizedBox(height: 12),
                Text('加载失败', style: AppTextStyles.footnote),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => ref.invalidate(platformDetailProvider(slug)),
                  child: Text('重试', style: AppTextStyles.footnote.copyWith(color: AppColors.accent)),
                ),
              ])),
            ),
            data: (data) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 60),
              sliver: SliverList(delegate: SliverChildListDelegate([
                _Header(data: data),
                const SizedBox(height: 28),
                _ApyHistogram(data: data),
                const SizedBox(height: 28),
                _AssetDistribution(data: data),
                const SizedBox(height: 28),
                _ChainDistribution(data: data),
                const SizedBox(height: 28),
                _TopPools(data: data),
              ])),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  final PlatformDetail data;
  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(children: [
          _Stat('总 TVL', Formatters.compactUsd(data.totalTvl)),
          const SizedBox(width: 24),
          _Stat('池子数', '${data.poolCount}'),
          const SizedBox(width: 24),
          _Stat('中位 APY', Formatters.apy(data.medianApy)),
          const SizedBox(width: 24),
          _Stat('最高 APY', Formatters.apy(data.maxApy)),
        ]),
        const SizedBox(height: 16),
        Container(height: 1, color: AppColors.separator),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.caption1),
      const SizedBox(height: 3),
      Text(value, style: AppTextStyles.numericSmall),
    ]);
  }
}

// ── APY Histogram ──
class _ApyHistogram extends StatelessWidget {
  final PlatformDetail data;
  const _ApyHistogram({required this.data});

  @override
  Widget build(BuildContext context) {
    final buckets = data.apyBuckets;
    final maxCount = buckets.values.fold<int>(0, (a, b) => a > b ? a : b);
    if (maxCount == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('收益分布', style: AppTextStyles.headline),
        Text('${data.poolCount} 个池子的 APY 分布', style: AppTextStyles.caption1),
        const SizedBox(height: 16),
        ...buckets.entries.map((e) {
          final pct = e.value / maxCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 50, child: Text(e.key, style: AppTextStyles.footnote.copyWith(color: AppColors.label))),
              const SizedBox(width: 8),
              Expanded(child: Stack(children: [
                Container(height: 20, decoration: BoxDecoration(
                  color: AppColors.fill, borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(widthFactor: pct.clamp(0.02, 1.0),
                  child: Container(height: 20, decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4)))),
              ])),
              const SizedBox(width: 8),
              SizedBox(width: 30, child: Text('${e.value}', style: AppTextStyles.footnote.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.label), textAlign: TextAlign.right)),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.separator),
      ],
    );
  }
}

// ── Asset Distribution ──
class _AssetDistribution extends StatelessWidget {
  final PlatformDetail data;
  const _AssetDistribution({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.assetTvl.isEmpty) return const SizedBox.shrink();

    final sorted = data.assetTvl.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final total = sorted.fold<double>(0, (s, e) => s + e.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('资金分布', style: AppTextStyles.headline),
        Text('按资产类型', style: AppTextStyles.caption1),
        const SizedBox(height: 16),
        // Stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 20,
            child: Row(children: top.asMap().entries.map((e) {
              final pct = e.value.value / total;
              final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
              return Expanded(
                flex: (pct * 100).round().clamp(1, 100),
                child: Container(color: color.withValues(alpha: 0.7)),
              );
            }).toList()),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 16, runSpacing: 8,
          children: top.asMap().entries.map((e) {
            final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
            final pct = (e.value.value / total * 100).toStringAsFixed(1);
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text('${e.value.key} $pct%', style: AppTextStyles.caption1.copyWith(color: AppColors.label)),
            ]);
          }).toList(),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: AppColors.separator),
      ],
    );
  }
}

// ── Chain Distribution ──
class _ChainDistribution extends StatelessWidget {
  final PlatformDetail data;
  const _ChainDistribution({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.chainTvl.isEmpty) return const SizedBox.shrink();

    final sorted = data.chainTvl.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final maxVal = top.isNotEmpty ? top.first.value : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('链分布', style: AppTextStyles.headline),
        Text('按链上 TVL', style: AppTextStyles.caption1),
        const SizedBox(height: 14),
        ...top.asMap().entries.map((e) {
          final bar = e.value.value / maxVal;
          final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 70, child: Text(e.value.key,
                style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Expanded(child: Stack(children: [
                Container(height: 12, decoration: BoxDecoration(
                  color: AppColors.fill, borderRadius: BorderRadius.circular(3))),
                FractionallySizedBox(widthFactor: bar.clamp(0.02, 1.0),
                  child: Container(height: 12, decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(3)))),
              ])),
              const SizedBox(width: 8),
              SizedBox(width: 56, child: Text(Formatters.compactUsd(e.value.value),
                style: AppTextStyles.caption1, textAlign: TextAlign.right)),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.separator),
      ],
    );
  }
}

// ── Top Pools ──
class _TopPools extends StatelessWidget {
  final PlatformDetail data;
  const _TopPools({required this.data});

  @override
  Widget build(BuildContext context) {
    final pools = data.pools.take(10).toList();
    if (pools.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('热门池子', style: AppTextStyles.headline),
        Text('按 TVL 排序 · Top ${pools.length}', style: AppTextStyles.caption1),
        const SizedBox(height: 12),
        // Table header
        Row(children: [
          SizedBox(width: 24, child: Text('#', style: AppTextStyles.caption1)),
          Expanded(child: Text('资产', style: AppTextStyles.caption1)),
          SizedBox(width: 60, child: Text('链', style: AppTextStyles.caption1)),
          SizedBox(width: 50, child: Text('APY', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
          SizedBox(width: 60, child: Text('TVL', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
        ]),
        const SizedBox(height: 8),
        ...pools.asMap().entries.map((e) {
          final pool = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              SizedBox(width: 24, child: Text('${e.key + 1}',
                style: AppTextStyles.caption1.copyWith(fontWeight: FontWeight.w600))),
              Expanded(child: Text(pool.symbol,
                style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              SizedBox(width: 60, child: Text(pool.chain,
                style: AppTextStyles.caption1, maxLines: 1, overflow: TextOverflow.ellipsis)),
              SizedBox(width: 50, child: Text(
                Formatters.apy(pool.apy),
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: pool.apy > 0 ? AppColors.green : AppColors.label,
                  fontFeatures: const [FontFeature.tabularFigures()]),
                textAlign: TextAlign.right)),
              SizedBox(width: 60, child: Text(Formatters.compactUsd(pool.tvlUsd),
                style: AppTextStyles.caption1, textAlign: TextAlign.right)),
            ]),
          );
        }),
      ],
    );
  }
}
