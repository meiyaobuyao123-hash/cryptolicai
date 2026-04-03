import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/skeleton.dart';
import '../platform_detail/models/platform_detail.dart';
import 'providers/compare_provider.dart';

class PlatformComparePage extends ConsumerWidget {
  const PlatformComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(compareDataProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('平台对比'),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
            previousPageTitle: '数据',
          ),
          data.when(
            loading: () => const SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(child: Skeleton(height: 300)),
            ),
            error: (_, __) => SliverFillRemaining(
              child: Center(child: Text('加载失败', style: AppTextStyles.footnote)),
            ),
            data: (platforms) {
              if (platforms.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text('请长按排行榜中的平台进行选择', style: AppTextStyles.footnote)),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 60),
                sliver: SliverToBoxAdapter(child: _CompareTable(platforms: platforms)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final List<PlatformDetail> platforms;
  const _CompareTable({required this.platforms});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('总 TVL', platforms.map((p) => Formatters.compactUsd(p.totalTvl)).toList()),
      ('池子数', platforms.map((p) => '${p.poolCount}').toList()),
      ('中位 APY', platforms.map((p) => Formatters.apy(p.medianApy)).toList()),
      ('最高 APY', platforms.map((p) => Formatters.apy(p.maxApy)).toList()),
      ('加权 APY', platforms.map((p) => Formatters.apy(p.weightedAvgApy)).toList()),
      ('链数', platforms.map((p) => '${p.chainTvl.length}').toList()),
    ];

    return Column(
      children: [
        // Header row — platform names
        Row(children: [
          const SizedBox(width: 80),
          ...platforms.map((p) => Expanded(
            child: Text(p.name, style: AppTextStyles.headline.copyWith(fontSize: 14), textAlign: TextAlign.center),
          )),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: AppColors.separator),
        // Metric rows
        ...metrics.map((m) => Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(children: [
              SizedBox(width: 80, child: Text(m.$1, style: AppTextStyles.footnote)),
              ...m.$2.map((v) => Expanded(
                child: Text(v, style: AppTextStyles.numericSmall.copyWith(fontSize: 14), textAlign: TextAlign.center),
              )),
            ]),
          ),
          Container(height: 0.5, color: AppColors.separator),
        ])),
      ],
    );
  }
}
