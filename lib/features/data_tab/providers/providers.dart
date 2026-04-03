import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../services/defillama_service.dart';
import '../services/coingecko_service.dart';
import '../services/cefi_service.dart';
import '../services/dune_service.dart';
import '../models/market_overview.dart';
import '../models/user_concentration.dart';
import '../models/protocol.dart';
import '../models/yield_pool.dart';
import '../models/chain_tvl.dart';
import '../models/platform_tvl_apy.dart';

// Services
final defiLlamaServiceProvider = Provider((ref) => DefiLlamaService());
final coinGeckoServiceProvider = Provider((ref) => CoinGeckoService());
final cefiServiceProvider = Provider((ref) => CefiService());
final duneServiceProvider = Provider((ref) => DuneService());

// User Concentration
final userConcentrationProvider =
    FutureProvider<List<UserConcentration>>((ref) async {
  final service = ref.read(duneServiceProvider);
  return service.fetchUserConcentration();
});

// Market Overview
final marketOverviewProvider = FutureProvider<MarketOverview>((ref) async {
  final defiService = ref.read(defiLlamaServiceProvider);
  final geckoService = ref.read(coinGeckoServiceProvider);

  final results = await Future.wait([
    defiService.fetchCurrentTvl(),
    geckoService.fetchGlobalData(),
    geckoService.fetchDefiGlobal(),
  ]);

  final tvl = results[0] as double;
  final globalData = results[1] as Map<String, dynamic>;
  final defiData = results[2] as Map<String, dynamic>;

  final totalMarketCap =
      (globalData['total_market_cap']?['usd'] as num?)?.toDouble() ?? 0;
  final marketCapChange =
      (globalData['market_cap_change_percentage_24h_usd'] as num?)
          ?.toDouble() ?? 0;
  final defiDominance =
      double.tryParse(defiData['defi_dominance']?.toString() ?? '0') ?? 0;

  return MarketOverview(
    totalDefiTvl: tvl,
    defiTvlChange24h: 0,
    totalMarketCap: totalMarketCap,
    marketCapChange24h: marketCapChange,
    defiDominance: defiDominance,
    stablecoinMarketCap: 0, // TODO: fetch from stablecoins API if needed
    updatedAt: DateTime.now(),
  );
});

// --- Simple state holders using Notifier ---

class TvlPeriodNotifier extends Notifier<String> {
  @override
  String build() => '30天';
  void update(String value) => state = value;
}

final tvlPeriodProvider =
    NotifierProvider<TvlPeriodNotifier, String>(TvlPeriodNotifier.new);

class ProtocolFilterNotifier extends Notifier<String> {
  @override
  String build() => '全部';
  void update(String value) => state = value;
}

final protocolFilterProvider =
    NotifierProvider<ProtocolFilterNotifier, String>(ProtocolFilterNotifier.new);

class YieldAssetFilterNotifier extends Notifier<String> {
  @override
  String build() => '全部';
  void update(String value) => state = value;
}

final yieldAssetFilterProvider =
    NotifierProvider<YieldAssetFilterNotifier, String>(
        YieldAssetFilterNotifier.new);

// TVL History
final tvlHistoryProvider = FutureProvider<List<TvlDataPoint>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  final period = ref.watch(tvlPeriodProvider);
  final allData = await service.fetchHistoricalTvl();

  final now = DateTime.now();
  final days = switch (period) {
    '7天' => 7,
    '30天' => 30,
    '90天' => 90,
    '1年' => 365,
    _ => 30,
  };

  final cutoff = now.subtract(Duration(days: days));
  return allData.where((p) => p.date.isAfter(cutoff)).toList();
});

// Protocol Ranking
final protocolRankingProvider = FutureProvider<List<Protocol>>((ref) async {
  final defiService = ref.read(defiLlamaServiceProvider);
  final cefiService = ref.read(cefiServiceProvider);
  final filter = ref.watch(protocolFilterProvider);

  if (filter == 'CeFi') {
    return cefiService.fetchCefiExchanges();
  }

  final defiProtocols = await defiService.fetchProtocols();

  if (filter == 'DeFi') {
    return defiProtocols.take(20).toList();
  }

  // "全部" — merge DeFi + CeFi (dynamic API data)
  final cefiProtocols = await cefiService.fetchCefiExchanges();
  final all = [...defiProtocols, ...cefiProtocols];
  all.sort((a, b) => b.tvl.compareTo(a.tvl));
  return all.take(20).toList();
});

