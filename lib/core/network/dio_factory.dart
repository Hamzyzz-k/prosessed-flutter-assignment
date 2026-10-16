import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';

/// Builds a [Dio] with the base URL, timeouts and (debug-only) logging.
Dio createDio({List<Interceptor> interceptors = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.addAll(interceptors);
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        // Headers carry the Bearer token: keep them out of the logs.
        requestHeader: false,
        logPrint: (line) => debugPrint(line.toString()),
      ),
    );
  }
  return dio;
}
