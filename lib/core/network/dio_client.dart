import 'package:dio/dio.dart';
import 'cache_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  late final CacheInterceptor cacheInterceptor;

  DioClient._internal() {
    cacheInterceptor = CacheInterceptor();

    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    dio.interceptors.add(cacheInterceptor);
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Duration? cacheTtl,
  }) {
    return dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(
        extra: {
          if (cacheTtl != null) 'cacheTtl': cacheTtl,
        },
      ),
    );
  }
}
