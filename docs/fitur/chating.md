# Dokumentasi Fitur: chating

## Daftar file

lib/fitur/chating/chating.dart
lib/fitur/chating/chating_dashboard.dart
lib/fitur/chating/dummy_chatting.dart
lib/fitur/chating/enum/status_pesan_enum.dart
lib/fitur/chating/model/chating_model.dart
lib/fitur/chating/model/lampiran.dart
lib/fitur/chating/model/percakapan.dart
lib/fitur/chating/operasi/chating_op_supabase.dart
lib/fitur/chating/provider/chating_provider.dart

## Isi file

### File: `lib/fitur/chating/chating.dart`
```dart
// file: lib/fitur/chating/chating.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';

class Chating extends ConsumerStatefulWidget {
  // ID pengguna yang sedang login

  const Chating({
    super.key,
    required this.idPercakapan,
    required this.namaLawanbicara,
    this.pesanAwal,
    this.idPenggunaSaatIni = 'u1', // sementara hardcode, nanti dari auth
  });
  final String idPercakapan;
  final String namaLawanbicara;
  final List<Pesan>? pesanAwal;
  final String idPenggunaSaatIni;

  @override
  ConsumerState<Chating> createState() => _ChatingState();
}

class _ChatingState extends ConsumerState<Chating> {
  late final List<Pesan> _pesan;
  final TextEditingController _pengontrol = TextEditingController();
  final ScrollController _penggulir = ScrollController();
  bool _sedangMengirim = false;

  @override
  void initState() {
    super.initState();
    // gunakan pesan awal jika ada, atau daftar kosong
    _pesan = List<Pesan>.from(widget.pesanAwal ?? []);
  }

  @override
  void dispose() {
    _pengontrol.dispose();
    _penggulir.dispose();
    super.dispose();
  }

  Future<void> _kirimPesan({bool popAfterSend = false}) async {
    final teks = _pengontrol.text.trim();
    if (teks.isEmpty) return;

    final pesanBaru = Pesan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idPercakapan: widget.idPercakapan,
      idPengirim: widget.idPenggunaSaatIni,
      teks: teks,
      dibuatPada: DateTime.now(),
      status: StatusPesan.mengirim,
    );

    setState(() {
      _sedangMengirim = true;
      _pesan.add(pesanBaru);
      _pengontrol.clear();
    });
    _gulirKeBawah();

    // Simulasi pengiriman (ganti dengan backend call)
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Perbarui status menjadi terkirim
    setState(() {
      _pesan[_pesan.length - 1] = pesanBaru.copyWith(
        status: StatusPesan.terkirim,
      );
      _sedangMengirim = false;
    });

    if (popAfterSend) {
      if (mounted) {
        Navigator.pop(context, pesanBaru);
      }
    }
  }

  void _tutupDanKembalikanHasil() {
    final hasil = {
      'idPercakapan': widget.idPercakapan,
      'jumlahPesan': _pesan.length,
      'pesanTerakhir': _pesan.isNotEmpty ? _pesan.last : null,
    };
    Navigator.pop(context, hasil);
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_penggulir.hasClients) return;
      _penggulir.animateTo(
        _penggulir.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _tutupDanKembalikanHasil,
        ),
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaLawanbicara,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _penggulir,
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: _pesan.length,
                itemBuilder: (context, index) {
                  final m = _pesan[index];
                  final isMine = m.idPengirim == widget.idPenggunaSaatIni;
                  return Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _bangunBubblePesan(m, isMine),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      // TODO: lampiran
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _pengontrol,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF2F3F5),
                      ),
                      onSubmitted: (_) => _kirimPesan(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sedangMengirim
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: _kirimPesan,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunBubblePesan(Pesan m, bool isMine) {
    final alignment = isMine
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bgColor = isMine ? Colors.blue.shade600 : Colors.grey.shade200;
    final textColor = isMine ? Colors.white : Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMine ? 12 : 0),
      bottomRight: Radius.circular(isMine ? 0 : 12),
    );

    // Tampilkan teks dan mungkin lampiran (disederhanakan dulu)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              decoration: BoxDecoration(color: bgColor, borderRadius: radius),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                m.teks ?? '',
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatWaktu(m.dibuatPada),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatWaktu(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inDays == 0) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } else {
      return '${t.day}/${t.month}/${t.year}';
    }
  }
}
```

