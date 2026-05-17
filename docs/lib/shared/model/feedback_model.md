
# Dokumentasi: FeedbackModel

## Lokasi File
`lib/shared/model/feedback_model.dart`

## Ringkasan
`FeedbackModel` adalah model data yang digunakan untuk merepresentasikan dan menyimpan umpan balik (feedback) yang diberikan oleh pengguna. Model ini menangkap isi pesan dari pengguna, siapa yang mengirimnya, dan kapan feedback tersebut dibuat. Fitur ini sangat penting untuk menjembatani komunikasi antara pengguna dan admin, memungkinkan admin untuk menerima saran, laporan bug, atau keluhan.

Data feedback disimpan di **Firebase** sebagai sumber utama dan dapat disinkronkan ke **SQLite** di perangkat admin untuk dibaca dan dikelola secara offline.

## Penggunaan
-   `FeedbackOperation`: Mengelola operasi CRUD untuk data feedback di database lokal (SQLite) pada aplikasi admin.
-   `FeedbackOpFirebase`: Mengelola pengiriman data feedback dari aplikasi user ke Firebase.
-   `UserFeedbackForm`: Form di aplikasi user tempat pengguna menulis dan mengirimkan feedback mereka.
-   `FeedbackHistoryUser`: Halaman di aplikasi user untuk melihat riwayat feedback yang pernah dikirim.
-   `FeedbackPage` (Aplikasi Admin): Halaman di aplikasi admin untuk melihat, membaca, dan mengelola semua feedback yang masuk dari pengguna.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap entri feedback. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `content` | `String` | Isi pesan atau konten dari feedback yang dikirimkan pengguna. | Wajib diisi. |
| `date` | `DateTime?` | Tanggal dan waktu saat feedback dibuat oleh pengguna. | |
| `userId` | `String` | ID pelanggan (`CustomerModel`) yang mengirimkan feedback. | Wajib diisi. |
| `updatedAt` | `DateTime?` | Waktu terakhir data ini diperbarui. | |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | Default `false`. |
| `archivedAt` | `DateTime?` | Waktu data ini diarsipkan. | |

## Metode Utama

### `FeedbackModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance `FeedbackModel` dari data `Map` SQLite.

### `Map<String, dynamic> toSqlite()`
Mengonversi `FeedbackModel` menjadi `Map` untuk disimpan di database SQLite.

### `FeedbackModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membuat instance `FeedbackModel` dari data `Map` Firestore. Mengambil `id` dokumen sebagai ID model.

### `Map<String, dynamic> toFirebase()`
Mengonversi `FeedbackModel` menjadi `Map` yang siap dikirim ke Firestore. Metode ini memastikan `DateTime` diubah menjadi `Timestamp` Firebase.

### `copyWith({...})`
Membuat salinan dari objek `FeedbackModel` dengan beberapa field yang diperbarui, berguna untuk menjaga imutabilitas state.

## Contoh Penggunaan
```dart
// Pengguna mengirim feedback dari aplikasi user
final newFeedback = FeedbackModel(
  content: 'Aplikasi sering keluar sendiri saat membuka halaman profil.',
  userId: 'cust-001', // ID pengguna yang sedang login
  date: DateTime.now(),
);

// Mengirim ke Firebase
final firebaseMap = newFeedback.toFirebase();
// await FeedbackOpFirebase.instance.add(newFeedback);

// Admin membaca feedback di aplikasi admin
// final doc = await firestore.collection('feedbacks').doc('some-id').get();
// final feedback = FeedbackModel.fromFirebase(doc.id, doc.data()!);
// print(feedback.content);
// print('Dari: ${await CustomerName.get(feedback.userId)}');
```

Dokumentasi ini menjelaskan bagaimana data feedback distrukturkan dan alur kerjanya, mulai dari pengiriman oleh pengguna hingga dibaca oleh admin, yang merupakan komponen vital untuk peningkatan kualitas layanan.
