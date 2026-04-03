import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data_tab/models/yield_pool.dart';
import '../../data_tab/providers/providers.dart';
import '../services/product_scoring_service.dart';

// ── Curated platform list ──
const _curatedSlugs = [
  'aave-v3', 'lido', 'compound-v3', 'eigenlayer',
  'pendle', 'morpho', 'rocket-pool', 'maker',
];

// ── Filter Notifiers ──
class _StringNotifier extends Notifier<String> {
  final String _default;
  _StringNotifier(this._default);
  @override
  String build() => _default;
  void update(String v) => state = v;
}

final marketRiskFilterProvider = NotifierProvider<_StringNotifier, String>(() => _StringNotifier('全部'));
final marketAssetFilterProvider = NotifierProvider<_StringNotifier, String>(() => _StringNotifier('全部'));
final marketChainFilterProvider = NotifierProvider<_StringNotifier, String>(() => _StringNotifier('全部'));

// ── Top Platforms ──
class MarketPlatformSummary {
  final String slug;
  final String displayName;
  final int poolCount;
  final double totalTvl;
  final double avgApy;
  final String category;

  MarketPlatformSummary({
    required this.slug,
    required this.displayName,
    required this.poolCount,
    required this.totalTvl,
    required this.avgApy,
    required this.category,
  });
}

const _displayNames = {
  'aave-v3': 'Aave V3',
  'lido': 'Lido',
  'compound-v3': 'Compound',
  'eigenlayer': 'EigenLayer',
  'pendle': 'Pendle',
  'morpho': 'Morpho',
  'rocket-pool': 'Rocket Pool',
  'maker': 'Maker',
};

const _categories = {
  'aave-v3': '借贷',
  'lido': '质押',
  'compound-v3': '借贷',
  'eigenlayer': '再质押',
  'pendle': '收益代币化',
  'morpho': '借贷',
  'rocket-pool': '质押',
  'maker': 'CDP',
};

final topPlatformsProvider = FutureProvider<List<MarketPlatformSummary>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  final allPools = await service.fetchYieldPools();

  return _curatedSlugs.map((slug) {
    final pools = allPools.where((p) => p.project.toLowerCase() == slug.toLowerCase()).toList();
    final tvl = pools.fold<double>(0, (s, p) => s + p.tvlUsd);
    final weightedSum = pools.fold<double>(0, (s, p) => s + p.apy * p.tvlUsd);
    final avgApy = tvl > 0 ? weightedSum / tvl : 0.0;

    return MarketPlatformSummary(
      slug: slug,
      displayName: _displayNames[slug] ?? slug,
      poolCount: pools.length,
      totalTvl: tvl,
      avgApy: avgApy,
      category: _categories[slug] ?? 'DeFi',
    );
  }).where((p) => p.poolCount > 0).toList();
});

// ── Featured Products (filtered + scored) ──
final featuredProductsProvider = FutureProvider<List<YieldPool>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  final allPools = await service.fetchYieldPools();
  final risk = ref.watch(marketRiskFilterProvider);
  final asset = ref.watch(marketAssetFilterProvider);
  final chain = ref.watch(marketChainFilterProvider);

  // Filter to curated platforms only
  var pools = allPools.where((p) =>
    _curatedSlugs.any((s) => p.project.toLowerCase() == s.toLowerCase())
  ).toList();

  // Apply user filters
  pools = ProductScoringService.filter(pools, risk: risk, asset: asset, chain: chain);

  // Score and rank
  return ProductScoringService.rank(pools).take(30).toList();
});

// ── Platform Products (for detail page) ──
final platformProductsProvider =
    FutureProvider.family<List<YieldPool>, String>((ref, slug) async {
  final service = ref.read(defiLlamaServiceProvider);
  return service.fetchPoolsByProject(slug);
});

// ── Available chains (for filter) ──
final availableChainsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  final pools = await service.fetchYieldPools();
  final chains = pools
      .where((p) => _curatedSlugs.any((s) => p.project.toLowerCase() == s.toLowerCase()))
      .map((p) => p.chain)
      .toSet()
      .toList();
  chains.sort();
  return chains;
});
