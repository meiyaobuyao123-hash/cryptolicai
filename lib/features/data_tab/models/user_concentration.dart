/// User-dimension concentration data per platform
class UserConcentration {
  final String platform;
  final int totalUsers;
  final double avgDeposit;         // Average deposit per user
  final double medianDeposit;      // Median deposit
  // Deposit size distribution (% of users)
  final double pctUnder1k;         // <$1K
  final double pct1kTo10k;         // $1K-$10K
  final double pct10kTo100k;       // $10K-$100K
  final double pct100kTo1m;        // $100K-$1M
  final double pctOver1m;          // >$1M
  // TVL concentration by user tier (% of TVL)
  final double tvlPctWhale;        // >$1M users hold X% of TVL
  final double tvlPctMid;          // $10K-$1M users hold X% of TVL
  final double tvlPctRetail;       // <$10K users hold X% of TVL

  UserConcentration({
    required this.platform,
    required this.totalUsers,
    required this.avgDeposit,
    required this.medianDeposit,
    required this.pctUnder1k,
    required this.pct1kTo10k,
    required this.pct10kTo100k,
    required this.pct100kTo1m,
    required this.pctOver1m,
    required this.tvlPctWhale,
    required this.tvlPctMid,
    required this.tvlPctRetail,
  });
}
