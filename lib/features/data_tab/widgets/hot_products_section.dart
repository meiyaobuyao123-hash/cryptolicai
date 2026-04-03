import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/risk_tag.dart';
import '../../../shared/widgets/skeleton.dart';
import '../data_definitions.dart';
import '../models/yield_pool.dart';
import '../providers/providers.dart';
import '../../staking/widgets/staking_bottom_sheet.dart';

class HotProductsSection extends ConsumerWidget {
  const HotProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(yieldAssetFilterProvider);
    final pools = ref.watch(yieldPoolsProvider);

    return SectionCard(
      title: '热门理财产品',
      subtitle: 'DefiLlama · 按 TVL 排序',
      icon: CupertinoIcons.flame,
      iconColor: AppColors.red,
      iconBg: AppColors.iconBgRed,
      infoTitle: DataDefinitions.hotProductsTitle,
      infoSource: DataDefinitions.hotProductsSource,
      infoFields: DataDefinitions.hotProductsFields,
      trailing: SegmentedControl(
        items: const ['全部', 'USDT', 'ETH', 'BTC'],
        selected: asset,
        onChanged: (v) => ref.read(yieldAssetFilterProvider.notifier).update(v),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: pools.when(
        loading: () => SizedBox(height: 150, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: EdgeInsets.zero,
          itemCount: 3, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => const Skeleton(width: 145, height: 150, borderRadius: 12))),
        error: (_, __) => SizedBox(height: 150, child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (data) {
          final display = data.take(15).toList();
          return SizedBox(height: 150, child: ListView.separated(
            scrollDirection: Axis.horizontal, padding: EdgeInsets.zero,
            itemCount: display.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _Card(pool: display[i]),
          ));
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final YieldPool pool;
  const _Card({required this.pool});

  void _onTap(BuildContext context) {
    StakingBottomSheet.show(context, pool);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
      width: 145, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(pool.symbol, style: AppTextStyles.headline.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${pool.project} · ${pool.chain}', style: AppTextStyles.caption2, maxLines: 1, overflow: TextOverflow.ellipsis),
        const Spacer(),
        Text(Formatters.apy(pool.apy),
          style: AppTextStyles.numericLarge.copyWith(color: AppColors.green, fontSize: 22)),
        Text('APY', style: AppTextStyles.caption1),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(Formatters.compactUsd(pool.tvlUsd), style: AppTextStyles.caption2),
          RiskTag(level: pool.riskLevel),
        ]),
      ]),
    ));
  }
}
