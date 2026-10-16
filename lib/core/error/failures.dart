import 'package:equatable/equatable.dart';

/// A problem the domain layer understands.
///
/// Repositories return these (never throw them) so every caller is forced by
/// the compiler to handle each case. The UI turns them into friendly text.
sealed class Failure extends Equatable {
  const Failure([this.message]);

  /// Optional server message, useful for logs and debugging only.
  final String? message;

  @override
  List<Object?> get props => [message];
}

/// No connection, DNS failure, socket closed...
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

/// The server took too long to answer.
final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message]);
}

/// 5xx (or an unexpected status code) from the server.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, String? message}) : super(message);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, message];
}

/// The requested resource does not exist (404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message]);
}

/// Login was rejected (DummyJSON answers 400 "Invalid credentials").
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message]);
}

/// The session can no longer be used and could not be refreshed.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message]);
}

/// Anything else: malformed JSON, local storage errors, programming errors.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message]);
}
