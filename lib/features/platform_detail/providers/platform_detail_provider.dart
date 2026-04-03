import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data_tab/providers/providers.dart';
import '../models/platform_detail.dart';

final platformDetailProvider =
    FutureProvider.family<PlatformDetail, String>((ref, slug) async {
  final service = ref.read(defiLlamaServiceProvider);

  // Fetch pools and chain TVL in parallel
  final results = await Future.wait([
    service.fetchPoolsByProject(slug),
    service.fetchProtocolChainTvl(slug),
  ]);

  final pools = (results[0] is List) ? results[0] as List : [];
  final chainTvl = (results[1] is Map) ? results[1] as Map<String, double> : <String, double>{};

  // Aggregate asset distribution from pools
  final assetTvl = <String, double>{};
  for (final pool in pools) {
    // Extract primary token from symbol (e.g. "USDT" from "USDT-WETH")
    final tokens = pool.symbol.split('-');
    for (final token in tokens) {
      final t = token.trim().toUpperCase();
      assetTvl[t] = (assetTvl[t] ?? 0) + pool.tvlUsd / tokens.length;
    }
  }

  // APY histogram buckets
  final buckets = <String, int>{
    '0-2%': 0, '2-5%': 0, '5-10%': 0, '10-20%': 0, '20%+': 0,
  };
  for (final pool in pools) {
    if (pool.apy < 2) {
      buckets['0-2%'] = buckets['0-2%']! + 1;
    } else if (pool.apy < 5) {
      buckets['2-5%'] = buckets['2-5%']! + 1;
    } else if (pool.apy < 10) {
      buckets['5-10%'] = buckets['5-10%']! + 1;
    } else if (pool.apy < 20) {
      buckets['10-20%'] = buckets['10-20%']! + 1;
    } else {
      buckets['20%+'] = buckets['20%+']! + 1;
    }
  }

  final totalTvl = pools.fold<double>(0, (s, p) => s + p.tvlUsd);

  return PlatformDetail(
    name: slug,
    slug: slug,
    category: pools.isNotEmpty ? (pools.first as dynamic).project ?? 'DeFi' : '',
    totalTvl: totalTvl,
    pools: List.from(pools),
    chainTvl: chainTvl,
    assetTvl: assetTvl,
    apyBuckets: buckets,
  );
});
