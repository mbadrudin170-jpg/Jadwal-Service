# Dokumentasi Fitur: settings

## Daftar file

- [lib/fitur/settings/model/settings_model.dart](lib/fitur/settings/model/settings_model.dart)
- [lib/fitur/settings/operasi/settings_op_firebase.dart](lib/fitur/settings/operasi/settings_op_firebase.dart)
- [lib/fitur/settings/operasi/settings_op_sqlite.dart](lib/fitur/settings/operasi/settings_op_sqlite.dart)
- [lib/fitur/settings/page/form_settings.dart](lib/fitur/settings/page/form_settings.dart)
- [lib/fitur/settings/page/settings_page_a.dart](lib/fitur/settings/page/settings_page_a.dart)
- [lib/fitur/settings/page/settings_page_u.dart](lib/fitur/settings/page/settings_page_u.dart)
- [lib/fitur/settings/provider/settings_provider.dart](lib/fitur/settings/provider/settings_provider.dart)

## Isi file

### File: `lib/fitur/settings/model/settings_model.dart`
```dart
// path: lib/fitur/settings/model/settings_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'settings_model.freezed.dart';

const String idGlobalSetting = 'global_config';

@freezed
abstract class SettingsModel with _$SettingsModel implements HasId {
  const SettingsModel._();
  const factory SettingsModel({
    @Default(idGlobalSetting) String id,
    @Default(24) int waktuOtomatisSinkronisasi,
    @Default(30) int waktuOtomatisHapusDataArsip,
    @Default(false) bool modeMaintenance,
    @Default('') String infoMaintenance,
    DateTime? diperbaruiPada,
  }) = _SettingModel;

  factory SettingsModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      id: map[NamaKolom.id] as String? ?? idGlobalSetting,
      waktuOtomatisSinkronisasi:
          map[NamaKolom.waktuOtomatisSinkronisasi] as int? ?? 24,
      waktuOtomatisHapusDataArsip:
          map[NamaKolom.waktuOtomatisHapusDataArsip] as int? ?? 30,
      modeMaintenance: ParserUtil.parseBool(map[NamaKolom.modeMaintenance]),
      infoMaintenance: map[NamaKolom.infoMaintenance] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.waktuOtomatisSinkronisasi: waktuOtomatisSinkronisasi,
      NamaKolom.waktuOtomatisHapusDataArsip: waktuOtomatisHapusDataArsip,
      NamaKolom.modeMaintenance: modeMaintenance ? 1 : 0,
      NamaKolom.infoMaintenance: infoMaintenance,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  factory SettingsModel.fromFirebase(Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[NamaKolom.id] as String? ?? idGlobalSetting,
      waktuOtomatisSinkronisasi:
          data[NamaKolom.waktuOtomatisSinkronisasi] as int? ?? 24,
      waktuOtomatisHapusDataArsip:
          data[NamaKolom.waktuOtomatisHapusDataArsip] as int? ?? 30,
      modeMaintenance: ParserUtil.parseBool(data[NamaKolom.modeMaintenance]),
      infoMaintenance: data[NamaKolom.infoMaintenance] as String? ?? '',
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.waktuOtomatisSinkronisasi: waktuOtomatisSinkronisasi,
      NamaKolom.waktuOtomatisHapusDataArsip: waktuOtomatisHapusDataArsip,
      NamaKolom.modeMaintenance: modeMaintenance,
      NamaKolom.infoMaintenance: infoMaintenance,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        diperbaruiPada ?? DateTime.now(),
      ),
    };
  }
}
```