### File: `lib/fitur/chating/chating_dashboard.dart`
```dart
// path: lib/fitur/chating/chating_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/chating/chating.dart';
import 'package:wifi/fitur/chating/dummy_chatting.dart';
import 'package:wifi/fitur/chating/model/percakapan.dart';

class ChatingDashboard extends ConsumerWidget {
  const ChatingDashboard({super.key});

  String _formatWaktu(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays == 0) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${t.day}/${t.month}/${t.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan dummy conversations dari dummy_chatting.dart
    const chats = sampleConversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari percakapan',
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ChatSearchDelegate(chats),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Lainnya',
            onPressed: () {
              // buka menu atau pengaturan chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conv = chats[index];
                // Ambil pesan dummy untuk percakapan ini
                final msgs = sampleMessagesForConversation(conv.id);
                final lastMsg = msgs.isNotEmpty ? msgs.last : null;

                // Pratinjau: gunakan pratinjau dari percakapan atau teks pesan terakhir
                final preview =
                    conv.pratinjauPesanTerakhir ?? lastMsg?.teks ?? '-';

                // Waktu: gunakan waktuPesanTerakhir atau dibuatPada dari pesan terakhir
                final waktu = conv.waktuPesanTerakhir ?? lastMsg?.dibuatPada;
                final waktuTampil = waktu != null ? _formatWaktu(waktu) : '';

                // Judul: gunakan tampilkanJudul getter
                final judul = conv.tampilkanJudul;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    child: Text(
                      judul.isNotEmpty ? judul[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        waktuTampil,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (conv.jumlahBelumDibaca > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conv.jumlahBelumDibaca.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Konversi Pesan dari dummy ke data yang bisa dipakai Chating
                    final pesanAwal =
                        msgs; // sampleMessagesForConversation sudah List<Pesan>
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => Chating(
                          idPercakapan: conv.id,
                          namaLawanbicara: judul,
                          pesanAwal: pesanAwal,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Mulai percakapan baru',
        child: const Icon(Icons.chat),
        onPressed: () {
          // buka layar buat chat baru
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Percakapan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              // buka filter percakapan
            },
          ),
        ],
      ),
    );
  }
}

class _ChatSearchDelegate extends SearchDelegate<String> {
  _ChatSearchDelegate(List<Percakapan> chats) : conversations = chats;
  final List<Percakapan> conversations;

  @override
  String get searchFieldLabel => 'Cari nama atau pesan';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = conversations.where((c) {
      final q = query.toLowerCase();
      final judul = c.tampilkanJudul.toLowerCase();
      final msgs = sampleMessagesForConversation(c.id);
      final preview =
          c.pratinjauPesanTerakhir ??
          (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
      return judul.contains(q) || preview.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Tidak ada hasil'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conv = results[index];
        final judul = conv.tampilkanJudul;
        final msgs = sampleMessagesForConversation(conv.id);
        final preview =
            conv.pratinjauPesanTerakhir ??
            (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
        return ListTile(
          leading: CircleAvatar(
            child: Text(judul.isNotEmpty ? judul[0].toUpperCase() : '?'),
          ),
          title: Text(judul),
          subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            close(context, conv.id);
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Chating(
                  idPercakapan: conv.id,
                  namaLawanbicara: judul,
                  pesanAwal: msgs,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? conversations
        : conversations.where((c) {
            final q = query.toLowerCase();
            final judul = c.tampilkanJudul.toLowerCase();
            final msgs = sampleMessagesForConversation(c.id);
            final preview =
                c.pratinjauPesanTerakhir ??
                (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
            return judul.contains(q) || preview.toLowerCase().contains(q);
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final conv = suggestions[index];
        final judul = conv.tampilkanJudul;
        final msgs = sampleMessagesForConversation(conv.id);
        final preview =
            conv.pratinjauPesanTerakhir ??
            (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
        return ListTile(
          leading: CircleAvatar(
            child: Text(judul.isNotEmpty ? judul[0].toUpperCase() : '?'),
          ),
          title: Text(judul),
          subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            query = judul;
            showResults(context);
          },
        );
      },
    );
  }
}
```

