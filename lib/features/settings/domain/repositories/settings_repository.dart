import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  AppSettings load();
  Future<Result<void>> save(AppSettings settings);
}
