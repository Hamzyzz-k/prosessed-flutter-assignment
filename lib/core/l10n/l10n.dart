import 'package:flutter/widgets.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/l10n/generated/app_localizations.dart';

export 'package:shopsphere/core/l10n/generated/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Turns a domain [Failure] into words a shopper understands.
extension FailureMessageX on Failure {
  String title(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorTitleOffline,
    TimeoutFailure() => l10n.errorTitleTimeout,
    ServerFailure() => l10n.errorTitleServer,
    NotFoundFailure() => l10n.errorTitleNotFound,
    InvalidCredentialsFailure() ||
    SessionExpiredFailure() ||
    UnexpectedFailure() => l10n.errorTitleGeneric,
  };

  String describe(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    ServerFailure() => l10n.errorServer,
    NotFoundFailure() => l10n.errorNotFound,
    InvalidCredentialsFailure() => l10n.errorInvalidCredentials,
    SessionExpiredFailure() => l10n.errorSessionExpired,
    UnexpectedFailure() => l10n.errorUnexpected,
  };
}
