import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/diagnostics/domain/entities/lab_scenario.dart';
import 'package:shopsphere/features/diagnostics/domain/repositories/diagnostics_repository.dart';

sealed class LabOutcome extends Equatable {
  const LabOutcome();

  @override
  List<Object?> get props => [];
}

final class LabRunning extends LabOutcome {
  const LabRunning();
}

final class LabSucceeded extends LabOutcome {
  const LabSucceeded(this.elapsed);

  final Duration elapsed;

  @override
  List<Object?> get props => [elapsed];
}

/// The scenario failed and the app turned it into this [failure].
final class LabHandled extends LabOutcome {
  const LabHandled(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ErrorLabCubit extends Cubit<Map<LabScenario, LabOutcome>> {
  ErrorLabCubit(this._repository) : super(const {});

  final DiagnosticsRepository _repository;

  Future<void> run(LabScenario scenario) async {
    if (state[scenario] is LabRunning) return;
    emit({...state, scenario: const LabRunning()});
    final result = await _repository.run(scenario);
    if (isClosed) return;
    emit({
      ...state,
      scenario: switch (result) {
        Ok(:final value) => LabSucceeded(value),
        Err(:final failure) => LabHandled(failure),
      },
    });
  }
}
