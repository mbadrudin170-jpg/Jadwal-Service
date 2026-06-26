// path lib/fitur/settings/provider/setting_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required int waktuOtomatisSinkronisasi,
    required int waktuOtomatisHapusDataArsip,
    required bool modeMaintenance,
    required String infoMaintenance,
  }) = _SettingsState;
}

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  SettingsOpSqlite get _settingsOpSqlite => ref.read(settingsOpSqliteProvider);

  @override
  FutureOr<SettingsState> build() {
    return _ambilData();
  }

  Future<SettingsState> _ambilData() async {
    final dataSettings = await _settingsOpSqlite.ambilSettings();
    return SettingsState(
      waktuOtomatisSinkronisasi: dataSettings.waktuOtomatisSinkronisasi,
      waktuOtomatisHapusDataArsip: dataSettings.waktuOtomatisHapusDataArsip,
      modeMaintenance: dataSettings.modeMaintenance,
      infoMaintenance: dataSettings.infoMaintenance,
    );
  }

  Future<void> tambahAtauUpdate(SettingsModel settings) async {
    state = await AsyncValue.guard(() async {
      await _settingsOpSqlite.saveOrUpdateSettings(settings);
      return await _ambilData();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
  }
}
