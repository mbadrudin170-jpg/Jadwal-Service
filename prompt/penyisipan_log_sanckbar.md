// path: prompt/penyisipan_log_sanckbar.md
---

**Aturan Logging dan SnackBar untuk Asisten Koding Flutter:**

1. **Logging**
   - Jangan pernah menggunakan `print()`, `debugPrint()`, atau `log()` bawaan.
   - Gunakan class `Log` dari path `lib/shared/debug/log.dart`.
   - Class `Log` punya method:
     - `Log.info(pesan, data?)` untuk informasi
     - `Log.warning(pesan, data?)` untuk peringatan
     - `Log.error(pesan, {e, st, data})` untuk error (bisa menyertakan exception & stacktrace)
   - Selalu sertakan pesan yang jelas, dan jika ada data relevan (response API, objek state, dll) masukkan sebagai parameter `data`.

2. **Snackbar**
   - Jangan pernah langsung pakai `ScaffoldMessenger.of(context).showSnackBar(...)` atau widget `SnackBar`.
   - Gunakan class `SnackBarUtil` dari path `lib/shared/utils/snackbar_util.dart`.
   - `SnackBarUtil` punya method statis:
     - `SnackBarUtil.success(context, pesan, {logData})`
     - `SnackBarUtil.error(context, pesan, {logData})`
     - `SnackBarUtil.warning(context, pesan, {logData})`
     - `SnackBarUtil.info(context, pesan, {logData})`
   - `logData` bersifat opsional, hanya untuk log internal (tidak tampil ke user), tapi tetap cantumkan jika ada data tambahan.
   - Method-method ini otomatis mencatat log sesuai tipe, jadi setelah memanggil `SnackBarUtil` **tidak perlu** lagi memanggil `Log` secara manual, **kecuali** untuk error (lihat poin 3).

3. **Penanganan Error (WAJIB)**
   - Setiap kali terjadi error, **harus** melakukan dua hal:
     a. **Log error** menggunakan `Log.error(...)` agar tercatat detail exception, stacktrace, dan data.
     b. **Tampilkan SnackBar error** menggunakan `SnackBarUtil.error(context, pesanUser, ...)` agar pengguna mendapat notifikasi.
   - **Jangan hanya** memanggil `Log.error` tanpa SnackBar, atau sebaliknya. Keduanya wajib ada.
   - **Aturan linter**: Gunakan `on` untuk menangkap tipe exception spesifik. Jangan gunakan `catch` polos tanpa `on`. Minimal `on Exception catch (e, st)` atau lebih spesifik. Jika tidak yakin, gunakan `on Object catch (e, st)`.
   - SnackBar untuk error harus menampilkan pesan yang ramah pengguna, sementara `Log.error` bisa berisi detail teknis.

4. **Pencatatan di Setiap Alur Kerja (WAJIB)**
   - Setiap fungsi atau metode yang melakukan aksi signifikan (misal: fetch data, submit form, proses perhitungan, navigasi dengan data) **harus**:
     a. Mencatat log di awal proses (contoh: `Log.info('Memulai mengambil data pengguna')`).
     b. Setelah selesai, memberikan notifikasi ke pengguna menggunakan `SnackBarUtil` (contoh: `SnackBarUtil.success(context, 'Data berhasil diambil')`).
   - Untuk operasi yang hanya memberi informasi tanpa efek besar, cukup gunakan `SnackBarUtil.info()` (sudah termasuk log).
   - Untuk operasi yang menghasilkan peringatan (misal data kosong), gunakan `SnackBarUtil.warning()`.
   - **Jangan sampai** ada aksi penting yang tidak meninggalkan jejak log atau tidak memberi tahu pengguna melalui SnackBar.

5. **Impor**
   - Setiap file yang membutuhkan log atau snackbar wajib mengimpor:
     ```dart
     import 'package:wifi/shared/debug/log.dart';
     import 'package:wifi/shared/utils/snackbar_util.dart';
     ```

6. **Hanya Menyisipkan Log dan SnackBar (Jangan Mengubah Kode Asli)**
   - Fokus hanya menambahkan pemanggilan `Log` dan `SnackBarUtil` sesuai aturan di atas.
   - **Jangan mengubah** struktur, logika, alur navigasi, nama fungsi/variabel, atau perilaku kode yang sudah ada.
   - Jika operasi penting belum memiliki penanganan error, tambahkan **blok `try`/`on Exception catch` minimal** untuk mencatat log dan menampilkan snackbar error, tetapi **biarkan isi blok `try` sama persis** dengan kode asli (tidak diubah).
   - Jangan menambahkan fungsionalitas baru, refaktor, atau "perbaikan" yang tidak diminta.

---

