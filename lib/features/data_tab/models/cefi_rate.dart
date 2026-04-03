class CefiRate {
  final String exchange;
  final String asset;
  final double flexibleApy;
  final double? lockedApy;
  final String? lockPeriod;
  final String productType;

  CefiRate({
    required this.exchange,
    required this.asset,
    required this.flexibleApy,
    this.lockedApy,
    this.lockPeriod,
    required this.productType,
  });

  factory CefiRate.fromJson(Map<String, dynamic> json) {
    return CefiRate(
      exchange: json['exchange'] ?? '',
      asset: json['asset'] ?? '',
      flexibleApy: (json['flexibleApy'] as num?)?.toDouble() ?? 0,
      lockedApy: (json['lockedApy'] as num?)?.toDouble(),
      lockPeriod: json['lockPeriod'],
      productType: json['productType'] ?? 'Savings',
    );
  }
}

class CefiPlatform {
  final String name;
  final double totalAssets;
  final String category;
  final List<CefiRate> rates;

  CefiPlatform({
    required this.name,
    required this.totalAssets,
    required this.category,
    required this.rates,
  });
}
