# Dokumentasi: `lib/shared/utils/sync_manager.dart`

`SyncManager` adalah kelas fasad (Facade) yang bertindak sebagai antarmuka tingkat tinggi untuk mengelola *timestamp* (penanda waktu) yang terkait dengan proses sinkronisasi data. Ia tidak melakukan sinkronisasi itu sendiri, melainkan menyediakan mekanisme bagi sistem sinkronisasi untuk "mengingat" kapan terakhir kali ia berjalan.

---

## Arsitektur dan Desain

1.  **Pola Fasad (Facade Pattern)**: `SyncManager` adalah contoh klasik dari pola desain Fasad. Ia menyembunyikan detail implementasi dari `PreferenceService` di belakang sebuah API yang lebih bersih dan lebih semantik. Seorang pengembang yang perlu tahu kapan sinkronisasi terakhir terjadi tidak perlu tahu atau peduli bahwa data ini disimpan di `SharedPreferences` (atau database, atau file). Mereka hanya perlu berinteraksi dengan `SyncManager`.

2.  **Pemisahan Tanggung Jawab**: Kelas ini memisahkan tanggung jawab dengan sangat baik:
    -   `PreferenceService` bertanggung jawab atas **bagaimana dan di mana** data disimpan (persisten).
    -   `SyncManager` bertanggung jawab atas **apa** data itu secara konseptual (timestamp sinkronisasi) dan menyediakan akses yang aman dan tercatat (logged).
    -   Sistem sinkronisasi yang sebenarnya (tidak ditampilkan di sini) akan menggunakan `SyncManager` untuk **mengapa** dan **kapan** melakukan sinkronisasi.

3.  **Penanganan Nilai Null yang Aman (Safe Null Handling)**: Metode `getLastDownload` dan `getLastUpload` menunjukkan cara yang sangat baik untuk menangani kemungkinan nilai `null` dari `PreferenceService` (yang terjadi saat aplikasi dijalankan untuk pertama kalinya). Daripada mengembalikan `null` dan memaksa pemanggil untuk melakukan pemeriksaan null, ia mengembalikan nilai *default* yang masuk akal: `DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)`. Ini adalah "Epoch" atau waktu nol dalam komputasi. Ini sangat berguna karena setiap tanggal dan waktu yang valid pasti akan lebih besar dari itu, menyederhanakan logika perbandingan di sisi pemanggil.

4.  **Logging Komprehensif**: Setiap tindakan—baik itu membaca, menulis, atau mereset—dicatat dengan jelas menggunakan `Log`. Ini sangat penting untuk men-debug masalah sinkronisasi, yang terkenal sulit. Log akan menunjukkan dengan tepat timestamp apa yang diminta dan disimpan selama proses sinkronisasi.

---

## Metode dan Alur Kerja

-   **`getLastDownload()` / `getLastUpload()`**: Metode ini akan dipanggil di awal proses sinkronisasi. Sistem sinkronisasi akan meminta timestamp ini dan kemudian mengambil semua data dari server yang telah berubah *setelah* waktu tersebut.

-   **`setLastDownload(time)` / `setLastUpload(time)`**: Setelah proses sinkronisasi berhasil diselesaikan, sistem sinkronisasi akan memanggil metode ini dengan waktu saat ini (`DateTime.now()`). Ini "memajukan" timestamp, memastikan bahwa pada sinkronisasi berikutnya, ia hanya akan mengambil data yang lebih baru lagi.

-   **`resetSyncTime()`**: Ini adalah fungsi utilitas yang kuat, kemungkinan besar untuk tujuan debugging atau untuk menangani situasi di mana pengguna ingin melakukan "sinkronisasi penuh". Dengan mereset waktu ke default, pada sinkronisasi berikutnya, seluruh data akan diunduh/diunggah lagi.

### Contoh Alur Kerja Sinkronisasi Unduh:

```dart
Future<void> performDownloadSync() async {
  final syncManager = SyncManager();
  
  // 1. Dapatkan timestamp terakhir kali kita berhasil sinkronisasi.
  final lastSyncTime = await syncManager.getLastDownload();
  
  // 2. Minta semua data baru dari server sejak waktu itu.
  final newData = await api.fetchNewDataSince(lastSyncTime);
  
  // 3. Simpan data baru ke database lokal.
  await localDatabase.save(newData);
  
  // 4. Jika semuanya berhasil, perbarui timestamp ke waktu saat ini.
  await syncManager.setLastDownload(DateTime.now());
}
```

---

## Kesimpulan

`SyncManager` adalah komponen kecil namun penting dalam arsitektur sinkronisasi yang kuat. Dengan menyediakan API yang bersih, aman, dan dapat diamati untuk mengelola state paling penting dari proses sinkronisasi (yaitu, waktu), ia memungkinkan logika sinkronisasi yang sebenarnya menjadi lebih sederhana dan lebih fokus pada tugas utamanya: memindahkan data.
