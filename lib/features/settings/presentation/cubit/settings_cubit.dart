import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/settings/domain/entities/app_settings.dart';
import 'package:shopsphere/features/settings/domain/repositories/settings_repository.dart';

/// Theme and language, applied app-wide and remembered between launches.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.load());

  final SettingsRepository _repository;

  Future<void> setTheme(ThemePreference theme) =>
      _save(state.copyWith(theme: theme));

  Future<void> setLanguage(AppLanguage language) =>
      _save(state.copyWith(language: language));

  Future<void> _save(AppSettings settings) async {
    if (settings == state) return;
    emit(settings);
    await _repository.save(settings);
  }
}

/// Domain preferences mapped to Flutter types.
extension AppSettingsX on AppSettings {
  ThemeMode get themeMode => switch (theme) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  Locale get locale => Locale(language.code);
}
