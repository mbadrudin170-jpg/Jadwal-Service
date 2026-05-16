# Dokumentasi APK Admin

## Peningkatan Cakupan Pengujian dan Verifikasi Log untuk `DompetPage`

- **File**: `test/admin/halaman/tab/dompet_test.dart` dan `lib/admin/halaman/tab/dompet.dart`
- **Masalah**: Pengujian awal untuk `DompetPage` tidak memverifikasi semua skenario, yang terbukti dari tidak munculnya semua pernyataan `Log` yang relevan saat `flutter test` dijalankan. Ini melanggar aturan proyek yang mengharuskan semua log dapat diverifikasi.
- **Solusi**: Cakupan pengujian untuk `DompetPage` diperluas secara signifikan dengan menambahkan beberapa skenario baru:
    1.  **Pengujian Render dengan Data**: Menambahkan tes untuk memastikan daftar `DompetCard` dirender dengan benar saat ada data. Proses ini juga mengungkap dan memperbaiki dua bug dalam pengujian itu sendiri: kesalahan tipe data pada mock `id` dan pencarian widget yang terlalu ambigu.
    2.  **Pengujian Navigasi**: Menambahkan tes yang mensimulasikan penekanan `FloatingActionButton` untuk memastikan aplikasi menavigasi ke `FormDompet`. Ini secara efektif memverifikasi eksekusi log navigasi.
    3.  **Pengujian Pembaruan Data**: Menambahkan tes yang mensimulasikan keberhasilan penambahan dompet baru dengan "mengembalikan" nilai `true` dari `FormDompet`. Dengan menggunakan `verify` dari `Mockito`, tes ini membuktikan bahwa fungsi untuk memuat ulang data dipanggil, sehingga memverifikasi log terkait.
- **Hasil**: Berkas pengujian `dompet_test.dart` sekarang jauh lebih komprehensif. Pengujian ini tidak hanya mencakup kondisi render statis tetapi juga interaksi pengguna, memastikan bahwa logika utama dan pernyataan log di `DompetPage` telah terverifikasi, sejalan dengan standar kualitas proyek.

---

## Perbaikan Lingkungan Pengujian

- **Konteks**: Proses `build_runner` yang penting untuk menghasilkan *mock* untuk pengujian unit mengalami kegagalan.
- **Tindakan**: Dilakukan investigasi dan perbaikan pada beberapa berkas pengujian yang terkait dengan operasi data admin, termasuk `kategori_operasi_test.dart`. Masalah seperti pelanggaran linting dan kesalahan dalam penyiapan *mock* telah diatasi.
- **Hasil**: `build_runner` sekarang berjalan dengan sukses, memulihkan kemampuan untuk menjalankan pengujian unit dan memastikan kualitas kode di sisi admin.

---

## Perbaikan Tampilan Nama Paket di Daftar Pelanggan Aktif (25 Juli 2024)

- **File**: `lib/admin/halaman/tab/pelanggan_aktif.dart`
- **Masalah**: Setelah `NamaPaketWidget` di-refactor secara global untuk menerima `Future<PaketModel?>` (lihat dokumentasi `shared`), halaman "Pelanggan Aktif" di aplikasi admin mengalami error kompilasi karena masih memanggil widget tersebut dengan cara lama (menggunakan `idPaket`).

- **Solusi**: Kode di dalam `ListView.builder` pada file ini telah diperbaiki untuk beradaptasi dengan `NamaPaketWidget` yang baru.
    1.  **Instansiasi `PaketOperasi`**: Sebuah instance dari `PaketOperasi` (yang berinteraksi dengan database SQLite lokal) dibuat di dalam *state* widget.
    2.  **Membuat `Future`**: Untuk setiap item pelanggan dalam daftar, sebuah `Future` dibuat dengan memanggil `_paketOperasi.getPaketById(pelanggan.idPaket)`.
    3.  **Meneruskan `Future`**: `Future` yang baru dibuat ini kemudian diteruskan ke parameter `paketFuture` dari `NamaPaketWidget`.