### File: `lib/fitur/settings/operasi/settings_op_firebase.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class SettingsOpFirebase {
  final FirebaseFirestore _db;

  SettingsOpFirebase({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance {
    Log.info('SettingsOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksi => _db.collection(NamaTabel.settings);

  Future<Map<String, dynamic>> ambilPengaturan() async {
    try {
      final doc = await _koleksi.doc(idGlobalSetting).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        Log.info('Pengaturan dari Firestore berhasil diambil.', data);
        return data ?? {};
      }
      Log.warning('Dokumen pengaturan tidak ditemukan, pakai default.');
      return {
        NamaKolom.modeMaintenance: false,
        NamaKolom.infoMaintenance:
            'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
      };
    } on Exception catch (e, s) {
      Log.error('Error mengambil pengaturan.', e: e, s: s);
      return {
        NamaKolom.modeMaintenance: false,
        NamaKolom.infoMaintenance:
            'Gagal memuat pengaturan. Menggunakan default.',
      };
    }
  }
}
```

### File: `lib/fitur/settings/operasi/settings_op_sqlite.dart`
```dart
// path: lib/fitur/settings/operasi/settings_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class SettingsOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;

  /// Konstruktor untuk [SettingsOpSqlite].
  ///
  /// Memungkinkan injeksi dependensi untuk [sqliteDb] dan [_baseOpSqlite] guna memfasilitasi pengujian.
  SettingsOpSqlite({
    required this.sqliteDb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite;

  final String _namaTabel = NamaTabel.settings;

  /// Mengambil data pengaturan dari database.
  /// Jika tidak ada, akan membuat pengaturan default.
  Future<SettingsModel> ambilSettings() async {
    try {
      Log.info(
        'Memulai proses pengambilan data pengaturan dari database - method: getSettings, tabel: ${NamaTabel.settings}',
        'Memulai proses pengambilan data pengaturan dari database - method: ambilPengaturan, tabel: ${NamaTabel.settings}',
      );
      final db = await sqliteDb.database;

      final hasil = await db.query(
        _namaTabel,
        where: 'id = ?',
        whereArgs: [idGlobalSetting],
      );

      if (hasil.isNotEmpty) {
        Log.info('Data pengaturan berhasil ditemukan di database.');
        return SettingsModel.fromSqlite(hasil.first);
      } else {
        Log.warning(
          'Tidak ditemukan data pengaturan, membuat pengaturan default.',
        );
        final defaultSettings = SettingsModel(diperbaruiPada: DateTime.now());
        await simpanAtauPerbaruiSettings(defaultSettings);
        Log.info('Pengaturan default berhasil dibuat dan disimpan.');
        return defaultSettings;
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil data pengaturan: $e', e: e, s: st);
      Log.warning('Mengembalikan SettingsModel default sebagai fallback.');
      return const SettingsModel();
    }
  }

  /// Menyimpan atau memperbarui [SettingsModel] di database.
  Future<void> simpanAtauPerbaruiSettings(
    final SettingsModel settings, {
    final bool dariServer = false,
  }) async {
    try {
      final settingsToSave = settings.copyWith(
        id: idGlobalSetting,
        diperbaruiPada: DateTime.now(),
      );

      Log.info(
        'Memulai proses simpan/perbarui untuk pengaturan dengan ID: ${settingsToSave.id}',
      );
      await _baseOpSqlite.sisipkan(
        _namaTabel,
        settingsToSave.toSqlite(),
        dariServer: dariServer,
      );
      Log.info(
        'Pengaturan berhasil disimpan atau diperbarui dengan metode UPSERT.',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menyimpan atau memperbarui data pengaturan: $e',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui sebagian field dari [SettingsModel] di database.
  ///
  /// [data] adalah Map yang berisi field yang akan diperbarui.
  Future<void> perbaruiSettings(
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info(
        'Memulai proses update parsial untuk pengaturan dengan ID: $idGlobalSetting',
      );

      final dataToUpdate = {
        ...data,
        NamaKolom.diperbaruiPada: DateTime.now().millisecondsSinceEpoch,
      };

      await _baseOpSqlite.update(
        _namaTabel,
        dataToUpdate,
        idGlobalSetting,
        dariServer: dariServer,
      );

      Log.info(
        'Pengaturan berhasil diperbarui sebagian. Fields: ${data.keys.join(', ')}',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal memperbarui data pengaturan sebagian: $e', e: e, s: st);
      rethrow;
    }
  }

  /// Menyimpan atau memperbarui [SettingsModel] di database menggunakan batch.
  Future<void> simpanAtauPerbaruiSettingsDenganBatch(
    final SettingsModel settings, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info('Memulai penyimpanan pengaturan dengan batch operation.');
      final data = settings
          .copyWith(id: idGlobalSetting, diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(_namaTabel, [
        data,
      ], dariServer: dariServer);
      Log.info('Batch operation untuk pengaturan berhasil.');
    } catch (e, st) {
      Log.error('Gagal menyimpan pengaturan dengan batch: $e', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/settings/page/form_settings.dart`
```dart
// path: lib/fitur/settings/page/form_settings.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/provider/settings_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormSettings extends ConsumerStatefulWidget {
  const FormSettings({super.key});

  @override
  ConsumerState<FormSettings> createState() => _FormSettingsState();
}

class _FormSettingsState extends ConsumerState<FormSettings> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _intervalController;
  late TextEditingController _hapusArsipController;
  late TextEditingController _infoPemeliharaanController;
  late bool _modePemeliharaan;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).value;
    _intervalController = TextEditingController(
      text: '${settings?.waktuOtomatisSinkronisasi ?? 24}',
    );
    _hapusArsipController = TextEditingController(
      text: '${settings?.waktuOtomatisHapusDataArsip ?? 30}',
    );
    _infoPemeliharaanController = TextEditingController(
      text: settings?.infoMaintenance ?? '',
    );
    _modePemeliharaan = settings?.modeMaintenance ?? false;
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _hapusArsipController.dispose();
    _infoPemeliharaanController.dispose();
    Log.info('Membersihkan controller pada SettingsForm.');
    super.dispose();
  }

  Future<void> _simpanSettings() async {
    setState(() {
      _menyimpan = true;
    });
    if (_formKey.currentState!.validate()) {
      Log.info('Memvalidasi dan menyimpan perubahan pengaturan.');
      try {
        final newSettings = SettingsModel(
          waktuOtomatisSinkronisasi:
              int.tryParse(_intervalController.text) ?? 24,
          waktuOtomatisHapusDataArsip:
              int.tryParse(_hapusArsipController.text) ?? 30,
          modeMaintenance: _modePemeliharaan,
          infoMaintenance: _infoPemeliharaanController.text,
        );
        await ref.read(settingsProvider.notifier).tambahAtauUpdate(newSettings);
        Log.info('Pengaturan berhasil diperbarui di database.');
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (mounted) {
          ToastUtil.success(
            context,
            'Pengaturan berhasil disimpan dan disinkronkan.',
          );
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } on Exception catch (e, st) {
        Log.error('Gagal menyimpan pengaturan.', e: e, s: st);
        if (mounted) {
          ToastUtil.error(context, 'Gagal menyimpan pengaturan: $e');
        }
      } finally {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(
                controller: _intervalController,
                label: 'Interval Sinkronisasi Otomatis (Jam)',
                icon: Icons.sync,
                keyboardType: TextInputType.number,
                validator: (final value) => (value == null || value.isEmpty)
                    ? 'Harap masukkan interval'
                    : null,
              ),
              gapH16,
              _buildTextFormField(
                controller: _hapusArsipController,
                label: 'Hapus Arsip Otomatis (Hari)',
                icon: Icons.auto_delete,
                keyboardType: TextInputType.number,
                validator: (final value) => (value == null || value.isEmpty)
                    ? 'Harap masukkan hari'
                    : null,
              ),
              gapH16,
              _buildSwitchTile(),
              gapH16,
              if (_modePemeliharaan)
                _buildTextFormField(
                  controller: _infoPemeliharaanController,
                  label: 'Info Mode Pemeliharaan',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
              gapH32,
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpanSettings,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _menyimpan
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required final TextEditingController controller,
    required final String label,
    required final IconData icon,
    final TextInputType keyboardType = TextInputType.text,
    final String? Function(String?)? validator,
    final int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildSwitchTile() {
    return SwitchListTile(
      title: const Text('Mode Pemeliharaan'),
      value: _modePemeliharaan,
      onChanged: (value) {
        setState(() {
          _modePemeliharaan = value;
          Log.info('Mode pemeliharaan diubah menjadi: $value');
        });
      },
      secondary: const Icon(Icons.construction),
    );
  }
}
```

### File: `lib/fitur/settings/page/settings_page_a.dart`
```dart
// path: lib/fitur/settings/page/settings_page_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/settings/page/form_settings.dart';
import 'package:wifi/fitur/settings/provider/settings_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

class SettingsAdminPage extends ConsumerWidget {
  const SettingsAdminPage({super.key});

  Future<void> _resetWaktuSinkroniasi(
    BuildContext context,
    WidgetRef ref,
  ) async {
    Log.info('Tombol Reset Waktu Sinkronisasi ditekan.');
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Reset'),
        content: const Text(
          'Anda yakin ingin mereset waktu sinkronisasi? Tindakan ini akan memaksa aplikasi untuk mengunggah semua data yang dimodifikasi dan mengunduh semua data dari server pada siklus sinkronisasi berikutnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if ((konfirmasi == true) && context.mounted) {
      try {
        await ref
            .read(pengelolaSinkronisasiProvider)
            .resetWaktuSinkronisasiPreferensi();
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (context.mounted) {
          ToastUtil.success(context, 'Waktu sinkronisasi berhasil di-reset.');
        }
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, s: st);
        if (context.mounted) {
          ToastUtil.error(context, 'Gagal mereset waktu sinkronisasi: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final tema = ref.watch(temaProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Aplikasi')),
      body: settingsAsync.when(
        skipLoadingOnReload: true,
        data: (settings) {
          Log.info('Data pengaturan tersedia, menampilkan detail.');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard(
                        judul: 'Sinkronisasi Otomatis',
                        nilai: '${settings.waktuOtomatisSinkronisasi} Jam',
                        ikon: Icons.sync,
                        context: context,
                      ),
                      gapH12,
                      _buildInfoCard(
                        judul: 'Hapus Arsip Otomatis',
                        nilai: '${settings.waktuOtomatisHapusDataArsip} Hari',
                        ikon: Icons.auto_delete_outlined,
                        context: context,
                      ),
                      const Divider(height: 24, thickness: 1),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                          leading: const Icon(Icons.palette_outlined, size: 40),
                          title: const Text(
                            'Mode Tema Aplikasi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: ThemeMenuWidget(
                            currentThemeMode: tema.value ?? ThemeMode.system,
                            onThemeSelected: (theme) async {
                              await ref
                                  .read(temaProvider.notifier)
                                  .simpanModeTema(theme);
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Mode Pemeliharaan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                settings.modeMaintenance
                                    ? 'Aplikasi dalam mode pemeliharaan'
                                    : 'Aplikasi berjalan normal',
                              ),
                              value: settings.modeMaintenance,
                              onChanged: null,
                              secondary: Icon(
                                settings.modeMaintenance
                                    ? Icons.construction
                                    : Icons.check_circle_outline,
                                color: settings.modeMaintenance
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            if (settings.modeMaintenance)
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text(
                                  'Info Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  settings.infoMaintenance.isNotEmpty
                                      ? settings.infoMaintenance
                                      : '(Tidak ada pesan diatur)',
                                ),
                                isThreeLine: true,
                              ),
                          ],
                        ),
                      ),
                      gapH16,
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sync_problem),
                        label: const Text('Reset Waktu Sinkronisasi'),
                        onPressed: () => _resetWaktuSinkroniasi(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                gapH16,
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Pengaturan'),
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => const FormSettings()),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) {
          Log.error('Gagal memuat pengaturan', e: e, s: s);
          return Center(child: Text('Error: $e'));
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String judul,
    required String nilai,
    required IconData ikon,
    required BuildContext context,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/settings/page/settings_page_u.dart`
```dart
// path lib/fitur/settings/page/settings_page_u.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/feedback/page/feedback_page.dart';
import 'package:wifi/fitur/info_perangkat/page/info_apk_page_user.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

class SettingsPageU extends ConsumerWidget {
  const SettingsPageU({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
        children: <Widget>[
          _SettingsMenuItem(
            icon: TIcons.theme,
            title: 'Tema Aplikasi',
            trailing: Consumer(
              builder: (context, ref, child) {
                final themeAsync = ref.watch(temaProvider);
                return themeAsync.when(
                  data: (themeMode) => ThemeMenuWidget(
                    currentThemeMode: themeMode,
                    onThemeSelected: (mode) {
                      unawaited(
                        ref.read(temaProvider.notifier).simpanModeTema(mode),
                      );
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const Icon(TIcons.error),
                );
              },
            ),
          ),
          _SettingsMenuItem(
            icon: TIcons.feedback,
            title: 'Kritik dan Saran',
            onTap: () async {
              Log.info('Navigasi ke halaman riwayat masukan.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          _SettingsMenuItem(
            icon: TIcons.infoOutlined,
            title: 'Info Aplikasi & Perangkat',
            onTap: () async {
              Log.info('Navigasi ke halaman info aplikasi.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const InfoApkPageUser(),
                ),
              );
            },
          ),
          // Hanya tampilkan tombol ini dalam mode debug
          if (kDebugMode)
            _SettingsMenuItem(
              icon: TIcons.science,
              title: 'Halaman Uji Fitur',
              onTap: () async {
                Log.info('Navigasi ke halaman tes fitur.');
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const HalamanTes(),
                  ),
                );
              },
            ),
          _SettingsMenuItem(
            icon: TIcons.logout,
            title: 'Ganti Akun/Keluar',
            isDestructive: true,
            onTap: () async {
              Log.info('Navigasi ke halaman daftar akun untuk ganti akun.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const DaftarAkunPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget kustom untuk item menu di halaman pengaturan.
class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : null;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color)),
          trailing: trailing,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 4,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}
```

### File: `lib/fitur/settings/provider/settings_provider.dart`
```dart
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
      await _settingsOpSqlite.simpanAtauPerbaruiSettings(settings);
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
```

