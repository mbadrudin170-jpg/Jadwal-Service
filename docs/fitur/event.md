# Dokumentasi Fitur: event

## Daftar file

- [lib/fitur/event/model/event_model.dart](../../lib/fitur/event/model/event_model.dart)
- [lib/fitur/event/operasi/event_op_supabase.dart](../../lib/fitur/event/operasi/event_op_supabase.dart)
- [lib/fitur/event/page/detail_event_a.dart](../../lib/fitur/event/page/detail_event_a.dart)
- [lib/fitur/event/page/event_page_a.dart](../../lib/fitur/event/page/event_page_a.dart)
- [lib/fitur/event/page/event_page_u.dart](../../lib/fitur/event/page/event_page_u.dart)
- [lib/fitur/event/page/form_event.dart](../../lib/fitur/event/page/form_event.dart)

## Isi file

### File: `lib/fitur/event/model/event_model.dart`
```dart
// path: lib/fitur/event/model/event_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'event_model.freezed.dart';

@freezed
abstract class EventModel with _$EventModel implements HasId {
  const EventModel._();
  const factory EventModel({
    required String id,
    required String linkGambar,
    @Default(false) bool statusAktif,
    required DateTime tanggalDibuat,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    DateTime? diperbaruiPada,
  }) = _EventModel;

  /// Membuat [EventModel] dari SQLite map.
  factory EventModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating EventModel from SQLite: ${map[NamaKolom.id]}');
    return EventModel(
      id: map[NamaKolom.id] as String? ?? '',
      linkGambar: map[NamaKolom.linkGambar] as String? ?? '',
      statusAktif: ParserUtil.parseBool(map[NamaKolom.statusAktif]),
      tanggalDibuat:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalDibuat]) ??
          DateTime.now(),
      tanggalMulai:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalBerakhir]) ??
          DateTime.now(),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.linkGambar: linkGambar,
      NamaKolom.statusAktif: statusAktif ? 1 : 0,
      NamaKolom.tanggalDibuat: tanggalDibuat.millisecondsSinceEpoch,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tanggalBerakhir: tanggalBerakhir.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  /// Membuat [EventModel] dari Supabase document.
  factory EventModel.fromSupabase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating EventModel from Supabase: $id');
    return EventModel(
      id: id,
      linkGambar: data[NamaKolom.linkGambar] as String? ?? '',
      statusAktif: ParserUtil.parseBool(data[NamaKolom.statusAktif]),
      tanggalDibuat:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalDibuat]) ??
          DateTime.now(),
      tanggalMulai:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalBerakhir]) ??
          DateTime.now(),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan Supabase.
  Map<String, dynamic> toSupabase() {
    return {
      NamaKolom.id: id,
      NamaKolom.linkGambar: linkGambar,
      NamaKolom.statusAktif: statusAktif,
      NamaKolom.tanggalMulai: tanggalMulai.toIso8601String(),
      NamaKolom.tanggalBerakhir: tanggalBerakhir.toIso8601String(),
      NamaKolom.tanggalDibuat: tanggalDibuat.toIso8601String(),
      NamaKolom.diperbaruiPada: (diperbaruiPada ?? DateTime.now())
          .toIso8601String(),
    };
  }
}
```