- **Hasil**: Error kompilasi teratasi. Halaman Pelanggan Aktif sekarang berfungsi kembali dengan benar, menampilkan nama paket dengan mengambil data dari sumber yang sesuai untuk lingkungan admin (database SQLite), sambil tetap menggunakan komponen UI `NamaPaketWidget` yang sama dengan aplikasi pengguna. Ini menunjukkan keberhasilan dari arsitektur komponen yang fleksibel dan dapat digunakan kembali.

---

## Perbaikan Form Transaksi (Mode Edit)

- **File**: `lib/admin/halaman/form/form_transaksi.dart`
- **Masalah**: Saat mengedit transaksi yang sudah ada, field `DropdownButtonFormField` untuk Dompet dan Kategori tidak secara otomatis memilih nilai yang sesuai dari data transaksi yang dimuat secara asinkron.
- **Penyebab**: Masalah ini terjadi karena `initialValue` dari `FormField` hanya dibaca saat state-nya pertama kali dibuat. Jika data untuk dropdown dimuat setelah widget dibuat, `initialValue` tidak akan dievaluasi kembali, dan UI tidak akan diperbarui. Penggunaan properti `value` yang sudah usang (`deprecated`) bukanlah solusi yang tepat dan menyebabkan peringatan saat kompilasi.
- **Solusi yang Benar**: Solusinya adalah dengan memberikan `key` unik pada setiap `DropdownButtonFormField`. Dengan menggunakan `ValueKey` yang nilainya adalah variabel state yang relevan (misalnya, `key: ValueKey<DompetModel?>(_selectedDompet)`), kita memberi sinyal kepada Flutter untuk memperlakukan `DropdownButtonFormField` sebagai widget yang berbeda setiap kali nilai state tersebut berubah. Ini memaksa Flutter untuk membuang state lama dari `FormField` dan membuat yang baru, yang pada gilirannya akan membaca ulang `initialValue` dengan nilai yang sudah diperbarui.
- **Hasil**: Dengan pendekatan ini, formulir edit transaksi sekarang berfungsi dengan benar. Semua field dropdown secara otomatis diisi dengan data yang benar setelah dimuat, dan ini dicapai dengan menggunakan praktik terbaik Flutter saat ini tanpa mengandalkan API yang sudah usang.

---

## Pemeriksaan dan Perbaikan Direktori `lib/admin`

- **File**: Seluruh file dalam direktori `lib/admin`, termasuk `halaman`, `halaman/form`, `halaman/tab`, dan `halaman/tambah`.
- **Masalah**: Banyak file dalam direktori `lib/admin` yang belum diperiksa dan berpotensi mengandung error, warning, atau kode yang tidak konsisten.
- **Solusi**: Dilakukan pemeriksaan menyeluruh pada setiap file dalam direktori `lib/admin`. File-file yang bermasalah diperbaiki dengan menambahkan logging, memperbaiki logika, dan menyesuaikan dengan arsitektur yang ada. Setiap file yang telah diperbaiki diberi komentar `// TODO : file telah selesai diperbaiki` untuk menandai bahwa file tersebut telah selesai diperiksa dan diperbaiki.
- **Hasil**: Direktori `lib/admin` sekarang lebih stabil, mudah dibaca, dan mudah dikelola. Kode di dalamnya lebih konsisten dan sesuai dengan standar proyek.

---

## Peningkatan Kualitas Kode Melalui Refaktorisasi dan Analisis Statis

- **Konteks**: Ditemukan bahwa beberapa bagian dari basis kode sulit untuk diuji, dan analisis statis menunjukkan adanya peringatan yang dapat memengaruhi kualitas dan pemeliharaan kode.
- **Tindakan**:
    - **Refaktorisasi untuk Testability**: `versi_apk_user_operasi.dart` telah di-refactor untuk menggunakan *Dependency Injection*, memisahkan logika bisnis dari lapisan data, yang secara signifikan meningkatkan kemudahan pengujian.
    - **Pembaruan Pengujian**: Berkas pengujian `versi_apk_user_operasi_test.dart` telah diperbarui untuk mencerminkan arsitektur baru dan menggunakan *mock* untuk pengujian yang terisolasi dan andal.
    - **Pembersihan Kode**: Berbagai peringatan dari `flutter analyze` di seluruh proyek telah diatasi, termasuk `avoid_dynamic_calls`, `avoid_catching_errors`, dan `avoid_catches_without_on_clauses`, yang menghasilkan kode yang lebih aman dan dapat diprediksi.
