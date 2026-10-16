import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';

/// Runs [body] and converts any thrown [AppException] into an [Err].
///
/// Repositories wrap every data-source call in this so exceptions never
/// escape into the domain or presentation layers.
Future<Result<T>> guard<T>(
  Future<T> Function() body, {
  Failure? Function(AppException exception)? mapException,
}) async {
  try {
    return Ok(await body());
  } on AppException catch (e) {
    return Err(mapException?.call(e) ?? e.toFailure());
  } on Object catch (e) {
    return Err(UnexpectedFailure(e.toString()));
  }
}
