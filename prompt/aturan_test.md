Baik, saya akan perbaiki aturan **"Aturan Unit Test Mockito"** agar konsisten dan lebih praktis. Aturan yang baru akan mengizinkan penggunaan **Mockito dengan code generator** (`@GenerateMocks`) karena itu adalah pendekatan standar dan paling efisien dalam proyek Flutter/Dart, serta tetap menjaga prinsip **tidak membuat file mock manual terpisah** dan **file test tetap self‑contained** (hanya bergantung pada file `.mocks.dart` yang dihasilkan di folder yang sama).

---

## 🔄 Aturan Unit Test Mockito (Versi Revisi)

### 1. Library Mocking
- **Wajib menggunakan `package:mockito`** sebagai library mocking utama.
- **Jangan gunakan library mocking lain** (seperti `mocktail`) kecuali ada alasan kuat yang disepakati.

### 2. Pembuatan Mock
- **Gunakan anotasi generator** (`@GenerateMocks`, `@GenerateNiceMocks`, atau `@GenerateMockClasses`) untuk membuat mock class secara otomatis.
- **Contoh:**
  ```dart
  import 'package:mockito/annotations.dart';
  import 'package:mockito/mockito.dart';
  import 'file_test.mocks.dart';

  @GenerateMocks([Repository, Service])
  void main() { ... }
  ```
- **Mock manual** (menulis class `MockX extends Mock implements X`) hanya diperbolehkan jika:
  - Tidak ada dependency eksternal yang perlu dimock.
  - Hanya untuk kasus sangat sederhana (1‑2 method) dan generator dianggap berlebihan.

### 3. File Mock
- File mock yang dihasilkan oleh generator **wajib diletakkan di folder yang sama dengan file test** dan dinamai `[nama_file_test].mocks.dart`.
- **Contoh:** Untuk `test/fitur/akun/akun_provider_test.dart`, file mock yang dihasilkan adalah `test/fitur/akun/akun_provider_test.mocks.dart`.
- **Dilarang** membuat folder `mocks/` atau `test/mocks/` untuk menyimpan file mock secara terpisah.
- **Dilarang** membuat file mock manual dengan nama `*_mock.dart` atau `*_mocks.dart` selain yang dihasilkan oleh generator.

### 4. Proses Build
- Setelah menambahkan anotasi `@GenerateMocks`, **jalankan perintah**:
  ```bash
  flutter pub run build_runner build
  ```
  atau untuk mode watch:
  ```bash
  flutter pub run build_runner watch
  ```
- Pastikan file mock sudah dihasilkan sebelum menjalankan test.

### 5. Penggunaan `any`, `anyNamed`, dan Matcher
- Untuk argumen posisional: gunakan `any`.
- Untuk argumen bernama: gunakan `anyNamed('nama')`.
- Untuk matcher kompleks: gunakan `argThat`, `captureAny`, dll.
- **Contoh valid:**
  ```dart
  when(mock.method(any, namedParam: anyNamed('namedParam'))).thenReturn(...);
  ```

### 6. Fake Class
- Jika membutuhkan implementasi dummy (misal `Stream` atau `Future`), buat `Fake` class di dalam file test yang sama.
- **Contoh:**
  ```dart
  class FakeUser extends Fake implements User {}
  ```

### 7. Test Harus Mandiri (Self‑Contained)
- Setiap file test **hanya boleh mengimpor file `*.mocks.dart` yang dihasilkan dari file itu sendiri**.
- Jangan mengimpor file mock dari file test lain.
- Tidak ada ketergantungan pada folder mock global.

### 8. Prioritas
- **Keterbacaan** dan **kesederhanaan** lebih penting daripada menghindari generator.
- Gunakan generator untuk mengurangi boilerplate, terutama jika ada banyak class yang perlu dimock.

### 9. Larangan
- ❌ Jangan membuat mock manual secara berlebihan.
- ❌ Jangan membuat folder `mocks/` atau `test/mocks/`.
- ❌ Jangan menggunakan `@GenerateMocks` tanpa menjalankan `build_runner`.

---

## 🌟 Ringkasan Singkat (Checklist)

| ✅ Wajib | ❌ Dilarang |
|---------|------------|
| Gunakan Mockito | Gunakan library lain |
| Gunakan `@GenerateMocks` | Buat mock manual panjang |
| Jalankan `build_runner` | Lupa menjalankan generator |
| File `.mocks.dart` di folder yang sama | File mock di folder terpisah |
| Import `.mocks.dart` di file test | Impor dari file test lain |
| Gunakan `anyNamed` untuk named arg | Gunakan `any` untuk named arg |
| Buat `Fake` untuk implementasi dummy | Buat `Fake` di file terpisah |

---

## 📌 Contoh Struktur yang Diinginkan (Baru)

```text
lib/
└── fitur/
    └── akun/
        └── provider/
            └── akun_provider.dart

test/
└── fitur/
    └── akun/
        └── provider/
            ├── akun_provider_test.dart
            └── akun_provider_test.mocks.dart   # dihasilkan oleh build_runner
```

---

Dengan aturan baru ini, Anda tetap menggunakan Mockito secara konsisten, memanfaatkan generator untuk kemudahan, tetapi tetap menjaga agar file test mandiri dan tidak ada mock global. Saya akan sesuaikan semua jawaban saya ke depan dengan aturan ini. Apakah Anda setuju dengan revisi ini?