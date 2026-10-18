import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/session/session_events.dart';

import '../../helpers/helpers.dart';

/// Answers requests from a function instead of the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final (int, Map<String, dynamic>) Function(RequestOptions options) handler;
  final calls = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add('${options.method} ${options.path}');
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late InMemoryTokenStorage tokens;
  late SessionEvents events;

  setUp(() {
    tokens = InMemoryTokenStorage()
      ..access = 'old-access'
      ..refresh = 'good-refresh';
    events = SessionEvents();
  });

  ApiClient clientWith(_FakeAdapter adapter) {
    final refreshDio = Dio(BaseOptions(baseUrl: 'https://test'))
      ..httpClientAdapter = adapter;
    final dio = Dio(BaseOptions(baseUrl: 'https://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(tokens, events, refreshDio));
    return ApiClient(dio);
  }

  test('attaches the Bearer token to protected requests only', () async {
    final seen = <String, Object?>{};
    final adapter = _FakeAdapter((o) {
      seen[o.path] = o.headers['Authorization'];
      return (200, {'ok': true});
    });
    final client = clientWith(adapter);

    await client.get('/auth/me', requiresAuth: true);
    await client.get('/products');

    expect(seen['/auth/me'], 'Bearer old-access');
    expect(seen['/products'], isNull);
  });

  test('on 401 it refreshes the token and retries the request', () async {
    final adapter = _FakeAdapter((o) {
      if (o.path == '/auth/refresh') {
        return (200, {'accessToken': 'new-access', 'refreshToken': 'new-r'});
      }
      final ok = o.headers['Authorization'] == 'Bearer new-access';
      return ok ? (200, {'id': 1}) : (401, {'message': 'Expired'});
    });

    final json = await clientWith(adapter).get('/auth/me', requiresAuth: true);

    expect(json['id'], 1);
    expect(tokens.access, 'new-access');
    expect(adapter.calls, [
      'GET /auth/me',
      'POST /auth/refresh',
      'GET /auth/me',
    ]);
  });

  test('a rejected refresh token (403) ends the session', () async {
    final adapter = _FakeAdapter(
      (o) => o.path == '/auth/refresh'
          ? (403, {'message': 'Invalid refresh token'})
          : (401, {'message': 'Expired'}),
    );
    var expired = false;
    events.onExpired.listen((_) => expired = true);

    await expectLater(
      clientWith(adapter).get('/auth/me', requiresAuth: true),
      throwsA(isA<UnauthorizedException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(expired, isTrue);
    expect(tokens.access, isNull);
  });

  test('a 401 on a public request is not refreshed', () async {
    final adapter = _FakeAdapter((_) => (401, {'message': 'nope'}));

    await expectLater(
      clientWith(adapter).get('/products'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(adapter.calls, ['GET /products']);
  });
}
