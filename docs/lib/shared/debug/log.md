# Dokumentasi: `lib/shared/debug/log.dart`

File ini berisi kelas utilitas `Log` yang digunakan untuk mencatat (logging) pesan secara terstruktur dan berwarna di konsol debug. Kelas ini membantu membedakan berbagai jenis pesan seperti informasi, peringatan, error, dan panggilan API.

## Kelas `Log`

Kelas statis yang menyediakan metode untuk logging. Tidak perlu diinstansiasi.

---

### `Log.info(String message, [Object? data])`

Mencatat pesan informasi umum. Pesan akan ditampilkan dengan warna hijau dan ikon centang (✅).

- **Parameter:**
  - `message` (String): Pesan utama yang ingin ditampilkan.
  - `data` (Object?, opsional): Objek data tambahan (seperti Map atau List) yang akan diformat sebagai JSON dan dilampirkan ke pesan.

- **Contoh Penggunaan:**
  '''dart
  Log.info('Pengguna berhasil login', {'userId': '123'});
  '''

---

### `Log.warning(String message, [Object? data])`

Mencatat pesan peringatan. Berguna untuk kondisi yang tidak terduga tetapi tidak menyebabkan aplikasi berhenti. Pesan akan ditampilkan dengan warna kuning dan ikon peringatan (⚠️).

- **Parameter:**
  - `message` (String): Pesan peringatan yang ingin ditampilkan.
  - `data` (Object?, opsional): Data tambahan yang relevan dengan peringatan.

- **Contoh Penggunaan:**
  '''dart
  Log.warning('Koneksi internet lambat', {'speed': '50kbps'});
  '''

---

### `Log.error(String message, {Object? e, StackTrace? st, Object? data})`

Mencatat error atau pengecualian (exception). Ini adalah prioritas tertinggi dan harus digunakan ketika terjadi kegagalan. Pesan akan ditampilkan dengan warna merah dan ikon silang (❌).

- **Parameter:**
  - `message` (String): Deskripsi error.
  - `e` (Object?, opsional): Objek `Exception` atau `Error` yang ditangkap.
  - `st` (StackTrace?, opsional): `StackTrace` dari error tersebut.
  - `data` (Object?, opsional): Data tambahan yang dapat membantu debugging.

- **Contoh Penggunaan:**
  '''dart
  try {
    // ... kode yang mungkin gagal ...
  } catch (e, st) {
    Log.error('Gagal memproses data', e: e, st: st);
  }
  '''

---

### `Log.api(String path, Map<String, dynamic> data, {required String method})`

Mencatat panggilan jaringan (API request). Membantu dalam men-debug interaksi dengan server. Pesan akan ditampilkan dengan warna cyan dan ikon globe (🌐).

- **Parameter:**
  - `path` (String): Endpoint atau URL dari API yang dipanggil.
  - `data` (Map<String, dynamic>): Data atau body yang dikirim dalam request.
  - `method` (String, required): Metode HTTP yang digunakan (e.g., 'GET', 'POST').

- **Contoh Penggunaan:**
  '''dart
  Log.api(
    '/api/users',
    {'name': 'John Doe'},
    method: 'POST',
  );
  '''