### File: `lib/fitur/event/operasi/event_op_supabase.dart`
```dart
// path: lib/fitur/event/operasi/event_op_supabase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class EventOpSupabase {
  EventOpSupabase({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;
  final String _tabelEvent = NamaTabel.event;
  final SupabaseClient _supabase;

  Future<List<EventModel>> ambilSemuaEvent() async {
    Log.info('EventOpSupabase: Mengambil semua data pengumuman');
    try {
      Log.info('1️⃣ Membangun query...');
      final query = _supabase.from(_tabelEvent).select();
      Log.info('2️⃣ Eksekusi query ke Supabase...');
      final response = await query;
      Log.info('3️⃣ Response diterima, jumlah data: ${response.length}');

      return response.map((data) {
        Log.info('4️⃣ Mapping data: ${data[NamaKolom.id]}');
        return EventModel.fromSupabase(
          data[NamaKolom.id]?.toString() ?? '',
          data,
        );
      }).toList();
    } catch (e, s) {
      Log.error('❌ Gagal ambil data pengumuman', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil aliran data (Stream) pengumuman secara realtime (Versi Asinkron Aman).
  Stream<List<EventModel>> ambilRealtimeStream() async* {
    Log.info('EventOpSupabase: Membuka stream realtime untuk $_tabelEvent');

    // Gunakan yield* untuk mengalirkan data tanpa mengunci thread utama
    yield* _supabase
        .from(_tabelEvent)
        .stream(primaryKey: [NamaKolom.id])
        .handleError((Object e, StackTrace s) {
          Log.error('❌ Error di dalam stream: $e', e: e, s: s);
        })
        .map((response) {
          Log.info(
            '⚡ Realtime: Menerima ${response.length} data pengumuman terbaru',
          );
          return response.map((data) {
            return EventModel.fromSupabase(
              data[NamaKolom.id]?.toString() ?? '',
              data,
            );
          }).toList();
        });
  }

  Future<EventModel?> ambilEventAktif() async {
    /// Mengambil pengumuman yang sedang aktif.
    Log.info('EventOpSupabase: Mengambil pengumuman aktif');
    try {
      final respon = await _supabase
          .from(_tabelEvent)
          .select()
          .eq(NamaKolom.statusAktif, true)
          .limit(1);
      Log.info('$respon $_tabelEvent');

      if (respon.isEmpty) {
        return null;
      }

      final data = respon.first;
      Log.info('$data $_tabelEvent');
      return EventModel.fromSupabase(
        data[NamaKolom.id]?.toString() ?? '',
        data,
      );
    } catch (e, s) {
      Log.error('Gagal mengambil pengumuman aktif dari Supabase', e: e, s: s);
      rethrow;
    }
  }

  Future<EventModel?> ambilBerdasarkanId(String id) async {
    /// Mengambil pengumuman berdasarkan ID.
    Log.info('EventOpSupabase: Mengambil pengumuman berdasarkan id: $id');
    try {
      final respon = await _supabase
          .from(_tabelEvent)
          .select()
          .eq(NamaKolom.id, id)
          .limit(1);

      if (respon.isEmpty) {
        Log.warning('Pengumuman dengan id: $id tidak ditemukan');
        return null;
      }
      final data = respon.first;
      Log.info('Pengumuman ditemukan: $data');
      return EventModel.fromSupabase(
        data[NamaKolom.id]?.toString() ?? '',
        data,
      );
    } catch (e, s) {
      Log.error('Gagal mengambil pengumuman dengan id: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menambahkan data pengumuman baru ke Supabase.
  Future<void> tambahEvent(EventModel event) async {
    Log.info('EventOpSupabase: Membuat pengumuman baru ${event.id}');
    try {
      final dataPayload = event.toSupabase();
      await _supabase.from(_tabelEvent).insert(dataPayload);
    } catch (e, s) {
      Log.error('Gagal membuat pengumuman di Supabase', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui data pengumuman yang sudah ada di Supabase.
  Future<void> perbaruiEvent(EventModel event) async {
    Log.info('EventOpSupabase: Memperbarui pengumuman ${event.id}');
    try {
      final dataPayload = event.toSupabase();
      await _supabase
          .from(_tabelEvent)
          .update(dataPayload)
          .eq(NamaKolom.id, event.id);
    } catch (e, s) {
      Log.error('Gagal memperbarui pengumuman di Supabase', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus pengumuman secara permanen berdasarkan ID.
  Future<void> hapusEvent(String id) async {
    Log.warning('EventOpSupabase: Menghapus pengumuman $id');
    try {
      await _supabase.from(_tabelEvent).delete().eq(NamaKolom.id, id);
    } catch (e, s) {
      Log.error('Gagal menghapus pengumuman di Supabase', e: e, s: s);
      rethrow;
    }
  }
}

/// Provider Riverpod untuk `EventOpSupabase`.
final eventOpSupabaseProvider = Provider<EventOpSupabase>((ref) {
  return EventOpSupabase();
});
```

