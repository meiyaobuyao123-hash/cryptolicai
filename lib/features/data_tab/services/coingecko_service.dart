import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class CoinGeckoService {
  final _client = DioClient();

  Future<Map<String, dynamic>> fetchGlobalData() async {
    try {
      final response = await _client.get(
        ApiEndpoints.globalData,
        cacheTtl: const Duration(seconds: 120),
      );
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchDefiGlobal() async {
    try {
      final response = await _client.get(
        ApiEndpoints.defiGlobal,
        cacheTtl: const Duration(seconds: 120),
      );
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchPrices() async {
    try {
      final response = await _client.get(
        ApiEndpoints.simplePrice,
        queryParameters: {
          'ids': 'bitcoin,ethereum',
          'vs_currencies': 'usd',
          'include_24hr_change': 'true',
        },
        cacheTtl: const Duration(seconds: 60),
      );
      return response.data;
    } catch (_) {
      return {};
    }
  }
}