### File: `lib/fitur/chating/dummy_chatting.dart`
```dart
// path: lib/fitur/chating/dummy_chatting.dart

import 'dart:math';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';
import 'package:wifi/fitur/chating/model/lampiran.dart';
import 'package:wifi/fitur/chating/model/percakapan.dart';

/// Dummy data untuk fitur chating.
/// Gunakan ini untuk pengujian UI sebelum menghubungkan ke backend nyata.

/// Contoh pengguna dummy (id, nama, avatarUrl)
const Map<String, Map<String, String>> dummyUsers = {
  'u1': {'nama': 'Admin Support', 'avatar': ''},
  'u2': {'nama': 'Budi', 'avatar': ''},
  'u3': {'nama': 'Siti', 'avatar': ''},
  'u4': {'nama': 'Toko Indah', 'avatar': ''},
};

/// Daftar percakapan dummy
const List<Percakapan> sampleConversations = [
  Percakapan(
    id: 'c1',
    idPartisipan: ['u1', 'u2'],
    judul: 'Budi',
    pratinjauPesanTerakhir: 'Terima kasih, kami akan cek dan segera merespon.',
    jumlahBelumDibaca: 1,
  ),
  Percakapan(
    id: 'c2',
    idPartisipan: ['u1', 'u3'],
    judul: 'Siti',
    pratinjauPesanTerakhir: 'Pembayaran diterima',
  ),
  Percakapan(
    id: 'c3',
    idPartisipan: ['u1', 'u4'],
    judul: 'Toko Indah',
    pratinjauPesanTerakhir: 'Ada promo baru minggu ini',
    jumlahBelumDibaca: 2,
  ),
];

/// Pesan dummy statis untuk percakapan tertentu
List<Pesan> sampleMessagesForConversation(String conversationId) {
  final now = DateTime.now();
  if (conversationId == 'c1') {
    return [
      Pesan(
        id: 'm1',
        idPercakapan: 'c1',
        idPengirim: 'u1',
        teks: 'Halo, ada yang bisa dibantu?',
        dibuatPada: now.subtract(const Duration(minutes: 10)),
        status: StatusPesan.dibaca,
      ),
      Pesan(
        id: 'm2',
        idPercakapan: 'c1',
        idPengirim: 'u2',
        teks: 'Saya mau tanya soal paket internet.',
        dibuatPada: now.subtract(const Duration(minutes: 9)),
        status: StatusPesan.dibaca,
      ),
      Pesan(
        id: 'm3',
        idPercakapan: 'c1',
        idPengirim: 'u1',
        teks: 'Silakan, sebutkan kendalanya.',
        dibuatPada: now.subtract(const Duration(minutes: 8)),
        status: StatusPesan.dibaca,
      ),
      Pesan(
        id: 'm4',
        idPercakapan: 'c1',
        idPengirim: 'u2',
        teks: 'Koneksi sering putus malam hari.',
        dibuatPada: now.subtract(const Duration(minutes: 7)),
      ),
      Pesan(
        id: 'm5',
        idPercakapan: 'c1',
        idPengirim: 'u1',
        teks: 'Terima kasih, kami akan cek dan segera merespon.',
        dibuatPada: now.subtract(const Duration(minutes: 6)),
      ),
    ];
  } else if (conversationId == 'c2') {
    return [
      Pesan(
        id: 'm10',
        idPercakapan: 'c2',
        idPengirim: 'u3',
        teks: 'Apakah paket 10GB masih tersedia?',
        dibuatPada: now.subtract(const Duration(days: 1, hours: 2)),
        status: StatusPesan.diterima,
      ),
      Pesan(
        id: 'm11',
        idPercakapan: 'c2',
        idPengirim: 'u1',
        teks: 'Iya, masih tersedia. Mau saya aktifkan?',
        dibuatPada: now.subtract(
          const Duration(days: 1, hours: 1, minutes: 50),
        ),
        status: StatusPesan.dibaca,
      ),
    ];
  } else if (conversationId == 'c3') {
    return [
      Pesan(
        id: 'm20',
        idPercakapan: 'c3',
        idPengirim: 'u4',
        teks: 'Ada promo baru minggu ini: diskon 20%',
        dibuatPada: now.subtract(const Duration(days: 2)),
      ),
      Pesan(
        id: 'm21',
        idPercakapan: 'c3',
        idPengirim: 'u1',
        teks: 'Terima kasih informasinya.',
        dibuatPada: now.subtract(const Duration(days: 2, minutes: 10)),
      ),
    ];
  } else {
    return [];
  }
}

/// Generator pesan dummy acak untuk pengujian UI (pagination / load more)
List<Pesan> generateDummyMessages({
  required String conversationId,
  required String myUserId,
  int count = 20,
}) {
  final rnd = Random();
  final now = DateTime.now();
  final samples = <String>[
    'Halo, ada yang bisa dibantu?',
    'Terima kasih, kami akan cek dan segera merespon.',
    'Saya mau tanya soal paket internet.',
    'Koneksi sering putus malam hari.',
    'Silakan, sebutkan kendalanya.',
    'Pembayaran diterima.',
    'Mohon tunggu sebentar.',
    'Sudah saya proses.',
    'Bisa kirimkan bukti pembayaran?',
    'Promo berlaku sampai akhir bulan.',
  ];

  return List.generate(count, (i) {
    final isMine = rnd.nextBool();
    final teks = samples[rnd.nextInt(samples.length)];
    return Pesan(
      id: '${conversationId}_gen_${i}_${now.millisecondsSinceEpoch}',
      idPercakapan: conversationId,
      idPengirim: isMine ? myUserId : 'u${(rnd.nextInt(3) + 1)}',
      teks: teks,
      dibuatPada: now.subtract(Duration(minutes: (count - i) * 3)),
      status: StatusPesan.values[rnd.nextInt(StatusPesan.values.length)],
      lampiran: rnd.nextBool()
          ? [
              Lampiran(
                id: 'att_$i',
                url: 'https://example.com/file_$i.jpg',
                tipe: 'gambar', // disesuaikan dengan model baru
                nama: 'file_$i.jpg',
                ukuran: 1024 + rnd.nextInt(20000),
              ),
            ]
          : const [],
      reaksi: rnd.nextBool() ? {'👍': rnd.nextInt(5) + 1} : const {},
    );
  });
}
```