### File: `lib/fitur/event/page/detail_event_a.dart`
```dart
// path: lib/fitur/event/page/detail_event_a.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/form_event.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DetailEventA extends ConsumerWidget {
  final EventModel event;
  const DetailEventA({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureEvent = ref
        .watch(eventOpSupabaseProvider)
        .ambilBerdasarkanId(event.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: FutureBuilder<EventModel?>(
        future: futureEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error(
              'Error fetching event detail',
              e: snapshot.error,
              s: snapshot.stackTrace,
            );
            return const Center(child: Text('Gagal memuat data.'));
          }

          final detailEvent = snapshot.data;

          if (detailEvent == null) {
            return const Center(child: Text('Pengumuman tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detailEvent.linkGambar.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: detailEvent.linkGambar,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, e) {
                        Log.error(
                          'Gagal memuat gambar detail: ${detailEvent.linkGambar}',
                          e: e,
                        );
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(TIcons.error, size: 50),
                        );
                      },
                    ),
                  ),
                gapH16,
                Row(
                  children: [
                    Chip(
                      label: Text(
                        detailEvent.statusAktif ? 'Aktif' : 'Tidak Aktif',
                      ),
                      backgroundColor: detailEvent.statusAktif
                          ? Colors.green.withAlpha(25) // Menggunakan withAlpha
                          : Colors.grey.withAlpha(25), // Menggunakan withAlpha
                      labelStyle: TextStyle(
                        color: detailEvent.statusAktif
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dibuat: ${FormatTanggal.formatSingkat(event.tanggalDibuat)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                gapH16,
                const Text(
                  'ID Pengumuman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  detailEvent.id,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                gapH16,
                const Text(
                  'Deskripsi / Konten',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (context) => FormEvent(event: event)),
            );
            Log.info('Tombol edit untuk ${event.id} ditekan');
          },
          icon: const Icon(TIcons.edit),
          label: const Text('Edit Pengumuman'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/event/page/event_page_a.dart`
```dart
// path: lib/fitur/event/page/event_page_a.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/detail_event_a.dart';
import 'package:wifi/fitur/event/page/form_event.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Menggunakan StreamProvider dengan proteksi siklus hidup
final announcementsStreamProvider = StreamProvider.autoDispose<List<EventModel>>((
  ref,
) {
  final operator = ref.watch(eventOpSupabaseProvider);

  // Mencegah provider langsung dihancurkan saat layar sedikit bergeser/rebuild
  final link = ref.keepAlive();

  // Pastikan stream ditutup bersih saat halaman BENAR-BENAR ditinggalkan (di-pop)
  ref.onDispose(() {
    Log.warning(
      'announcementsStreamProvider: Menutup stream dan membersihkan memori.',
    );
    link.close();
  });

  return operator.ambilRealtimeStream();
});

class EventPageA extends ConsumerWidget {
  const EventPageA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Tonton state dari StreamProvider terbaru
    final announcementsAsync = ref.watch(announcementsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman Realtime')),
      // 3. RefreshIndicator sekarang opsional karena data sudah otomatis realtime.
      // Namun tetap dipertahankan jika pengguna ingin memaksa pembersihan cache/sinkronisasi ulang.
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(announcementsStreamProvider.future),
        child: announcementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            Log.error(
              'Error saat memuat pengumuman realtime: $error',
              e: error,
              s: stackTrace,
            );
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(TSizes.p16),
                child: Text(
                  'Gagal memuat pengumuman.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          data: (announcements) {
            if (announcements.isEmpty) {
              return const Center(child: Text('Belum ada pengumuman.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(TSizes.p16),
              // Tambahkan physics AlwaysScrollableScrollPhysics agar RefreshIndicator
              // tetap berfungsi normal meskipun jumlah item sedikit.
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (final context, final index) {
                final event = announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: TSizes.p16),
                  child: ListTile(
                    leading: event.linkGambar.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: event.linkGambar,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                Log.error(
                                  'Gagal memuat gambar: ${event.linkGambar}',
                                  e: error,
                                );
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    TIcons.error,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                );
                              },
                              // 🔥 Cache lebih cepat
                              fadeInDuration: const Duration(milliseconds: 200),
                              fadeInCurve: Curves.easeOut,
                            ),
                          )
                        : null,
                    title: Text(
                      'ID: ${event.id.length > 30 ? '${event.id.substring(0, 30)}...' : event.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gapH8,
                        Text(
                          'Dibuat: ${FormatTanggal.formatSingkat(event.tanggalDibuat)}',
                        ),
                        gapH4,
                        Chip(
                          label: Text(
                            event.statusAktif ? 'Aktif' : 'Tidak Aktif',
                          ),
                          avatar: Icon(
                            event.statusAktif
                                ? TIcons.toggleOn
                                : TIcons.toggleOff,
                            size: 18,
                            color: event.statusAktif
                                ? Colors.green
                                : Colors.grey,
                          ),
                          backgroundColor: event.statusAktif
                              ? Colors.green.withAlpha(26)
                              : Colors.grey.withAlpha(26),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ),
                    onTap: () {
                      Log.info('Menavigasi ke detail pengumuman.', {
                        'id': event.id,
                      });
                      unawaited(
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => DetailEventA(event: event),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('Membuka halaman untuk mengelola pengumuman baru.');
          unawaited(
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (context) => const FormEvent()),
            ),
          );
        },
        child: const Icon(TIcons.add),
      ),
    );
  }
}
```

