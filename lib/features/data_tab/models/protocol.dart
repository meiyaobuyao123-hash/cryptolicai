class Protocol {
  final String name;
  final String slug;
  final String? logo;
  final String category;
  final String? chain;
  final double tvl;
  final double? change7d;
  final bool isCefi;

  Protocol({
    required this.name,
    required this.slug,
    this.logo,
    required this.category,
    this.chain,
    required this.tvl,
    this.change7d,
    this.isCefi = false,
  });

  factory Protocol.fromDefiLlama(Map<String, dynamic> json) {
    return Protocol(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      logo: json['logo'],
      category: json['category'] ?? 'Other',
      chain: json['chain'],
      tvl: (json['tvl'] as num?)?.toDouble() ?? 0,
      change7d: (json['change_7d'] as num?)?.toDouble(),
    );
  }
}

// Category mapping for Chinese display
String protocolCategoryLabel(String category) {
  const map = {
    'Lending': '借贷',
    'Liquid Staking': '流动性质押',
    'Dexes': 'DEX',
    'CDP': 'CDP',
    'Bridge': '跨链桥',
    'Yield': '收益',
    'Restaking': '再质押',
    'Yield Aggregator': '收益聚合',
    'RWA': 'RWA',
    'Derivatives': '衍生品',
    'CEX': '交易所',
  };
  return map[category] ?? category;
}
