import 'dart:math';
import '../../data_tab/models/yield_pool.dart';

class ProductScoringService {
  /// Score a pool by risk-adjusted return × TVL weight
  static double score(YieldPool pool) {
    final riskPenalty = pool.apy <= 8 ? 1.0 : (pool.apy <= 20 ? 0.8 : 0.5);
    final tvlWeight = pool.tvlUsd > 0 ? log(pool.tvlUsd) / log(10) : 0.0;
    return pool.apy * riskPenalty * tvlWeight;
  }

  /// Sort pools by score descending
  static List<YieldPool> rank(List<YieldPool> pools) {
    final sorted = List<YieldPool>.from(pools);
    sorted.sort((a, b) => score(b).compareTo(score(a)));
    return sorted;
  }

  /// Filter pools by criteria
  static List<YieldPool> filter(
    List<YieldPool> pools, {
    String risk = '全部',
    String asset = '全部',
    String chain = '全部',
  }) {
    var result = pools;

    if (risk != '全部') {
      result = result.where((p) => p.riskLevel == risk).toList();
    }

    if (asset != '全部') {
      if (asset == '稳定币') {
        result = result.where((p) {
          final s = p.symbol.toUpperCase();
          return s.contains('USDT') || s.contains('USDC') || s.contains('DAI') || s.contains('FRAX');
        }).toList();
      } else {
        result = result.where((p) => p.symbol.toUpperCase().contains(asset.toUpperCase())).toList();
      }
    }

    if (chain != '全部') {
      result = result.where((p) => p.chain.toLowerCase() == chain.toLowerCase()).toList();
    }

    return result;
  }
}
