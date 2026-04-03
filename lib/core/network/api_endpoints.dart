class ApiEndpoints {
  ApiEndpoints._();

  // DefiLlama
  static const defiLlamaBase = 'https://api.llama.fi';
  static const defiLlamaYields = 'https://yields.llama.fi';

  static const historicalTvl = '$defiLlamaBase/v2/historicalChainTvl';
  static const chains = '$defiLlamaBase/v2/chains';
  static const protocols = '$defiLlamaBase/protocols';
  static const yieldPools = '$defiLlamaYields/pools';
  static String protocolDetail(String slug) => '$defiLlamaBase/protocol/$slug';

  // CoinGecko
  static const coinGeckoBase = 'https://api.coingecko.com/api/v3';

  static const globalData = '$coinGeckoBase/global';
  static const defiGlobal = '$coinGeckoBase/global/decentralized_finance_defi';
  static const simplePrice = '$coinGeckoBase/simple/price';
  static const exchanges = '$coinGeckoBase/exchanges';
}
