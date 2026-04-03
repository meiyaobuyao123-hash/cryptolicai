import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/skeleton.dart';
import '../staking/widgets/staking_bottom_sheet.dart';
import 'providers/market_providers.dart';
import 'widgets/platform_card.dart';
import 'widgets/product_row.dart';
import 'widgets/market_filter_bar.dart';
import 'widgets/market_empty_state.dart';

class MarketPage extends ConsumerWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platforms = ref.watch(topPlatformsProvider);
    final products = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('市场'),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
          ),
          CupertinoSliverRefreshControl(onRefresh: () async {
            ref.invalidate(topPlatformsProvider);
            ref.invalidate(featuredProductsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          }),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 0, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Top Platforms ──
              Text('头部平台', style: AppTextStyles.headline),
              const SizedBox(height: 2),
              Text('DeFi 理财协议', style: AppTextStyles.caption1),
              const SizedBox(height: 12),
            ]),
          )),
          // Platform horizontal scroll
          SliverToBoxAdapter(child: SizedBox(
            height: 170,
            child: platforms.when(
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => const Skeleton(width: 140, height: 160, borderRadius: 14),
              ),
              error: (_, __) => const Center(child: Text('加载失败')),
              data: (list) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => PlatformCard(
                  platform: list[i],
                  index: i,
                  onTap: () => context.push('/discover/platform/${list[i].slug}?name=${Uri.encodeComponent(list[i].displayName)}'),
                ),
              ),
            ),
          )),
          // ── Filter + Products ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('精选产品', style: AppTextStyles.headline),
                const Spacer(),
                Text('按风险调整收益排序', style: AppTextStyles.caption2),
              ]),
              const SizedBox(height: 12),
              const MarketFilterBar(),
              const SizedBox(height: 8),
              Container(height: 0.5, color: AppColors.separator),
            ])),
          ),
          // Product list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: products.when(
              loading: () => SliverList(delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(padding: EdgeInsets.only(bottom: 8), child: Skeleton(height: 48)),
                childCount: 6,
              )),
              error: (_, __) => SliverToBoxAdapter(
                child: MarketEmptyState(
                  message: '加载失败',
                  actionLabel: '重试',
                  onAction: () => ref.invalidate(featuredProductsProvider),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: MarketEmptyState(
                      message: '未找到匹配的产品\n试试调整筛选条件',
                      actionLabel: '重置筛选',
                      onAction: () {
                        ref.read(marketRiskFilterProvider.notifier).update('全部');
                        ref.read(marketAssetFilterProvider.notifier).update('全部');
                        ref.read(marketChainFilterProvider.notifier).update('全部');
                      },
                    ),
                  );
                }
                return SliverList(delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final pool = list[i];
                    return Column(children: [
                      ProductRow(
                        pool: pool,
                        onTap: () {
                          if (pool.apy > 20) {
                            _showRiskWarning(context, () => StakingBottomSheet.show(context, pool));
                          } else {
                            StakingBottomSheet.show(context, pool);
                          }
                        },
                      ),
                      if (i < list.length - 1) Container(height: 0.5, color: AppColors.separator),
                    ]);
                  },
                  childCount: list.length,
                ));
              },
            ),
          ),
          // Disclaimer
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
            child: Text('收益率为实时浮动，以实际到账为准。DeFi 理财涉及智能合约风险。',
              style: AppTextStyles.caption2, textAlign: TextAlign.center),
          )),
        ],
      ),
    );
  }

  void _showRiskWarning(BuildContext context, VoidCallback onConfirm) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('高收益风险提示'),
        content: const Text('该产品 APY 较高（>20%），通常伴随更高的智能合约风险、无常损失或代币通胀风险。请确认您了解相关风险。'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text('我了解风险，继续'),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
