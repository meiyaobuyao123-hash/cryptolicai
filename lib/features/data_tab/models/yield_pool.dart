class YieldPool {
  final String pool;
  final String project;
  final String chain;
  final String symbol;
  final double tvlUsd;
  final double apy;
  final double? apyBase;
  final double? apyReward;
  final String? rewardTokens;
  final String riskLevel;
  // New fields for user decision-making
  final double? apyPct7D;        // APY 7-day change
  final double? apyMean30d;      // 30-day mean APY
  final bool isStablecoin;       // Is stablecoin pool
  final String ilRisk;           // Impermanent loss risk: "no", "yes"
  final String exposure;         // "single" or "multi"
  final String? predictedTrend;  // "Stable/Up", "Down", etc.
  final int? predictedConfidence; // 1-3
  final int? addressCount;       // Number of addresses in pool
  final double? sigma;           // APY volatility (standard deviation)

  YieldPool({
    required this.pool,
    required this.project,
    required this.chain,
    required this.symbol,
    required this.tvlUsd,
    required this.apy,
    this.apyBase,
    this.apyReward,
    this.rewardTokens,
    required this.riskLevel,
    this.apyPct7D,
    this.apyMean30d,
    this.isStablecoin = false,
    this.ilRisk = 'no',
    this.exposure = 'single',
    this.predictedTrend,
    this.predictedConfidence,
    this.addressCount,
    this.sigma,
  });

  factory YieldPool.fromDefiLlama(Map<String, dynamic> json) {
    final apy = (json['apy'] as num?)?.toDouble() ?? 0;
    final predictions = json['predictions'] as Map<String, dynamic>?;

    return YieldPool(
      pool: json['pool'] ?? '',
      project: json['project'] ?? '',
      chain: json['chain'] ?? '',
      symbol: json['symbol'] ?? '',
      tvlUsd: (json['tvlUsd'] as num?)?.toDouble() ?? 0,
      apy: apy,
      apyBase: (json['apyBase'] as num?)?.toDouble(),
      apyReward: (json['apyReward'] as num?)?.toDouble(),
      rewardTokens: (json['rewardTokens'] as List?)?.join(', '),
      riskLevel: _calculateRisk(apy),
      apyPct7D: (json['apyPct7D'] as num?)?.toDouble(),
      apyMean30d: (json['apyMean30d'] as num?)?.toDouble(),
      isStablecoin: json['stablecoin'] == true,
      ilRisk: json['ilRisk']?.toString() ?? 'no',
      exposure: json['exposure']?.toString() ?? 'single',
      predictedTrend: predictions?['predictedClass']?.toString(),
      predictedConfidence: (predictions?['binnedConfidence'] as num?)?.toInt(),
      addressCount: (json['count'] as num?)?.toInt(),
      sigma: (json['sigma'] as num?)?.toDouble(),
    );
  }

  static String _calculateRisk(double apy) {
    if (apy <= 8) return '低';
    if (apy <= 20) return '中';
    return '高';
  }

  /// Human-readable exposure type
  String get exposureLabel => exposure == 'single' ? '单币' : 'LP';

  /// APY stability indicator
  String get stabilityLabel {
    if (sigma == null) return '';
    if (sigma! < 0.01) return '极稳定';
    if (sigma! < 0.05) return '稳定';
    if (sigma! < 0.2) return '波动';
    return '高波动';
  }

  /// Trend arrow
  String get trendIcon {
    if (predictedTrend == null) return '';
    if (predictedTrend!.contains('Up')) return '↗';
    if (predictedTrend!.contains('Down')) return '↘';
    return '→';
  }

  /// Whether APY is mostly from rewards (unsustainable)
  bool get isRewardHeavy {
    if (apyBase == null || apyReward == null) return false;
    return apyReward! > apyBase! * 2;
  }
}

class YieldCategory {
  final String name;
  final double minApy;
  final double medianApy;
  final double maxApy;
  final int poolCount;

  YieldCategory({
    required this.name,
    required this.minApy,
    required this.medianApy,
    required this.maxApy,
    required this.poolCount,
  });
}
