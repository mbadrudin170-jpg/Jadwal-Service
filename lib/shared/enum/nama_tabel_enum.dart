// TODO: Tinjau kembali lokasi file ini. Disarankan untuk memindahkannya ke lib/common/enums/

enum NamaTabel {
  dompet,
  kategori,
  kritikSaran,
  paket,
  pelangganAktif,
  pelanggan,
  pesanan,
  // riwayatLangganan, // Tabel ini sudah digantikan oleh logika di dalam tabel transaksi
  transaksi,
  subKategori,
  versiApkUser,
  pengaturan,
  statusUnggah, // ditambah: tabel ini penting untuk sinkronisasi
  unknown,
}