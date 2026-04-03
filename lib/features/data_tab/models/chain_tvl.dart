class ChainTvl {
  final String name;
  final double tvl;
  final String? tokenSymbol;
  final String? geckoId;
  double? marketCap; // Filled from CoinGecko

  ChainTvl({
    required this.name,
    required this.tvl,
    this.tokenSymbol,
    this.geckoId,
    this.marketCap,
  });

  factory ChainTvl.fromJson(Map<String, dynamic> json) {
    return ChainTvl(
      name: json['name'] ?? '',
      tvl: (json['tvl'] as num?)?.toDouble() ?? 0,
      tokenSymbol: json['tokenSymbol'],
      geckoId: json['gecko_id'],
    );
  }
}
