import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/diagnostics/domain/entities/lab_scenario.dart';

abstract interface class DiagnosticsRepository {
  /// Runs [scenario] and returns how long it took.
  Future<Result<Duration>> run(LabScenario scenario);
}
