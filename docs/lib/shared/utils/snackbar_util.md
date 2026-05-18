# Dokumentasi: `lib/shared/utils/snackbar_util.dart`

`SnackBarUtil` adalah kelas utilitas pembungkus (wrapper) yang dirancang untuk menstandarisasi dan menyederhanakan penggunaan `SnackBar` di seluruh aplikasi. Ini mengatasi beberapa tantangan umum yang terkait dengan `ScaffoldMessenger`, seperti konsistensi gaya, logging, dan keamanan konteks (context safety).

Ini adalah komponen penting untuk menerapkan umpan balik pengguna yang konsisten dan dapat di-debug.

---

## Arsitektur dan Desain

1.  **Pola Fasad (Facade Pattern)**: Kelas ini bertindak sebagai fasad untuk `ScaffoldMessenger`. Daripada membiarkan pengembang memanggil `ScaffoldMessenger.of(context).showSnackBar(...)` di mana-mana dengan konfigurasi yang berpotensi berbeda setiap saat, `SnackBarUtil` menyediakan satu set metode sederhana (`success`, `error`, `warning`, `info`) yang menyembunyikan detail implementasi.

2.  **Metode Publik Sederhana, Logika Pribadi yang Kompleks**: Desainnya mengikuti praktik yang baik dengan mengekspos API publik yang mudah digunakan (`SnackBarUtil.success(...)`) sementara logika inti yang lebih kompleks berada dalam metode privat `_show(...)`. Ini membuat penggunaan utilitas menjadi sangat mudah dan mengurangi kemungkinan kesalahan.

3.  **Keamanan Konteks (`context.mounted`)**: Ini adalah fitur yang paling penting dan sering diabaikan. Pemanggilan `_show` mungkin terjadi dalam fungsi `async`. Ada kemungkinan bahwa pada saat `SnackBar` akan ditampilkan, pengguna telah menavigasi ke layar lain, membuat `BuildContext` asli menjadi tidak valid (*stale*). Mencoba menggunakan konteks yang tidak valid akan menyebabkan crash. `SnackBarUtil` secara cerdas memeriksa `if (!context.mounted) return;` **setelah** operasi yang berpotensi memakan waktu (bahkan logging bisa menjadi async di beberapa implementasi). Ini mencegah seluruh kelas kesalahan yang sulit di-debug.

4.  **Logging Otomatis**: Setiap kali `SnackBar` ditampilkan, sebuah log secara otomatis dibuat. Ini sangat berharga untuk debugging. Jika pengguna melaporkan perilaku aneh, log dapat mengungkapkan urutan pesan umpan balik yang mereka terima. Penggunaan level log yang berbeda (`Log.error` untuk `SnackBarType.error`) memungkinkan penyaringan log yang lebih mudah.

5.  **Gaya Terpusat**: Warna, bentuk (`RoundedRectangleBorder`), dan perilaku (`SnackBarBehavior.floating`) semuanya didefinisikan di satu tempat. Ini memastikan bahwa setiap `SnackBar` di seluruh aplikasi memiliki tampilan dan nuansa yang sama, menciptakan pengalaman pengguna yang konsisten dan profesional. Jika desain aplikasi berubah, hanya perlu mengubah beberapa baris di dalam file ini.

---

## Metode dan Penggunaan

-   **`SnackBarType` enum**: Mendefinisikan status semantik yang berbeda untuk sebuah pesan, yang kemudian dipetakan ke warna dan level log. Ini jauh lebih baik daripada melewatkan warna secara langsung, karena menjaga pemisahan antara "apa" (sebuah error) dan "bagaimana" (berwarna merah).

-   **`success(context, message)`**: Untuk pesan keberhasilan. Gunakan setelah operasi yang berhasil diselesaikan, seperti "Profil berhasil diperbarui".

-   **`error(context, message)`**: Untuk pesan kesalahan. Gunakan dalam blok `catch` atau setelah validasi gagal, seperti "Gagal terhubung ke server".

-   **`warning(context, message)`**: Untuk pesan peringatan. Gunakan untuk informasi yang tidak kritis tetapi penting, seperti "Koneksi internet Anda lambat".

-   **`info(context, message)`**: Untuk pesan informasi umum yang netral.

Contoh Penggunaan:
```dart
try {
  await updateUserProfile();
  SnackBarUtil.success(context, 'Profil berhasil diperbarui.');
} catch (e) {
  SnackBarUtil.error(context, 'Gagal memperbarui profil. Silakan coba lagi.');
}
```

---

## Kesimpulan

`SnackBarUtil` adalah contoh sempurna dari utilitas yang dirancang dengan baik. Ia mengambil API tingkat rendah Flutter, menambahkan lapisan keamanan (pemeriksaan `mounted`), konsistensi (gaya terpusat), dan kemampuan observasi (logging), dan membungkus semuanya dalam API yang sederhana dan aman untuk digunakan. Menerapkan aturan proyek yang mengharuskan semua `SnackBar` melalui utilitas ini adalah cara yang pasti untuk meningkatkan kualitas dan keandalan basis kode.
