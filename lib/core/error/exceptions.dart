import 'package:shopsphere/core/error/failures.dart';

/// Errors thrown inside the data layer (data sources).
///
/// They never leave a repository: `guard` converts them into [Failure]s.
sealed class AppException implements Exception {
  const AppException([this.message]);

  final String? message;

  /// The domain-level equivalent of this exception.
  Failure toFailure();

  @override
  String toString() => 'AppException: ${message ?? 'no message'}';
}

final class NetworkException extends AppException {
  const NetworkException([super.message]);

  @override
  Failure toFailure() => NetworkFailure(message);
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message]);

  @override
  Failure toFailure() => TimeoutFailure(message);
}

final class ServerException extends AppException {
  const ServerException({this.statusCode, String? message}) : super(message);

  final int? statusCode;

  @override
  Failure toFailure() =>
      ServerFailure(statusCode: statusCode, message: message);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message]);

  @override
  Failure toFailure() => NotFoundFailure(message);
}

/// 401 / 403: the token is missing, invalid or expired.
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message]);

  @override
  Failure toFailure() => SessionExpiredFailure(message);
}

/// 400: the request was understood but rejected (e.g. wrong password).
final class BadRequestException extends AppException {
  const BadRequestException([super.message]);

  @override
  Failure toFailure() => UnexpectedFailure(message);
}

/// The response body did not have the shape we expected.
final class ParseException extends AppException {
  const ParseException([super.message]);

  @override
  Failure toFailure() => UnexpectedFailure(message);
}

/// Reading or writing local storage failed.
final class CacheException extends AppException {
  const CacheException([super.message]);

  @override
  Failure toFailure() => UnexpectedFailure(message);
}
