import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';

/// Turns a low-level [DioException] into one of our [AppException]s.
///
/// This is the only place in the app that knows about HTTP status codes.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return RequestTimeoutException(e.message);
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkException(e.message);
    case DioExceptionType.cancel:
      return NetworkException(e.message ?? 'Request cancelled');
    case DioExceptionType.badResponse:
      return _fromStatus(e.response?.statusCode, _serverMessage(e.response));
    case DioExceptionType.unknown:
      if (e.error is SocketException || e.error is HttpException) {
        return NetworkException(e.message);
      }
      return ServerException(message: e.message);
  }
}

AppException _fromStatus(int? status, String? message) {
  return switch (status) {
    400 => BadRequestException(message),
    401 || 403 => UnauthorizedException(message),
    404 => NotFoundException(message),
    _ => ServerException(statusCode: status, message: message),
  };
}

/// DummyJSON puts a human-readable reason in `{"message": "..."}`.
String? _serverMessage(Response<dynamic>? response) {
  final data = response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return response?.statusMessage;
}
