

--------------------------------------------------------------------------
| FILE INFO
| path : lib/user/operasi/contoh_file.dart
--------------------------------------------------------------------------
|
| Nama:
| PelangganOperasi
|
| Tujuan:
| Mengelola operasi CRUD pelanggan pada SQLite.
|
| Tanggung Jawab:
| - Tambah pelanggan
| - Edit pelanggan
| - Arsip pelanggan
| - Ambil data pelanggan
|
| Tidak Bertanggung Jawab:
| - UI
| - Validasi form
| - Notifikasi
|
|--------------------------------------------------------------------------
| ALUR DATA
|--------------------------------------------------------------------------
|
| UI/Form
|   ↓
| PelangganOperasi
|   ↓
| DatabaseHelper
|   ↓
| SQLite
|
|--------------------------------------------------------------------------
| DEPENDENCY
|--------------------------------------------------------------------------
|
| Digunakan oleh:
| - FormPelangganPage
| - DetailPelangganPage
|
| Bergantung pada:
| - DatabaseHelper
| - PelangganModel
|
|--------------------------------------------------------------------------
| CATATAN PENTING
|--------------------------------------------------------------------------
|
| - Semua waktu wajib UTC.
| - Jangan pakai print().
| - Gunakan transaksi database.
|
|--------------------------------------------------------------------------
| RESIKO JIKA DIUBAH
|--------------------------------------------------------------------------
|
| Jika struktur return berubah:
| - Form pelanggan bisa error.
| - Test pelanggan gagal.
|
|--------------------------------------------------------------------------
| TODO
|--------------------------------------------------------------------------
|
| - Tambahkan bulk insert.
| - Optimasi query pencarian.
|
--------------------------------------------------------------------------
