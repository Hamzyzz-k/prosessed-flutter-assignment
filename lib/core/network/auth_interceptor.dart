import 'package:dio/dio.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/session/session_events.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

/// Adds the Bearer token to protected requests and renews it when it expires.
///
/// It is a [QueuedInterceptor], so if several requests fail with 401 at the
/// same time they wait in line: the first one refreshes the token and the
/// rest simply retry with the new one.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokens, this._sessionEvents, this._refreshClient);

  final TokenStorage _tokens;
  final SessionEvents _sessionEvents;

  /// A separate client without this interceptor, used for the refresh call
  /// and the retry, so a failing refresh can never loop back in here.
  final Dio _refreshClient;

  static const _retriedKey = 'authRetried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_requiresAuth(options)) {
      final token = await _tokens.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isUnauthorised = err.response?.statusCode == 401;
    if (!isUnauthorised ||
        !_requiresAuth(request) ||
        request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    // Another queued request may already have refreshed the token.
    final current = await _tokens.readAccessToken();
    final usedHeader = request.headers['Authorization'];
    if (current != null && usedHeader != 'Bearer $current') {
      return await _retry(request, current, handler);
    }

    switch (await _refreshToken()) {
      case _Refreshed(:final accessToken):
        return await _retry(request, accessToken, handler);
      case _RefreshFailed(:final error):
        // Offline, timeout or server trouble: keep the session and report
        // that error instead; the user can simply try again.
        return handler.next(error);
      case _SessionOver():
        await _tokens.clear();
        _sessionEvents.notifyExpired();
        return handler.next(err);
    }
  }

  Future<_RefreshOutcome> _refreshToken() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return const _SessionOver();
    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': ApiEndpoints.tokenLifetimeMinutes,
        },
      );
      final data = response.data;
      final access = data?['accessToken'];
      final refresh = data?['refreshToken'];
      if (access is! String || refresh is! String) return const _SessionOver();
      await _tokens.saveTokens(accessToken: access, refreshToken: refresh);
      return _Refreshed(access);
    } on DioException catch (e) {
      // Only 401/403 prove the refresh token is invalid (DummyJSON answers
      // 403 "Invalid refresh token"). Anything else may be temporary.
      final status = e.response?.statusCode;
      return status == 401 || status == 403
          ? const _SessionOver()
          : _RefreshFailed(e);
    }
  }

  Future<void> _retry(
    RequestOptions request,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    request
      ..headers['Authorization'] = 'Bearer $token'
      ..extra[_retriedKey] = true;
    try {
      handler.resolve(await _refreshClient.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _requiresAuth(RequestOptions options) =>
      options.extra[requiresAuthKey] == true;
}

sealed class _RefreshOutcome {
  const _RefreshOutcome();
}

final class _Refreshed extends _RefreshOutcome {
  const _Refreshed(this.accessToken);

  final String accessToken;
}

final class _RefreshFailed extends _RefreshOutcome {
  const _RefreshFailed(this.error);

  final DioException error;
}

final class _SessionOver extends _RefreshOutcome {
  const _SessionOver();
}
