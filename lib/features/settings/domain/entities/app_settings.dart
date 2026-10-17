import 'package:equatable/equatable.dart';

enum ThemePreference { system, light, dark }

/// Language codes the app ships translations for.
enum AppLanguage {
  english('en'),
  hindi('hi');

  AppLanguage(this.code);

  final String code;

  static AppLanguage fromCode(String? code) =>
      values.firstWhere((l) => l.code == code, orElse: () => english);
}

class AppSettings extends Equatable {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.language = AppLanguage.english,
  });

  final ThemePreference theme;
  final AppLanguage language;

  AppSettings copyWith({ThemePreference? theme, AppLanguage? language}) =>
      AppSettings(
        theme: theme ?? this.theme,
        language: language ?? this.language,
      );

  @override
  List<Object?> get props => [theme, language];
}
