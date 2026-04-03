import 'package:dio/dio.dart';

class CacheEntry {
  final Response response;
  final DateTime expiry;

  CacheEntry(this.response, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class CacheInterceptor extends Interceptor {
  final Map<String, CacheEntry> _cache = {};
  final Duration defaultTtl;

  CacheInterceptor({this.defaultTtl = const Duration(seconds: 120)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = _cacheKey(options);
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      final cachedResponse = Response(
        requestOptions: options,
        data: entry.response.data,
        statusCode: entry.response.statusCode,
        headers: entry.response.headers,
      );
      return handler.resolve(cachedResponse);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _cacheKey(response.requestOptions);

    // Read custom TTL from request extras or use default
    final ttl = response.requestOptions.extra['cacheTtl'] as Duration? ??
        defaultTtl;

    _cache[key] = CacheEntry(response, DateTime.now().add(ttl));
    handler.next(response);
  }

  String _cacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }

  void clearCache() => _cache.clear();
}