### File: `lib/fitur/chating/enum/status_pesan_enum.dart`
```dart
// path lib/fitur/chating/enum/status_pesan_enum.dart
enum StatusPesan { mengirim, terkirim, diterima, dibaca, gagal }
```

### File: `lib/fitur/chating/model/chating_model.dart`
```dart
// lib/fitur/chating/model/chating_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/lampiran.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // tambahkan import

part 'chating_model.freezed.dart';

@freezed
abstract class Pesan with _$Pesan {
  const Pesan._();
  const factory Pesan({
    required String id,
    required String idPercakapan,
    required String idPengirim,
    String? teks,
    required DateTime dibuatPada,
    DateTime? dieditPada,
    @Default(StatusPesan.terkirim) StatusPesan status,
    @Default([]) List<Lampiran> lampiran,
    String? balasanUntuk,
    @Default({}) Map<String, int> reaksi,
    Map<String, dynamic>? metadata,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
  }) = _Pesan;

  factory Pesan.fromSupabase(String id, Map<String, dynamic> data) {
    List<Lampiran> parseLampiran(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        try {
          return v.cast<Map<String, dynamic>>().map(Lampiran.fromMap).toList();
        } catch (_) {
          return v
              .whereType<Map<String, dynamic>>()
              .map(Lampiran.fromMap)
              .toList();
        }
      }
      return [];
    }

    // Reaksi tetap manual
    Map<String, int> parseReaksi(dynamic v) {
      if (v == null) return {};
      if (v is Map) {
        return v.map(
          (key, value) => MapEntry(
            key.toString(),
            (value is int) ? value : int.tryParse(value?.toString() ?? '') ?? 0,
          ),
        );
      }
      return {};
    }

    final meta = data['metadata'];

    return Pesan(
      id: id,
      idPercakapan:
          data['id_percakapan'] as String? ??
          data['idPercakapan'] as String? ??
          '',
      idPengirim:
          data['id_pengirim'] as String? ?? data['idPengirim'] as String? ?? '',
      teks: data['teks'] as String?,
      dibuatPada:
          ParserUtil.parseDateTime(data['dibuat_pada'] ?? data['dibuatPada']) ??
          DateTime.now(),
      dieditPada: ParserUtil.parseDateTime(
        data['diedit_pada'] ?? data['dieditPada'],
      ),
      status:
          ParserUtil.safeParseEnum(
            StatusPesan.values,
            data['status']?.toString(),
          ) ??
          StatusPesan.terkirim,
      lampiran: parseLampiran(data['lampiran'] ?? data['attachments']),
      balasanUntuk:
          data['balasan_untuk'] as String? ?? data['balasanUntuk'] as String?,
      reaksi: parseReaksi(data['reaksi'] ?? data['reactions']),
      metadata: meta is Map ? Map<String, dynamic>.from(meta) : null,
      dihapus: ParserUtil.parseBool(data['dihapus']),
      diarsipkanPada: ParserUtil.parseDateTime(
        data['diarsipkan_pada'] ?? data['diarsipkanPada'],
      ),
    );
  }

  Map<String, dynamic> toSupabase() {
    // tidak berubah
    return {
      'id': id,
      'id_percakapan': idPercakapan,
      'id_pengirim': idPengirim,
      'teks': teks,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diedit_pada': dieditPada?.toIso8601String(),
      'status': status.toString().split('.').last,
      'lampiran': lampiran.map((l) => l.toMap()).toList(),
      'balasan_untuk': balasanUntuk,
      'reaksi': reaksi,
      'metadata': metadata,
      'dihapus': dihapus,
      'diarsipkan_pada': diarsipkanPada?.toIso8601String(),
    };
  }
}
```

