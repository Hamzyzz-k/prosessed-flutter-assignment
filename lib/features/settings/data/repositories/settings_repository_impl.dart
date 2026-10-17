import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/features/settings/domain/entities/app_settings.dart';
import 'package:shopsphere/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._store);

  final KeyValueStore _store;

  static const _themeKey = 'settings.theme';
  static const _languageKey = 'settings.language';

  @override
  AppSettings load() {
    final theme = ThemePreference.values.firstWhere(
      (t) => t.name == _store.getString(_themeKey),
      orElse: () => ThemePreference.system,
    );
    return AppSettings(
      theme: theme,
      language: AppLanguage.fromCode(_store.getString(_languageKey)),
    );
  }

  @override
  Future<Result<void>> save(AppSettings settings) {
    return guard(() async {
      await _store.setString(_themeKey, settings.theme.name);
      await _store.setString(_languageKey, settings.language.code);
    });
  }
}
