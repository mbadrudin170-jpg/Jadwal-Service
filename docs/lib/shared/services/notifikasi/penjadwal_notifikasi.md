# Dokumentasi: `lib/shared/services/notifikasi/penjadwal_notifikasi.dart`

`PenjadwalNotifikasi` adalah kelas utilitas statis yang memiliki satu tanggung jawab spesifik dan penting: mengelola siklus hidup notifikasi yang terkait dengan langganan pengguna. Ini bertindak sebagai "lapisan logika bisnis" di atas `NotifikasiServis` yang lebih generik.

Daripada menyebarkan logika penjadwalan di berbagai tempat, kelas ini memusatkannya, membuatnya mudah untuk dipanggil, diperbarui, dan di-debug.

---

## Tujuan dan Arsitektur

**Tujuan**: Secara proaktif memberi tahu pengguna tentang peristiwa penting dalam siklus langganan mereka untuk meningkatkan retensi dan pengalaman pengguna.

**Arsitektur**: `PenjadwalNotifikasi` mengoordinasikan tiga komponen berbeda:
1.  **`BuildContext`**: Diperlukan untuk mendapatkan akses ke `NotifikasiServis` yang disediakan oleh `Provider`.
2.  **`NotifikasiServis`**: Layanan tingkat rendah yang sebenarnya melakukan pekerjaan teknis untuk mendaftarkan atau membatalkan notifikasi di tingkat OS.
3.  **`TransactionOpFirebase`**: Layanan operasi data yang mengambil informasi langganan terakhir pengguna dari Firebase, yang merupakan "sumber kebenaran" (source of truth).

---

## Logika Inti: `aturNotifikasiLangganan()`

Metode statis tunggal ini berisi seluruh logika bisnis. Alur kerjanya adalah sebagai berikut:

1.  **Dapatkan Dependensi**: Mengambil `NotifikasiServis` dari `Provider`.

2.  **Hasilkan ID Unik dan Deterministik**: ID untuk notifikasi akhir periode dan tengah periode dibuat menggunakan `userId.hashCode`. Ini sangat penting:
    -   **Deterministik**: Untuk pengguna yang sama, `userId.hashCode` akan selalu menghasilkan ID yang sama. Ini memungkinkan kita untuk secara andal **memperbarui** atau **membatalkan** notifikasi yang ada tanpa perlu menyimpan ID-nya di tempat lain.
    -   **Unik per Pengguna**: Pengguna yang berbeda akan memiliki ID notifikasi yang berbeda, mencegah tumpang tindih.

3.  **Ambil Status Langganan**: Memanggil `transactionOperation.getLatestPaidTransactionByUserId(userId)` untuk mendapatkan data langganan lunas terbaru yang akan datang.

4.  **Logika Percabangan Utama**:
    -   **JIKA ada langganan aktif di masa depan**:
        a.  **Jadwalkan Notifikasi Akhir Periode**: `notifikasiServis.perbaruiJadwalNotifikasi()` dipanggil untuk mengatur notifikasi tepat pada tanggal `endDate`. Menggunakan `perbaruiJadwalNotifikasi` (bukan `jadwalNotifikasi`) adalah pilihan yang cerdas; ini secara atomik membatalkan jadwal lama (jika ada) dan menetapkan yang baru, menangani kasus perpanjangan atau perubahan paket dengan mulus.
        b.  **Jadwalkan Notifikasi Tengah Periode**: Logika menghitung titik tengah durasi langganan. Jika tanggal tersebut masih di masa depan, ia menjadwalkan notifikasi pengingat "separuh jalan". Jika tanggal tersebut sudah lewat, ia secara proaktif membatalkan notifikasi tengah periode yang mungkin sudah ada dari jadwal sebelumnya.

    -   **JIKA TIDAK ada langganan aktif**:
        a.  **Bersihkan Jadwal**: Kelas ini mengasumsikan pengguna tidak lagi berlangganan. Ia secara proaktif memanggil `notifikasiServis.batalNotifikasi()` untuk kedua ID (akhir dan tengah periode) untuk memastikan tidak ada notifikasi sisa yang akan muncul secara tidak terduga.

5.  **Penanganan Error (Fail-Safe)**: Seluruh logika dibungkus dalam `try-catch`. Jika terjadi kesalahan apa pun (misalnya, gagal mengambil data dari Firebase), blok `catch` akan berusaha untuk membatalkan semua notifikasi yang diketahui untuk pengguna tersebut. Ini adalah perilaku yang aman, mencegah notifikasi yang berpotensi salah atau usang tetap terjadwal.

---

## Alur Pemanggilan

Metode `aturNotifikasiLangganan` harus dipanggil pada setiap titik di mana status langganan pengguna mungkin telah berubah. Tempat-tempat yang ideal untuk memanggilnya adalah:

-   Setelah pengguna berhasil melakukan login.
-   Setelah pengguna berhasil menyelesaikan pembayaran untuk paket baru atau perpanjangan.
-   Saat aplikasi dimulai, sebagai bagian dari proses inisialisasi pengguna.

---

## Kesimpulan

`PenjadwalNotifikasi` adalah contoh bagus dari pemisahan tanggung jawab (Separation of Concerns). Ia tidak tahu *bagaimana* cara menampilkan notifikasi atau *bagaimana* cara mengambil data dari Firebase. Ia hanya tahu *logika bisnis* tentang *kapan* notifikasi harus dijadwalkan berdasarkan status langganan. Dengan memusatkan logika ini, aplikasi menjadi lebih mudah dipelihara dan diperluas di masa depan.