// Chain Distribution
final chainDistributionProvider = FutureProvider<List<ChainTvl>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  return service.fetchChains();
});

// Yield Pools
final yieldPoolsProvider = FutureProvider<List<YieldPool>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  final asset = ref.watch(yieldAssetFilterProvider);
  final pools = await service.fetchYieldPools(
    asset: asset == '全部' ? null : asset,
  );
  return pools.take(30).toList();
});

// Yield Distribution
final yieldDistributionProvider =
    FutureProvider<List<YieldCategory>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  return service.fetchYieldDistribution();
});

// Prices
final pricesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(coinGeckoServiceProvider);
  return service.fetchPrices();
});

// CeFi Exchanges (dynamic)
final cefiExchangesProvider = FutureProvider<List<Protocol>>((ref) async {
  final service = ref.read(cefiServiceProvider);
  return service.fetchCefiExchanges();
});

// Platform TVL & APY Distribution (aggregated from yield pools)
final platformTvlApyProvider =
    FutureProvider<List<PlatformTvlApy>>((ref) async {
  final service = ref.read(defiLlamaServiceProvider);
  final pools = await service.fetchYieldPools();

  // Group by project
  final grouped = <String, List<YieldPool>>{};
  for (final pool in pools) {
    grouped.putIfAbsent(pool.project, () => []).add(pool);
  }

  // Aggregate per platform with concentration metrics
  final result = grouped.entries.map((entry) {
    final name = entry.key;
    final pPools = entry.value;
    final totalTvl = pPools.fold<double>(0, (s, p) => s + p.tvlUsd);
    final apys = pPools.map((p) => p.apy).toList()..sort();
    if (apys.isEmpty) return null; // Skip platforms with no pools
    final weightedSum = pPools.fold<double>(0, (s, p) => s + p.apy * p.tvlUsd);
    final weightedAvg = totalTvl > 0 ? weightedSum / totalTvl : 0.0;

    // Top 3 pool concentration
    final sortedByTvl = List<YieldPool>.from(pPools)
      ..sort((a, b) => b.tvlUsd.compareTo(a.tvlUsd));
    final top3Tvl = sortedByTvl.take(3).fold<double>(0, (s, p) => s + p.tvlUsd);
    final top3Pct = totalTvl > 0 ? top3Tvl / totalTvl : 0.0;

    // APY band distribution (by TVL weight)
    double lowTvl = 0, midTvl = 0, highTvl = 0;
    for (final p in pPools) {
      if (p.apy < 5) {
        lowTvl += p.tvlUsd;
      } else if (p.apy < 15) {
        midTvl += p.tvlUsd;
      } else {
        highTvl += p.tvlUsd;
      }
    }

    // Top asset
    final assetMap = <String, double>{};
    for (final p in pPools) {
      final token = p.symbol.split('-').first.trim().toUpperCase();
      assetMap[token] = (assetMap[token] ?? 0) + p.tvlUsd;
    }
    final topEntry = assetMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topAsset = topEntry.isNotEmpty ? topEntry.first.key : '-';
    final topAssetPct = topEntry.isNotEmpty && totalTvl > 0
        ? topEntry.first.value / totalTvl
        : 0.0;

    // HHI (Herfindahl-Hirschman Index) — pool-level concentration
    double hhi = 0;
    if (totalTvl > 0) {
      for (final p in pPools) {
        final share = p.tvlUsd / totalTvl;
        hhi += share * share;
      }
    }

    return PlatformTvlApy(
      project: name,
      totalTvl: totalTvl,
      poolCount: pPools.length,
      minApy: apys.first,
      maxApy: apys.last.clamp(0, 100),
      weightedAvgApy: weightedAvg,
      top3TvlPct: top3Pct,
      lowApyTvlPct: totalTvl > 0 ? lowTvl / totalTvl : 0,
      midApyTvlPct: totalTvl > 0 ? midTvl / totalTvl : 0,
      highApyTvlPct: totalTvl > 0 ? highTvl / totalTvl : 0,
      topAsset: topAsset,
      topAssetPct: topAssetPct,
      hhi: hhi,
    );
  }).whereType<PlatformTvlApy>().toList();

  result.sort((a, b) => b.totalTvl.compareTo(a.totalTvl));
  return result.take(10).toList();
});