### File: `lib/fitur/chating/model/lampiran.dart`
```dart
// lib/fitur/chating/model/lampiran.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lampiran.freezed.dart';

@freezed
abstract class Lampiran with _$Lampiran {
  const Lampiran._();
  const factory Lampiran({
    required String id,
    required String url,
    required String tipe, // 'gambar', 'file', 'audio'
    String? nama,
    int? ukuran, // dalam byte
  }) = _Lampiran;

  // helper untuk membuat dari Map (Supabase / JSON)
  factory Lampiran.fromMap(Map<String, dynamic> map) {
    return Lampiran(
      id: map['id'] as String? ?? '',
      url: map['url'] as String? ?? '',
      tipe: map['tipe'] as String? ?? '',
      nama: map['nama'] as String?,
      ukuran: (map['ukuran'] is int)
          ? map['ukuran'] as int
          : int.tryParse(map['ukuran']?.toString() ?? ''),
    );
  }

  // alias jika kamu ingin nama khusus Supabase
  factory Lampiran.fromSupabase(Map<String, dynamic> map) =>
      Lampiran.fromMap(map);

  // konversi ke Map untuk disimpan ke Supabase / JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'tipe': tipe,
      if (nama != null) 'nama': nama,
      if (ukuran != null) 'ukuran': ukuran,
    };
  }

  // alias toSupabase
  Map<String, dynamic> toSupabase() => toMap();
}
```

### File: `lib/fitur/chating/model/percakapan.dart`
```dart
// lib/fitur/chating/model/percakapan.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'percakapan.freezed.dart';

@freezed
abstract class Percakapan with _$Percakapan implements HasId {
  const Percakapan._();
  const factory Percakapan({
    required String id,
    @Default([]) List<String> idPartisipan,
    String? judul,
    Pesan? pesanTerakhir,
    String? pratinjauPesanTerakhir,
    DateTime? waktuPesanTerakhir,
    @Default(0) int jumlahBelumDibaca,
  }) = _Percakapan;

  /// Getter untuk tampilan judul (mengatasi error undefined getter)
  String get tampilkanJudul => judul ?? 'Tanpa Judul';

  /// Membuat [Percakapan] dari SQLite map.
  factory Percakapan.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating Percakapan from SQLite: ${map['id']}');
    return Percakapan(
      id: map['id'] as String? ?? '',
      idPartisipan:
          (map['id_partisipan'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      judul: map['judul'] as String?,
      pratinjauPesanTerakhir: map['pratinjau_pesan_terakhir'] as String?,
      waktuPesanTerakhir: ParserUtil.parseDateTime(map['waktu_pesan_terakhir']),
      jumlahBelumDibaca:
          int.tryParse(map['jumlah_belum_dibaca']?.toString() ?? '') ?? 0,
    );
  }

  /// Mengonversi [Percakapan] ke map untuk SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_partisipan': idPartisipan.join(','),
      'judul': judul,
      'pratinjau_pesan_terakhir': pratinjauPesanTerakhir,
      'waktu_pesan_terakhir': waktuPesanTerakhir?.millisecondsSinceEpoch,
      'jumlah_belum_dibaca': jumlahBelumDibaca,
    };
  }

  /// Membuat [Percakapan] dari Supabase document.
  factory Percakapan.fromSupabase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating Percakapan from Supabase: $id');
    return Percakapan(
      id: id,
      idPartisipan:
          (data['id_partisipan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      judul: data['judul'] as String?,
      pratinjauPesanTerakhir: data['pratinjau_pesan_terakhir'] as String?,
      waktuPesanTerakhir: ParserUtil.parseDateTime(
        data['waktu_pesan_terakhir'],
      ),
      jumlahBelumDibaca:
          int.tryParse(data['jumlah_belum_dibaca']?.toString() ?? '') ?? 0,
    );
  }

  /// Mengonversi [Percakapan] ke map untuk Supabase.
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'id_partisipan': idPartisipan,
      'judul': judul,
      'pratinjau_pesan_terakhir': pratinjauPesanTerakhir,
      'waktu_pesan_terakhir': waktuPesanTerakhir?.toIso8601String(),
      'jumlah_belum_dibaca': jumlahBelumDibaca,
    };
  }
}
```

### File: `lib/fitur/chating/operasi/chating_op_supabase.dart`
```dart

```

### File: `lib/fitur/chating/provider/chating_provider.dart`
```dart

```