### File: `lib/fitur/event/page/event_page_u.dart`
```dart
// path: lib/fitur/event/page/event_page_u.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/shared/theme/app_colors.dart';

class EventPageU extends ConsumerStatefulWidget {
  const EventPageU({super.key, required this.event});
  final EventModel event;

  @override
  ConsumerState<EventPageU> createState() => _EventPageUState();
}

class _EventPageUState extends ConsumerState<EventPageU> {
  Timer? _timer;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Hentikan timer sebelumnya jika ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    final data = widget.event;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: data.linkGambar,
            fit: BoxFit.cover,
            fadeOutDuration: const Duration(seconds: 200),
            fadeInDuration: const Duration(seconds: 300),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                backgroundColor: TColors.darkBackground.withValues(alpha: 0.7),
              ),
              child: Text(
                _countdown > 0 ? '$_countdown' : 'X',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/event/page/form_event.dart`
```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/layanan_penyimpanan_gambar.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormEvent extends ConsumerStatefulWidget {
  const FormEvent({super.key, this.event});
  final EventModel? event;

  @override
  ConsumerState<FormEvent> createState() => _FormEventState();
}

class _FormEventState extends ConsumerState<FormEvent> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _scrollController = ScrollController();
  late bool _isSwitched;
  EventModel? _selectedAnnouncement;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  bool get _isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _selectedAnnouncement = widget.event;
      _imageUrlController.text = widget.event!.linkGambar;
      _isSwitched = widget.event!.statusAktif;
      _selectedStartDate = widget.event!.tanggalMulai;
      _selectedEndDate = widget.event!.tanggalBerakhir;
    } else {
      _isSwitched = false;
    }
    unawaited(_loadData());
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.event != null) return;

    final operator = ref.read(eventOpSupabaseProvider);
    try {
      final announcements = await operator.ambilSemuaEvent();
      final activeAnnouncement = announcements.cast<EventModel?>().firstWhere(
        (ann) => ann?.statusAktif ?? false,
        orElse: () {
          Log.info('Tidak ada pengumuman aktif ditemukan untuk dimuat.');
          return null;
        },
      );

      setState(() {
        _selectedAnnouncement = activeAnnouncement;
        _imageUrlController.text = activeAnnouncement?.linkGambar ?? '';
        _isSwitched = activeAnnouncement?.statusAktif ?? false;
        _selectedStartDate = activeAnnouncement?.tanggalMulai;
        _selectedEndDate = activeAnnouncement?.tanggalBerakhir;
      });
    } on Exception catch (e, st) {
      Log.error('Gagal memuat pengumuman', e: e, s: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memuat data pengumuman.');
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e, st) {
      Log.error('Gagal memilih gambar', e: e, s: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memilih gambar dari galeri.');
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    var initialDate = DateTime.now();
    if (isStartDate) {
      if (_selectedStartDate != null) {
        initialDate = _selectedStartDate!;
      }
    } else {
      if (_selectedEndDate != null) {
        initialDate = _selectedEndDate!;
      }
    }
    DateTime? pickedDate;
    try {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
    } catch (e, st) {
      Log.error('Error saat memilih tanggal', e: e, s: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal membuka pemilih tanggal');
    }

    if (pickedDate != null) {
      setState(() {
        final currentDateTime = isStartDate
            ? _selectedStartDate
            : _selectedEndDate;
        final newDateTime = DateTime(
          pickedDate!.year,
          pickedDate.month,
          pickedDate.day,
          currentDateTime?.hour ?? DateTime.now().hour,
          currentDateTime?.minute ?? DateTime.now().minute,
        );
        if (isStartDate) {
          _selectedStartDate = newDateTime;
        } else {
          _selectedEndDate = newDateTime;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    var initialTime = TimeOfDay.now();
    final currentDateTime = isStartTime ? _selectedStartDate : _selectedEndDate;
    if (currentDateTime != null) {
      initialTime = TimeOfDay(
        hour: currentDateTime.hour,
        minute: currentDateTime.minute,
      );
    } else {
      initialTime = TimeOfDay.now();
    }
    TimeOfDay? pickedTime;
    try {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
    } catch (e, st) {
      Log.error('Error saat memilih waktu', e: e, s: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal membuka pemilih waktu');
    }

    if (pickedTime != null) {
      setState(() {
        final dateToUpdate = isStartTime
            ? _selectedStartDate
            : _selectedEndDate;
        final datePart = dateToUpdate ?? DateTime.now();

        final newDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          pickedTime!.hour,
          pickedTime.minute,
        );
        if (isStartTime) {
          _selectedStartDate = newDateTime;
        } else {
          _selectedEndDate = newDateTime;
        }
      });
    }
  }

  Future<void> _simpanForm() async {
    // 1. Validasi manual tanggal dan gambar karena tidak memakai TextFormField bawaan
    if (_selectedStartDate == null || _selectedEndDate == null) {
      ToastUtil.error(context, 'Harap pilih tanggal mulai dan selesai');
      return;
    }

    if (_selectedImage == null && _imageUrlController.text.trim().isEmpty) {
      ToastUtil.error(
        context,
        'Harap pilih atau sediakan gambar untuk pengumuman.',
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ToastUtil.error(
        context,
        'Tanggal selesai tidak boleh sebelum tanggal mulai',
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    var imageUrl = _imageUrlController.text.trim();

    // 2. Proses upload gambar ke storage jika admin memilih file gambar baru
    if (_selectedImage != null) {
      final storageService = ref.read(layananPenyimpananGambarProvider);
      try {
        final uploadUrl = await storageService.unggahGambar(
          _selectedImage!,
          NamaTabel.event,
        );
        imageUrl = uploadUrl;
        if (imageUrl.isEmpty) {
          throw Exception('URL gambar kosong dari storage service.');
        }
      } catch (e, st) {
        Log.error('Gagal mengunggah gambar', e: e, s: st);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal mengunggah gambar. Silakan coba lagi.');
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    final eventOpSupabase = ref.read(eventOpSupabaseProvider);
    final isActive = _isSwitched;
    final now = DateTime.now();

    // 3. REFAKTORISASI STRUKTUR OBJEK: Dipisahkan tegas antara Edit data vs Buat baru
    // Menjamin kolom 'not null' di Supabase selalu terisi dengan data terbaru dari UI
    final announcementToSave = _isEditMode
        ? _selectedAnnouncement!.copyWith(
            linkGambar: imageUrl,
            statusAktif: isActive,
            tanggalMulai: _selectedStartDate!,
            tanggalBerakhir: _selectedEndDate!,
            diperbaruiPada: now,
          )
        : EventModel(
            id: const Uuid().v4(),
            tanggalDibuat: now,
            diperbaruiPada: now,
            linkGambar: imageUrl,
            statusAktif: isActive,
            tanggalMulai: _selectedStartDate!,
            tanggalBerakhir: _selectedEndDate!,
          );

    if (isActive) {
      try {
        final currentActive = await eventOpSupabase.ambilEventAktif();
        if (currentActive != null &&
            currentActive.id != announcementToSave.id) {
          final oldActive = currentActive.copyWith(
            statusAktif: false,
            diperbaruiPada: now,
          );
          await eventOpSupabase.perbaruiEvent(oldActive);
        }
      } catch (e, st) {
        Log.error('Gagal menonaktifkan pengumuman lama', e: e, s: st);
        if (!mounted) return;
        ToastUtil.error(
          context,
          'Gagal menonaktifkan pengumuman lain yang aktif.',
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    // 5. Eksekusi penyimpanan ke Supabase via Provider
    try {
      if (_isEditMode) {
        await eventOpSupabase.perbaruiEvent(announcementToSave);
      } else {
        await eventOpSupabase.tambahEvent(announcementToSave);
      }
      final _ = ref.refresh(eventOpSupabaseProvider);
      if (!mounted) return;
      ToastUtil.success(context, 'Pengumuman berhasil disimpan!');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      Log.error('Gagal menyimpan pengumuman', e: e, s: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal menyimpan pengumuman.');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pengumuman')),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detail Pengumuman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              gapH16,
              // Image Preview and Picker
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                clipBehavior:
                    Clip.antiAlias, // Mencegah gambar keluar dari border radius
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. TAMPILAN JIKA ADA GAMBAR (LOKAL / URL)
                    if (_selectedImage != null)
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else if (_imageUrlController.text.isNotEmpty)
                      Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text('Gagal memuat gambar dari URL'),
                            ),
                      )
                    else
                      // Tampilan placeholder jika sama sekali belum ada gambar
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                          gapH8,
                          Text(
                            'Belum ada gambar terpilih',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),

                    // 2. TOMBOL AKSI (Ditempatkan secara dinamis menggunakan Positioned)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.7),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: Icon(
                          _selectedImage != null ||
                                  _imageUrlController.text.isNotEmpty
                              ? TIcons.edit
                              : TIcons.upload,
                          size: 18,
                        ),
                        label: Text(
                          _selectedImage != null ||
                                  _imageUrlController.text.isNotEmpty
                              ? 'Ubah Gambar'
                              : 'Pilih Gambar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              gapH16,

              PemilihTanggalWaktuWidget(
                teksLabel: 'Mulai:',
                tanggalTerpilih: _selectedStartDate,
                waktuTerpilih: _selectedStartDate == null
                    ? null
                    : TimeOfDay(
                        hour: _selectedStartDate!.hour,
                        minute: _selectedStartDate!.minute,
                      ),
                onPilihTanggal: () => _selectDate(true),
                onPilihWaktu: () => _selectTime(true),
              ),
              PemilihTanggalWaktuWidget(
                teksLabel: 'Selesai:',
                tanggalTerpilih: _selectedEndDate,
                waktuTerpilih: _selectedEndDate == null
                    ? null
                    : TimeOfDay(
                        hour: _selectedEndDate!.hour,
                        minute: _selectedEndDate!.minute,
                      ),
                onPilihTanggal: () => _selectDate(false),
                onPilihWaktu: () => _selectTime(false),
              ),
              gapH16,
              SwitchListTile(
                title: const Text('Aktifkan Pengumuman'),
                subtitle: const Text(
                  'Jika diaktifkan, pengumuman ini akan tampil di aplikasi.',
                ),
                value: _isSwitched,
                secondary: const Icon(TIcons.toggleOn),
                onChanged: (value) {
                  setState(() {
                    _isSwitched = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              gapH16,
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  icon: Icon(_isEditMode ? TIcons.edit : TIcons.save),
                  label: Text(
                    !_isEditMode ? 'Simpan Pengumuman' : 'Perbarui Pengumuman',
                  ),
                  onPressed: _isUploading ? null : _simpanForm,
                ),
        ),
      ),
    );
  }
}
```