- **Hasil**: Kualitas basis kode secara keseluruhan telah meningkat. Kode sekarang tidak hanya lebih mudah untuk diuji dan dipelihara, tetapi juga lebih tangguh terhadap *error* dengan penanganan `exception` yang lebih baik dan tipe data yang lebih aman.

---

## Standarisasi Notifikasi dengan `SnackBarUtil`

- **Konteks**: Untuk meningkatkan konsistensi UI/UX di seluruh aplikasi admin, semua notifikasi *snackbar* telah distandarisasi.
- **Tindakan**: Semua pemanggilan `ScaffoldMessenger.of(context).showSnackBar()` telah diganti dengan utilitas terpusat, `SnackBarUtil`. Perubahan ini diterapkan pada file-file seperti:
  - `lib/admin/halaman/lainnya/pengaturan_admin.dart`
  - `lib/admin/halaman/lainnya/pelanggan.dart`
- **Hasil**: Notifikasi di seluruh aplikasi admin sekarang memiliki tampilan dan perilaku yang seragam, dikelola dari satu sumber kebenaran (`SnackBarUtil`), yang membuat kode lebih bersih dan lebih mudah dipelihara.

---

## Perbaikan Konflik Animasi `Hero` dengan Mengganti `IndexedStack`

- **File**: `lib/admin/halaman_utama.dart`
- **Masalah**: Aplikasi mengalami *crash* dengan error `multiple heroes that share the same tag` saat bernavigasi antar tab. Analisis menunjukkan bahwa `IndexedStack`, yang digunakan untuk mempertahankan *state* setiap halaman, menyebabkan konflik karena beberapa halaman yang aktif secara bersamaan di dalam *widget tree* memiliki `Hero` widget dengan *tag* yang identik.
- **Solusi**: Atas arahan pengguna, `IndexedStack` telah diganti. Alih-alih menumpuk semua widget, `body` dari `Scaffold` sekarang secara dinamis membangun hanya widget yang dipilih (`_widgetOptions.elementAt(_selectedIndex)`).
- **Hasil**: Perubahan ini secara efektif menyelesaikan masalah konflik `Hero` dengan memastikan hanya satu halaman (dan satu set `Hero` widget) yang ada di dalam *widget tree* pada satu waktu. Sebagai konsekuensi yang telah dipertimbangkan, *state* halaman (seperti posisi *scroll*) tidak lagi dipertahankan saat berpindah tab, yang merupakan trade-off yang dapat diterima untuk mengatasi *runtime error* kritis ini.

---

## Perbaikan `LateInitializationError` di `DompetPage`

- **File**: `lib/admin/halaman/tab/dompet.dart`
- **Masalah**: Setelah refaktorisasi `HalamanUtama` (menghilangkan `IndexedStack`), aplikasi mengalami *crash* saat membuka tab "Dompet". Investigasi mengungkapkan adanya `LateInitializationError` yang tersembunyi.
- **Penyebab**: Variabel `_dompetOperasi` di `_DompetPageState` ditandai sebagai `late final` tetapi tidak pernah diinisialisasi. Karena tab tidak lagi dijaga oleh `IndexedStack`, *state* halaman dibuat ulang setiap kali dibuka, dan upaya untuk mengakses `_dompetOperasi` yang belum diinisialisasi menyebabkan *crash*.
- **Solusi**: Variabel `_dompetOperasi` sekarang diinisialisasi dengan benar di dalam metode `initState` menggunakan `_dompetOperasi = widget.dompetOperasi ?? DompetOperasi();`. Ini memastikan bahwa *instance* `DompetOperasi` selalu tersedia sebelum metode lain membutuhkannya.
- **Hasil**: *Crash* berhasil diatasi. Halaman Dompet sekarang dapat dibangun kembali dengan andal setiap kali pengguna menavigasi ke tab tersebut, menjadikan aplikasi stabil.
