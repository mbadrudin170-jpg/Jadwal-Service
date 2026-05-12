# Cetak Biru Proyek

Dokumen ini memberikan gambaran umum tentang semua file dalam proyek, beserta tujuan dan fungsinya masing-masing.

## Struktur & Fitur Utama

- **Flavors (User & Admin)**: Proyek ini dikonfigurasi untuk membangun dua versi aplikasi (`user` dan `admin`) dari satu basis kode. Masing-masing memiliki Application ID dan file entri yang terpisah.
- **Pemisahan Kode**: Kode untuk setiap flavor dipisahkan ke dalam direktorinya sendiri (`lib/admin` dan `lib/user`) untuk meningkatkan keterbacaan dan pengelolaan.
- **Integrasi Firebase (Flavor-specific)**: Kedua aplikasi terdaftar dalam satu proyek Firebase. Konfigurasi Firebase untuk setiap flavor dipisahkan ke dalam file `firebase_option` masing-masing (`..._user_dev.dart` dan `..._admin_dev.dart`) untuk memastikan inisialisasi yang benar.

## File Proyek

### Direktori Root

- **`GEMINI.md`**: Aturan dan panduan untuk asisten AI (Gemini).
- **`README.md`**: Informasi umum dan cara menjalankan proyek.
- **`analysis_options.yaml`**: Konfigurasi alat analisis statis Dart (linting).
- **`blueprint.md`**: Dokumen ini. Cetak biru arsitektur dan file proyek.
- **`pubspec.lock`**: Mengunci versi pasti dari setiap dependensi proyek.
- **`pubspec.yaml`**: Mendefinisikan metadata, dependensi, dan aset (gambar, font) untuk proyek.

### Direktori Konfigurasi (`.idx`, `.vscode`)

- **`.idx/dev.nix`**: Konfigurasi lingkungan pengembangan (alat sistem, ekstensi, dll.).
- **`.idx/mcp.json`**: Konfigurasi untuk server Firebase MCP.
- **`.vscode/settings.json`**: Pengaturan khusus untuk editor VS Code.

### Platform-Specific (`android`, `web`, `test`)

- **`android/`**: Berisi semua file yang terkait dengan platform Android.
    - `app/build.gradle.kts`: Skrip build Gradle yang telah dimodifikasi untuk mendukung *flavors* `user` dan `admin`.
    - `app/google-services.json`: File konfigurasi Firebase yang berisi informasi untuk semua aplikasi Android dalam proyek.
- **`web/`**: Berisi file untuk platform web.
- **`test/`**: Berisi file pengujian untuk aplikasi.

### Direktori Kode Aplikasi (`lib`)

- **`lib/main_user.dart`**: **File entri untuk flavor `user`**. Menginisialisasi Firebase menggunakan `firebase_option_user_dev.dart` dan menjalankan aplikasi `UserApp`.
- **`lib/main_admin.dart`**: **File entri untuk flavor `admin`**. Menginisialisasi Firebase menggunakan `firebase_option_admin_dev.dart` dan menjalankan aplikasi `AdminApp`.

- **`lib/common/`**: Direktori untuk widget atau utilitas yang dapat digunakan kembali di kedua aplikasi.
    - `text_input_field.dart`: Widget `CustomTextInputField` untuk input teks yang konsisten.

- **`lib/user/`**: Direktori untuk semua kode yang khusus untuk aplikasi **User**.
    - **`firebase_option/`**: **(BARU)** Direktori untuk konfigurasi Firebase.
        - `firebase_option_user_dev.dart`: **(BARU)** File konfigurasi Firebase khusus untuk *flavor* **user**.
    - `halaman/`: Berisi file-file halaman (layar) untuk aplikasi user.
        - `login_page.dart`: Halaman login untuk pengguna dengan navigasi ke halaman tambah data.
        - `tambah_data_page.dart`: Halaman untuk menambahkan catatan baru ke Firestore.

- **`lib/admin/`**: Direktori untuk semua kode yang khusus untuk aplikasi **Admin**.
    - **`firebase_option/`**: **(BARU)** Direktori untuk konfigurasi Firebase.
        - `firebase_option_admin_dev.dart`: **(BARU)** File konfigurasi Firebase khusus untuk *flavor* **admin**.
    - `halaman/`: Berisi file-file halaman (layar) untuk aplikasi admin.
        - `dashboard_page.dart`: Halaman dashboard utama untuk admin.
