class MarketOverview {
  final double totalDefiTvl;
  final double defiTvlChange24h;
  final double totalMarketCap;
  final double marketCapChange24h;
  final double defiDominance;
  final double stablecoinMarketCap;
  final DateTime updatedAt;

  MarketOverview({
    required this.totalDefiTvl,
    required this.defiTvlChange24h,
    required this.totalMarketCap,
    required this.marketCapChange24h,
    required this.defiDominance,
    required this.stablecoinMarketCap,
    required this.updatedAt,
  });
}

class TvlDataPoint {
  final DateTime date;
  final double tvl;

  TvlDataPoint({required this.date, required this.tvl});
}
