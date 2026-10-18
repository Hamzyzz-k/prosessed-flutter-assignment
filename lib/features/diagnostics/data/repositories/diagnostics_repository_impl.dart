import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/diagnostics/domain/entities/lab_scenario.dart';
import 'package:shopsphere/features/diagnostics/domain/repositories/diagnostics_repository.dart';

/// Talks to DummyJSON's test endpoints through the real [ApiClient], so the
/// scenarios exercise exactly the same interceptors and error mapping as
/// the rest of the app.
class DiagnosticsRepositoryImpl implements DiagnosticsRepository {
  const DiagnosticsRepositoryImpl(this._client, this._tokens);

  final ApiClient _client;
  final TokenStorage _tokens;

  // No dots on purpose: DummyJSON answers a malformed JWT ("a.b.c") with a
  // 500, but a plain unknown token with the 401 a real expiry produces.
  static const _expiredAccess = 'expired-access-token';
  static const _invalidRefresh = 'invalid-refresh-token';

  @override
  Future<Result<Duration>> run(LabScenario scenario) {
    return guard(() async {
      final stopwatch = Stopwatch()..start();
      switch (scenario) {
        case LabScenario.serverError:
          await _client.get(ApiEndpoints.httpStatus(500));
        case LabScenario.slowNetwork:
          await _client.get(
            ApiEndpoints.products,
            query: {'limit': 1, 'select': 'id', 'delay': 3000},
          );
        case LabScenario.timeout:
          await _client.get(
            ApiEndpoints.products,
            query: {'limit': 1, 'select': 'id', 'delay': 5000},
            receiveTimeout: const Duration(seconds: 2),
          );
        case LabScenario.expiredAccessToken:
          final refresh = await _tokens.readRefreshToken();
          await _tokens.saveTokens(
            accessToken: _expiredAccess,
            refreshToken: refresh ?? _invalidRefresh,
          );
          await _client.get(ApiEndpoints.me, requiresAuth: true);
        case LabScenario.badRefreshToken:
          await _tokens.saveTokens(
            accessToken: _expiredAccess,
            refreshToken: _invalidRefresh,
          );
          await _client.get(ApiEndpoints.me, requiresAuth: true);
      }
      return stopwatch.elapsed;
    });
  }
}
