import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/error_mapper.dart';

void main() {
  final request = RequestOptions(path: '/x');

  DioException withStatus(int code, [Object? body]) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: request, statusCode: code, data: body),
  );

  test('timeouts become RequestTimeoutException', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      expect(
        mapDioException(DioException(requestOptions: request, type: type)),
        isA<RequestTimeoutException>(),
      );
    }
  });

  test('no connection becomes NetworkException', () {
    expect(
      mapDioException(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      ),
      isA<NetworkException>(),
    );
    expect(
      mapDioException(
        DioException(
          requestOptions: request,
          error: const SocketException('no route'),
        ),
      ),
      isA<NetworkException>(),
    );
  });

  test('status codes map to the right exception', () {
    expect(
      mapDioException(withStatus(400, {'message': 'Invalid credentials'})),
      isA<BadRequestException>().having(
        (e) => e.message,
        'message',
        'Invalid credentials',
      ),
    );
    expect(mapDioException(withStatus(401)), isA<UnauthorizedException>());
    expect(mapDioException(withStatus(403)), isA<UnauthorizedException>());
    expect(mapDioException(withStatus(404)), isA<NotFoundException>());
    expect(
      mapDioException(withStatus(500)),
      isA<ServerException>().having((e) => e.statusCode, 'status', 500),
    );
  });

  test('each exception has a domain failure', () {
    expect(const NetworkException().toFailure(), isA<NetworkFailure>());
    expect(const RequestTimeoutException().toFailure(), isA<TimeoutFailure>());
    expect(const NotFoundException().toFailure(), isA<NotFoundFailure>());
    expect(
      const UnauthorizedException().toFailure(),
      isA<SessionExpiredFailure>(),
    );
    expect(const ParseException().toFailure(), isA<UnexpectedFailure>());
  });
}
