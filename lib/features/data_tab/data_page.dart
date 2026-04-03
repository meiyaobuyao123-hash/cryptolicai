import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/market_overview_section.dart';
import 'widgets/tvl_trend_section.dart';
import 'widgets/platform_ranking_section.dart';
import 'widgets/cefi_defi_comparison_section.dart';
import 'widgets/hot_products_section.dart';
import 'widgets/yield_distribution_section.dart';
import 'widgets/chain_distribution_section.dart';
import 'widgets/platform_tvl_apy_section.dart';
import 'widgets/user_concentration_section.dart';
import 'providers/providers.dart';

class DataPage extends ConsumerWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('数据'),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
          ),
          CupertinoSliverRefreshControl(onRefresh: () async {
            ref.invalidate(marketOverviewProvider);
            ref.invalidate(tvlHistoryProvider);
            ref.invalidate(protocolRankingProvider);
            ref.invalidate(chainDistributionProvider);
            ref.invalidate(yieldPoolsProvider);
            ref.invalidate(yieldDistributionProvider);
            ref.invalidate(platformTvlApyProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          }),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 60),
            sliver: SliverList(delegate: SliverChildListDelegate([
              const MarketOverviewSection(),
              const SizedBox(height: 24),
              const TvlTrendSection(),
              const SizedBox(height: 24),
              const PlatformRankingSection(),
              const SizedBox(height: 24),
              const PlatformTvlApySection(),
              const SizedBox(height: 24),
              const UserConcentrationSection(),
              const SizedBox(height: 24),
              const CefiDefiComparisonSection(),
              const SizedBox(height: 24),
              const HotProductsSection(),
              const SizedBox(height: 24),
              const YieldDistributionSection(),
              const SizedBox(height: 24),
              const ChainDistributionSection(),
            ])),
          ),
        ],
      ),
    );
  }
}
