# Dokumentasi: `lib/shared/utils/snackbar_util.dart`

File ini menyediakan utilitas untuk menampilkan `SnackBar` di seluruh aplikasi dengan gaya yang konsisten. Ini memastikan bahwa semua pesan yang ditampilkan kepada pengguna (sukses, error, peringatan, info) memiliki tampilan dan nuansa yang seragam, serta secara otomatis mencatat setiap SnackBar yang ditampilkan ke log.

---

## Enum `SnackBarType`

Enum ini mendefinisikan jenis-jenis SnackBar yang dapat ditampilkan. Setiap jenis memiliki warna latar yang berbeda untuk memberikan isyarat visual kepada pengguna.

- **Nilai:**
  - `success`: Untuk operasi yang berhasil (latar hijau).
  - `error`: Untuk operasi yang gagal atau error (latar merah).
  - `warning`: Untuk peringatan atau potensi masalah (latar oranye).
  - `info`: Untuk pesan informasi umum (latar biru).

---

## Kelas `SnackBarUtil`

Kelas statis yang berisi metode untuk menampilkan berbagai jenis SnackBar. Karena bersifat statis, Anda tidak perlu membuat instance dari kelas ini.

### `SnackBarUtil.success(BuildContext context, String message)`

Menampilkan SnackBar bertipe "sukses".

- **Parameter:**
  - `context` (BuildContext): Konteks dari widget tempat SnackBar akan ditampilkan.
  - `message` (String): Pesan yang ingin ditampilkan di dalam SnackBar.

- **Contoh Penggunaan:**
  '''dart
  SnackBarUtil.success(context, 'Profil berhasil diperbarui!');
  '''

---

### `SnackBarUtil.error(BuildContext context, String message)`

Menampilkan SnackBar bertipe "error".

- **Parameter:**
  - `context` (BuildContext): Konteks dari widget.
  - `message` (String): Pesan error yang akan ditampilkan.

- **Contoh Penggunaan:**
  '''dart
  SnackBarUtil.error(context, 'Gagal terhubung ke server.');
  '''

---

### `SnackBarUtil.warning(BuildContext context, String message)`

Menampilkan SnackBar bertipe "peringatan".

- **Parameter:**
  - `context` (BuildContext): Konteks dari widget.
  - `message` (String): Pesan peringatan yang akan ditampilkan.

- **Contoh Penggunaan:**
  '''dart
  SnackBarUtil.warning(context, 'Anda akan kehabisan kuota internet.');
  '''

---

### `SnackBarUtil.info(BuildContext context, String message)`

Menampilkan SnackBar bertipe "informasi".

- **Parameter:**
  - `context` (BuildContext): Konteks dari widget.
  - `message` (String): Pesan informasi yang akan ditampilkan.

- **Contoh Penggunaan:**
  '''dart
  SnackBarUtil.info(context, 'Pembaruan aplikasi tersedia.');
  '''
