# Aturan Untuk AI
- Wajib dipatuhi
1. Dilarang melawan perintah user,
2. Dilarang keras tidak mematuhi perintah user.

Komentar Kode
Semua komentar (//, ///, /* */) wajib ditulis dalam bahasa Indonesia, menjelaskan maksud kode dengan singkat.

Bahasa Percakapan
AI wajib merespons dalam bahasa Indonesia untuk semua diskusi,komentar di file, tanya jawab, dan penjelasan.

Nama Kolom Database
Nama kolom database tetap bahasa Inggris dan snake_case (contoh: is_deleted, updated_at, earned_points). Tidak diubah ke bahasa Indonesia.

Penamaan Kode
Nama kelas, fungsi, variabel, parameter, dan file tetap menggunakan bahasa Inggris sesuai konvensi global (contoh: TransactionModel, walletId, ColumnNames).

selalu sertakan path file nya yang dibungkus komentar contoh : `// path : lib/main.dart.

- Selalu ikuti semua perintah user, kalau ada perintah user yang akan membuat kode menjadi error atau tidak konsisten tanyakan lagi keuser apakah user yakin dengan semua perintah itu.

# Logging Rules

Semua file wajib menggunakan Log dari:
lib/shared/debug/log.dart

Dilarang menggunakan:
- print()
- debugPrint()
- developer.log()

Gunakan:
- Log.info()
- Log.warning()
- Log.error()
- Log.api()

Logging wajib ditambahkan pada:
- initState
- dispose
- proses database
- proses async
- API request
- API response
- error handling
- navigasi halaman
- perubahan state penting
- proses CRUD
- validasi penting
- proses cache
- lifecycle widget

Setiap proses penting wajib memiliki log masuk dan log hasil.

Semua catch wajib menggunakan:
Log.error()

Semua async operation penting wajib memiliki logging.

Logging harus menjelaskan:
- apa yang sedang terjadi,
- data apa yang diproses,
- hasil proses,
- dan sumber error jika gagal.


# Snackbar Rules

Dilarang menggunakan:
- ScaffoldMessenger.of(context).showSnackBar()
secara langsung di file lain.

Semua snackbar wajib menggunakan:
lib/shared/utils/snackbar_util.dart

Gunakan:
- SnackBarUtil.success()
- SnackBarUtil.error()
- SnackBarUtil.warning()
- SnackBarUtil.info()

Semua feedback UI kepada user wajib konsisten menggunakan SnackBarUtil.

Snackbar wajib digunakan untuk:
- operasi berhasil,
- operasi gagal,
- validasi penting,
- warning penting,
- feedback async process.

Jangan gunakan snackbar:
- terlalu sering,
- pada proses otomatis background,
- pada event yang spam.