# Dokumentasi: `lib/shared/operasi/feedback_operation.dart`

`FeedbackOperation` adalah kelas yang didedikasikan untuk mengelola data `FeedbackModel`, yang berisi kritik, saran, atau laporan bug dari pengguna aplikasi. Kelas ini berfungsi sebagai jembatan antara input pengguna di aplikasi klien dengan database lokal di perangkat admin.

---

## Alur Kerja dan Tujuan

1.  **Pengumpulan**: Pengguna di aplikasi klien (misalnya, aplikasi pelanggan) dapat mengirimkan feedback melalui sebuah formulir. Saat dikirim, data ini langsung disimpan di koleksi `kritik_saran` di Firestore.

2.  **Sinkronisasi**: Aplikasi admin secara berkala melakukan sinkronisasi. `FeedbackOperation` akan mengunduh data feedback baru dari Firestore dan menyimpannya ke dalam tabel `kritik_saran` di database SQLite lokal.

3.  **Manajemen**: Admin dapat melihat semua feedback yang masuk melalui aplikasi admin. `FeedbackOperation` menyediakan metode untuk membaca, mencari, dan jika perlu, menghapus feedback tersebut dari database lokal.

---

## Metode Utama

### Operasi Tulis (Write)

-   `createFeedback(feedback, {fromServer})`: Menyimpan satu data feedback baru ke database lokal. Biasanya dipanggil selama proses sinkronisasi.

-   `insertOrUpdateBatch(feedbackList, {fromServer})`: Metode utama yang digunakan untuk sinkronisasi. Ini memungkinkan penyimpanan banyak data feedback baru dari server ke database lokal secara efisien dalam satu operasi batch.

-   `deleteFeedback(id, {fromServer})`: Melakukan **hard delete** pada satu item feedback berdasarkan ID-nya.

-   `deleteAllFeedback({fromServer})`: Menghapus **semua** data feedback dari tabel lokal. Operasi ini bersifat destruktif dan digunakan dengan hati-hati.

-   `deleteByUserId(userId, {fromServer})`: Menghapus semua feedback yang dikirim oleh seorang pengguna tertentu.

### Operasi Baca (Read)

-   `getAllFeedback()`: Mengambil semua feedback dari database lokal, diurutkan dari yang paling baru, untuk ditampilkan di aplikasi admin.

-   `getFeedbackById(id)`: Mengambil detail satu feedback spesifik.

-   `getChanges(lastSync)`: Digunakan dalam mekanisme sinkronisasi untuk mengunggah perubahan. Jika ada feedback yang dibuat atau diubah di sisi admin (meskipun jarang), metode ini akan mengambilnya untuk diunggah kembali ke server.

-   `downloadFromFirebase()`: **Metode Statis Penting**. Metode ini tidak berinteraksi dengan database lokal, melainkan langsung menghubungi Firestore untuk mengunduh semua dokumen dari koleksi `kritik_saran`. Ini adalah langkah pertama dalam proses sinkronisasi dari server ke klien.

-   `getFeedbackByIds(ids)`: Mengambil beberapa item feedback berdasarkan daftar ID.

---

## Interaksi dengan `BaseOperation` dan Firebase

-   **Ketergantungan pada `BaseOperation`**: Untuk setiap operasi tulis ke database lokal (`create`, `delete`, `batch update`), `FeedbackOperation` menggunakan `BaseOperation` untuk memastikan data ditandai dengan benar untuk sinkronisasi (meskipun dalam kasus feedback, alur utamanya adalah unduh dari server).

-   **Sumber Data Utama**: Perlu dicatat bahwa untuk feedback, sumber data utamanya ( *source of truth*) adalah Firestore. Data dibuat di Firestore oleh klien, kemudian disalin ke database lokal admin untuk dibaca. Ini berbeda dari data lain seperti pelanggan atau transaksi di mana admin bisa menjadi sumber pembuat data.
