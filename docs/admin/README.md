# Dokumentasi APK Admin

## Perbaikan Form Transaksi (Mode Edit)

- **File**: `lib/admin/halaman/form/form_transaksi.dart`
- **Masalah**: Saat mengedit transaksi yang sudah ada, field `DropdownButtonFormField` untuk Dompet dan Kategori tidak secara otomatis memilih nilai yang sesuai dari data transaksi yang dimuat secara asinkron.
- **Penyebab**: Masalah ini terjadi karena `initialValue` dari `FormField` hanya dibaca saat state-nya pertama kali dibuat. Jika data untuk dropdown dimuat setelah widget dibuat, `initialValue` tidak akan dievaluasi kembali, dan UI tidak akan diperbarui. Penggunaan properti `value` yang sudah usang (`deprecated`) bukanlah solusi yang tepat dan menyebabkan peringatan saat kompilasi.
- **Solusi yang Benar**: Solusinya adalah dengan memberikan `key` unik pada setiap `DropdownButtonFormField`. Dengan menggunakan `ValueKey` yang nilainya adalah variabel state yang relevan (misalnya, `key: ValueKey<DompetModel?>(_selectedDompet)`), kita memberi sinyal kepada Flutter untuk memperlakukan `DropdownButtonFormField` sebagai widget yang berbeda setiap kali nilai state tersebut berubah. Ini memaksa Flutter untuk membuang state lama dari `FormField` dan membuat yang baru, yang pada gilirannya akan membaca ulang `initialValue` dengan nilai yang sudah diperbarui.
- **Hasil**: Dengan pendekatan ini, formulir edit transaksi sekarang berfungsi dengan benar. Semua field dropdown secara otomatis diisi dengan data yang benar setelah dimuat, dan ini dicapai dengan menggunakan praktik terbaik Flutter saat ini tanpa mengandalkan API yang sudah usang.
