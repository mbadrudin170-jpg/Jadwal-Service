// path: lib/fitur/chating/dummy_chatting.dart

import 'dart:math';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';

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
