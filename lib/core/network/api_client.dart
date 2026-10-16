import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/error_mapper.dart';

/// `RequestOptions.extra` key that marks a request as needing a Bearer token.
const requiresAuthKey = 'requiresAuth';

/// Thin wrapper around [Dio] used by every remote data source.
///
/// It hides Dio from the rest of the data layer and guarantees that callers
/// only ever see [AppException]s, never [DioException]s.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool requiresAuth = false,
    Duration? receiveTimeout,
  }) {
    return _send(
      () => _dio.get<dynamic>(
        path,
        queryParameters: query,
        options: Options(
          extra: {requiresAuthKey: requiresAuth},
          receiveTimeout: receiveTimeout,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    bool requiresAuth = false,
  }) {
    return _send(
      () => _dio.post<dynamic>(
        path,
        data: body,
        options: Options(extra: {requiresAuthKey: requiresAuth}),
      ),
    );
  }

  /// Like [get] but for endpoints that return a bare JSON array.
  Future<List<dynamic>> getList(String path) async {
    final response = await _request(() => _dio.get<dynamic>(path));
    final data = response.data;
    if (data is List) return data;
    throw const ParseException('Expected a JSON array');
  }

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() call,
  ) async {
    final response = await _request(call);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw const ParseException('Expected a JSON object');
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

/// Parses [json] with [fromJson], turning any shape error into a
/// [ParseException] instead of a crash.
T parseJson<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  try {
    return fromJson(json);
  } on Object catch (e) {
    throw ParseException(e.toString());
  }
}
