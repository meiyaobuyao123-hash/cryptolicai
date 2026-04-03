class PlatformTvlApy {
  final String project;
  final double totalTvl;
  final int poolCount;
  final double minApy;
  final double maxApy;
  final double weightedAvgApy;
  // Concentration metrics
  final double top3TvlPct;       // Top 3 pools hold X% of TVL
  final double lowApyTvlPct;     // % of TVL earning <5% APY
  final double midApyTvlPct;     // % of TVL earning 5-15% APY
  final double highApyTvlPct;    // % of TVL earning >15% APY
  final String topAsset;         // Largest asset by TVL
  final double topAssetPct;      // Top asset % of total TVL
  final double hhi;              // Herfindahl index (0-1, higher = more concentrated)

  PlatformTvlApy({
    required this.project,
    required this.totalTvl,
    required this.poolCount,
    required this.minApy,
    required this.maxApy,
    required this.weightedAvgApy,
    required this.top3TvlPct,
    required this.lowApyTvlPct,
    required this.midApyTvlPct,
    required this.highApyTvlPct,
    required this.topAsset,
    required this.topAssetPct,
    required this.hhi,
  });

  String get concentrationLevel {
    if (hhi > 0.5) return '高';
    if (hhi > 0.25) return '中';
    return '低';
  }
}
