# Cetak Biru Proyek

Dokumen ini memberikan gambaran umum tentang semua file dalam proyek, beserta tujuan dan fungsinya masing-masing.

## File Proyek

### `GEMINI.md`

*   **Fungsi**: Berisi aturan dan panduan untuk asisten AI (Gemini) yang digunakan dalam proyek ini. File ini mendefinisikan bagaimana AI harus berinteraksi dengan kode, mengelola dependensi, dan menangani kesalahan.

### `README.md`

*   **Fungsi**: Memberikan gambaran umum tentang proyek. Biasanya berisi informasi tentang cara menjalankan proyek, dependensi yang diperlukan, dan tujuan umum aplikasi.

### `analysis_options.yaml`

*   **Fungsi**: Mengkonfigurasi alat analisis statis untuk kode Dart. File ini memungkinkan Anda untuk menyesuaikan aturan linting, menentukan tingkat keparahan untuk berbagai masalah, dan memastikan gaya kode yang konsisten di seluruh proyek.

### `blueprint.md`

*   **Fungsi**: File ini! Dokumen ini berisi cetak biru proyek, termasuk deskripsi semua file dan direktori dalam proyek.

### `pubspec.lock`

*   **Fungsi**: File yang dibuat secara otomatis oleh manajer paket Dart (pub). File ini mengunci versi dependensi yang digunakan dalam proyek, memastikan bahwa setiap orang yang mengerjakan proyek menggunakan versi dependensi yang sama.

### `pubspec.yaml`

*   **Fungsi**: File konfigurasi utama untuk proyek Flutter. File ini mendefinisikan metadata proyek (nama, deskripsi, versi), dependensi, dan aset (gambar, font, dll.) yang digunakan oleh aplikasi.

### `.idx/dev.nix`

*   **Fungsi**: File konfigurasi Nix untuk lingkungan pengembangan. File ini mendefinisikan alat sistem, ekstensi IDE, variabel lingkungan, dan perintah startup yang diperlukan untuk proyek.

### `.idx/mcp.json`

*   **Fungsi**: Berisi konfigurasi untuk server Firebase MCP (Multi-platform Command-line Interface).

### `.vscode/settings.json`

*   **Fungsi**: Berisi pengaturan khusus untuk editor Visual Studio Code. Ini dapat mencakup pengaturan untuk pemformatan kode, analisis statis, dan fitur editor lainnya.

### `android/`

*   **Fungsi**: Direktori ini berisi semua file yang terkait dengan platform Android.
    *   `build.gradle.kts`: Skrip build utama untuk proyek Android.
    *   `gradle.properties`: Berisi properti untuk proses build Gradle.
    *   `settings.gradle.kts`: Skrip pengaturan untuk proyek Android.
    *   `app/`: Direktori ini berisi kode sumber dan sumber daya untuk aplikasi Android.
        *   `build.gradle.kts`: Skrip build untuk modul aplikasi.
        *   `src/`: Direktori ini berisi kode sumber Java/Kotlin dan file manifes Android.

### `lib/`

*   **Fungsi**: Direktori ini berisi kode sumber Dart untuk aplikasi Flutter.
    *   `main.dart`: Titik masuk utama untuk aplikasi Flutter.
    *   `common/`: Direktori untuk widget atau utilitas umum yang dapat digunakan kembali.
        *   `text_input_field.dart`: Berisi widget `CustomTextInputField` yang dapat digunakan kembali untuk membuat kolom input teks.

### `test/`

*   **Fungsi**: Direktori ini berisi file pengujian untuk aplikasi.
    *   `widget_test.dart`: Contoh pengujian widget.

### `web/`

*   **Fungsi**: Direktori ini berisi semua file yang terkait dengan platform web.
    *   `favicon.png`: Ikon yang ditampilkan di tab browser.
    *   `index.html`: File HTML utama untuk aplikasi web.
    *   `manifest.json`: File manifes aplikasi web.
    *   `icons/`: Direktori ini berisi ikon untuk aplikasi web.
