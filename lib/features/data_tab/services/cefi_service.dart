import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/protocol.dart';

class CefiService {
  final _client = DioClient();

  /// Fetch top exchanges from CoinGecko API — real-time data
  Future<List<Protocol>> fetchCefiExchanges() async {
    try {
      // Fetch BTC price first for volume conversion
      final priceResponse = await _client.get(
        ApiEndpoints.simplePrice,
        queryParameters: {'ids': 'bitcoin', 'vs_currencies': 'usd'},
        cacheTtl: const Duration(seconds: 120),
      );
      final btcPrice = (priceResponse.data['bitcoin']?['usd'] as num?)?.toDouble() ?? 67000;

      final response = await _client.get(
        ApiEndpoints.exchanges,
        queryParameters: {'per_page': '15', 'page': '1'},
        cacheTtl: const Duration(seconds: 300),
      );

      final List data = response.data;
      return data.map((item) {
        final name = item['name'] ?? '';
        final tradeVolume24hBtc = (item['trade_volume_24h_btc'] as num?)?.toDouble() ?? 0;
        final volumeUsd = tradeVolume24hBtc * btcPrice;

        return Protocol(
          name: name,
          slug: item['id'] ?? name.toLowerCase(),
          logo: item['image'],
          category: 'CEX',
          tvl: volumeUsd,
          isCefi: true,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
