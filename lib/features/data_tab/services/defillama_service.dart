import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/market_overview.dart';
import '../models/protocol.dart';
import '../models/yield_pool.dart';
import '../models/chain_tvl.dart';

class DefiLlamaService {
  final _client = DioClient();

  /// Fetch historical TVL data
  Future<List<TvlDataPoint>> fetchHistoricalTvl() async {
    final response = await _client.get(
      ApiEndpoints.historicalTvl,
      cacheTtl: const Duration(seconds: 300),
    );
    final List data = response.data;
    return data.map((item) {
      return TvlDataPoint(
        date: DateTime.fromMillisecondsSinceEpoch((item['date'] as int) * 1000),
        tvl: (item['tvl'] as num).toDouble(),
      );
    }).toList();
  }

  /// Fetch current total DeFi TVL (latest point from historical)
  Future<double> fetchCurrentTvl() async {
    final history = await fetchHistoricalTvl();
    return history.isNotEmpty ? history.last.tvl : 0;
  }

  /// Fetch all chains TVL + market cap from CoinGecko
  Future<List<ChainTvl>> fetchChains() async {
    final response = await _client.get(
      ApiEndpoints.chains,
      cacheTtl: const Duration(seconds: 300),
    );
    final List data = response.data;
    final chains = data
        .map((item) => ChainTvl.fromJson(item))
        .where((c) => c.tvl > 0)
        .toList();
    chains.sort((a, b) => b.tvl.compareTo(a.tvl));

    // Fetch market caps for top chains from CoinGecko
    final topChains = chains.take(10).toList();
    final geckoIds = topChains
        .where((c) => c.geckoId != null && c.geckoId!.isNotEmpty)
        .map((c) => c.geckoId!)
        .toList();

    if (geckoIds.isNotEmpty) {
      try {
        final mcResponse = await _client.get(
          'https://api.coingecko.com/api/v3/simple/price',
          queryParameters: {
            'ids': geckoIds.join(','),
            'vs_currencies': 'usd',
            'include_market_cap': 'true',
          },
          cacheTtl: const Duration(seconds: 300),
        );
        final Map<String, dynamic> mcData = mcResponse.data;
        for (final chain in topChains) {
          if (chain.geckoId != null && mcData.containsKey(chain.geckoId)) {
            final coinData = mcData[chain.geckoId] as Map<String, dynamic>?;
            chain.marketCap = (coinData?['usd_market_cap'] as num?)?.toDouble();
          }
        }
      } catch (_) {
        // CoinGecko rate limit — gracefully skip market cap
      }
    }

    return chains;
  }

  /// Fetch protocols filtered for finance-related categories
  Future<List<Protocol>> fetchProtocols() async {
    final response = await _client.get(
      ApiEndpoints.protocols,
      cacheTtl: const Duration(seconds: 300),
    );
    final List data = response.data;
    const financeCategories = {
      'Lending', 'Liquid Staking', 'CDP', 'Yield',
      'Yield Aggregator', 'Restaking', 'RWA', 'Dexes',
    };
    final protocols = data
        .map((item) => Protocol.fromDefiLlama(item))
        .where((p) => financeCategories.contains(p.category) && p.tvl > 1e6)
        .toList();
    protocols.sort((a, b) => b.tvl.compareTo(a.tvl));
    return protocols;
  }

  /// Fetch yield pools
  Future<List<YieldPool>> fetchYieldPools({String? asset}) async {
    final response = await _client.get(
      ApiEndpoints.yieldPools,
      cacheTtl: const Duration(seconds: 120),
    );
    final List data = response.data['data'] ?? [];
    var pools = data
        .map((item) => YieldPool.fromDefiLlama(item))
        .where((p) => p.tvlUsd > 1e5 && p.apy >= 0.5 && p.apy < 1000)
        .toList();

    if (asset != null && asset != '全部') {
      pools = pools
          .where((p) => p.symbol.toUpperCase().contains(asset.toUpperCase()))
          .toList();
    }

    pools.sort((a, b) => b.tvlUsd.compareTo(a.tvlUsd));
    return pools;
  }

  /// Aggregate yield distribution by category
  Future<List<YieldCategory>> fetchYieldDistribution() async {
    final pools = await fetchYieldPools();

    final categoryMap = <String, List<double>>{};
    for (final pool in pools) {
      String cat;
      final proj = pool.project.toLowerCase();
      if (proj.contains('lido') || proj.contains('staking') || proj.contains('rocket')) {
        cat = '质押';
      } else if (proj.contains('aave') || proj.contains('compound') || proj.contains('lending')) {
        cat = '借贷';
      } else if (proj.contains('uniswap') || proj.contains('curve') || proj.contains('sushi')) {
        cat = 'LP';
      } else if (proj.contains('eigen') || proj.contains('restaking')) {
        cat = '再质押';
      } else {
        cat = '其他';
      }
      categoryMap.putIfAbsent(cat, () => []).add(pool.apy);
    }

    return categoryMap.entries.map((entry) {
      final apys = entry.value..sort();
      return YieldCategory(
        name: entry.key,
        minApy: apys.first,
        medianApy: apys[apys.length ~/ 2],
        maxApy: apys.last > 100 ? 100 : apys.last,
        poolCount: apys.length,
      );
    }).toList();
  }

  /// Fetch all yield pools for a specific project
  Future<List<YieldPool>> fetchPoolsByProject(String projectSlug) async {
    final response = await _client.get(
      ApiEndpoints.yieldPools,
      cacheTtl: const Duration(seconds: 120),
    );
    final List data = response.data['data'] ?? [];
    final pools = data
        .map((item) => YieldPool.fromDefiLlama(item))
        .where((p) =>
            p.project.toLowerCase() == projectSlug.toLowerCase() &&
            p.tvlUsd > 1e4 &&
            p.apy < 1000)
        .toList();
    pools.sort((a, b) => b.tvlUsd.compareTo(a.tvlUsd));
    return pools;
  }

  /// Fetch protocol detail (chain-level TVL breakdown)
  Future<Map<String, double>> fetchProtocolChainTvl(String slug) async {
    try {
      final response = await _client.get(
        ApiEndpoints.protocolDetail(slug),
        cacheTtl: const Duration(seconds: 300),
      );
      final Map<String, dynamic> chainTvls = response.data['chainTvls'] ?? {};
      final result = <String, double>{};
      chainTvls.forEach((chain, data) {
        if (data is Map && data['tvl'] is List) {
          final tvlList = data['tvl'] as List;
          if (tvlList.isNotEmpty) {
            final latest = tvlList.last;
            result[chain] = (latest['totalLiquidityUSD'] as num?)?.toDouble() ?? 0;
          }
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }
}
