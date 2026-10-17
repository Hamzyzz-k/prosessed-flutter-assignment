import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_palette.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/features/diagnostics/domain/entities/lab_scenario.dart';
import 'package:shopsphere/features/diagnostics/presentation/cubit/error_lab_cubit.dart';

/// Developer screen that triggers each failure from the brief on purpose,
/// so reviewers can watch the error handling in the demo video.
class ErrorLabPage extends StatelessWidget {
  const ErrorLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scenarios = <(LabScenario, IconData, String, String)>[
      (
        LabScenario.serverError,
        Icons.dns_outlined,
        l10n.labServerError,
        l10n.labServerErrorDesc,
      ),
      (
        LabScenario.slowNetwork,
        Icons.slow_motion_video_rounded,
        l10n.labSlow,
        l10n.labSlowDesc,
      ),
      (
        LabScenario.timeout,
        Icons.timer_off_outlined,
        l10n.labTimeout,
        l10n.labTimeoutDesc,
      ),
      (
        LabScenario.expiredAccessToken,
        Icons.autorenew_rounded,
        l10n.labExpiredToken,
        l10n.labExpiredTokenDesc,
      ),
      (
        LabScenario.badRefreshToken,
        Icons.lock_reset_rounded,
        l10n.labBadRefresh,
        l10n.labBadRefreshDesc,
      ),
    ];

    return BlocProvider(
      create: (_) => sl<ErrorLabCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.errorLab)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(Insets.lg),
              children: [
                Text(
                  l10n.labIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Gaps.lg,
                for (final (scenario, icon, title, description) in scenarios)
                  _ScenarioCard(
                    scenario: scenario,
                    icon: icon,
                    title: title,
                    description: description,
                  ),
                _LabCard(
                  icon: Icons.search_off_rounded,
                  title: l10n.labNotFound,
                  description: l10n.labNotFoundDesc,
                  action: FilledButton.tonal(
                    onPressed: () =>
                        unawaited(context.push(Routes.product(9999))),
                    child: Text(l10n.labRun),
                  ),
                ),
                _LabCard(
                  icon: Icons.airplanemode_active_rounded,
                  title: l10n.errorTitleOffline,
                  description: l10n.labOfflineHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.icon,
    required this.title,
    required this.description,
  });

  final LabScenario scenario;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final outcome = context.select<ErrorLabCubit, LabOutcome?>(
      (c) => c.state[scenario],
    );
    final running = outcome is LabRunning;

    final result = switch (outcome) {
      null || LabRunning() => null,
      LabSucceeded(:final elapsed) => (
        Icons.check_circle_rounded,
        context.palette.success,
        l10n.labSuccess(elapsed.inMilliseconds),
      ),
      LabHandled(:final failure) => (
        Icons.shield_outlined,
        theme.colorScheme.primary,
        '${failure.title(l10n)} · ${failure.describe(l10n)}',
      ),
    };

    return _LabCard(
      icon: icon,
      title: title,
      description: description,
      action: FilledButton.tonal(
        onPressed: running
            ? null
            : () => unawaited(context.read<ErrorLabCubit>().run(scenario)),
        child: running
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.labRun),
      ),
      footer: result == null
          ? null
          : Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(result.$1, size: 18, color: result.$2),
                  Gaps.sm,
                  Expanded(
                    child: Text(
                      result.$3,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: result.$2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  Gaps.md,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        Gaps.xs,
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (action != null) ...[Gaps.md, action!],
                ],
              ),
              if (footer != null) ...[Gaps.md, footer!],
            ],
          ),
        ),
      ),
    );
  }
}
