import '../../data_tab/models/yield_pool.dart';

class PlatformDetail {
  final String name;
  final String slug;
  final String category;
  final double totalTvl;
  final List<YieldPool> pools;
  final Map<String, double> chainTvl;       // chain → TVL
  final Map<String, double> assetTvl;       // token symbol → TVL
  final Map<String, int> apyBuckets;        // "0-2%" → count

  PlatformDetail({
    required this.name,
    required this.slug,
    required this.category,
    required this.totalTvl,
    required this.pools,
    required this.chainTvl,
    required this.assetTvl,
    required this.apyBuckets,
  });

  int get poolCount => pools.length;

  double get medianApy {
    if (pools.isEmpty) return 0;
    final sorted = pools.map((p) => p.apy).toList()..sort();
    return sorted[sorted.length ~/ 2];
  }

  double get maxApy {
    if (pools.isEmpty) return 0;
    return pools.map((p) => p.apy).reduce((a, b) => a > b ? a : b);
  }

  double get weightedAvgApy {
    if (pools.isEmpty) return 0;
    final totalWeight = pools.fold<double>(0, (s, p) => s + p.tvlUsd);
    if (totalWeight == 0) return 0;
    return pools.fold<double>(0, (s, p) => s + p.apy * p.tvlUsd) / totalWeight;
  }
}
