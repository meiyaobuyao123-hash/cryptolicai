import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/segmented_control.dart';
import '../staking/widgets/staking_bottom_sheet.dart';
import '../data_tab/models/yield_pool.dart';
import 'providers/market_providers.dart';
import 'widgets/product_row.dart';
import 'widgets/market_empty_state.dart';

class PlatformProductsPage extends ConsumerStatefulWidget {
  final String slug;
  final String name;
  const PlatformProductsPage({super.key, required this.slug, required this.name});

  @override
  ConsumerState<PlatformProductsPage> createState() => _State();
}

class _State extends ConsumerState<PlatformProductsPage> {
  String _sort = 'APY';

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(platformProductsProvider(widget.slug));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(widget.name),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
            previousPageTitle: '市场',
          ),
          data.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, __) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Skeleton(height: 140, borderRadius: 14)),
                childCount: 4,
              )),
            ),
            error: (_, __) => SliverFillRemaining(
              child: MarketEmptyState(
                message: '加载失败',
                actionLabel: '重试',
                onAction: () => ref.invalidate(platformProductsProvider(widget.slug)),
              ),
            ),
            data: (pools) {
              if (pools.isEmpty) {
                return const SliverFillRemaining(
                  child: MarketEmptyState(message: '该平台暂无可用产品'),
                );
              }
              final sorted = List<YieldPool>.from(pools);
              switch (_sort) {
                case 'APY': sorted.sort((a, b) => b.apy.compareTo(a.apy));
                case 'TVL': sorted.sort((a, b) => b.tvlUsd.compareTo(a.tvlUsd));
                case '风险': sorted.sort((a, b) => a.apy.compareTo(b.apy));
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 60),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  // Sort + count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(children: [
                      Text('${sorted.length} 个产品', style: AppTextStyles.footnote),
                      const Spacer(),
                      SegmentedControl(
                        items: const ['APY', 'TVL', '风险'],
                        selected: _sort,
                        onChanged: (v) => setState(() => _sort = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  // Product cards
                  ...sorted.map((pool) => ProductRow(
                    pool: pool,
                    onTap: () => StakingBottomSheet.show(context, pool),
                  )),
                  const SizedBox(height: 16),
                  Text('收益率为实时浮动，以实际到账为准',
                    style: AppTextStyles.caption2, textAlign: TextAlign.center),
                ])),
              );
            },
          ),
        ],
      ),
    );
  }
}
