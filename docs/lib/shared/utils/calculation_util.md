# Dokumentasi: `lib/shared/utils/calculation_util.dart`

`CalculationUtil` adalah kelas utilitas statis murni yang berfungsi sebagai pusat untuk semua logika perhitungan yang terkait dengan status dan durasi langganan pelanggan. Tujuannya adalah untuk mengambil tanggal sebagai input dan menghasilkan data yang dapat ditindaklanjuti—seperti sisa hari, teks yang ramah pengguna, dan kode warna visual—yang dapat digunakan oleh UI.

---

## Arsitektur dan Desain

1.  **Kelas Statis (Static Class)**: Semua metode di dalam kelas ini adalah `static`. Ini adalah pilihan desain yang disengaja dan tepat. Metode-metode ini adalah *fungsi murni* (pure functions): output mereka hanya bergantung pada input mereka, dan mereka tidak memiliki efek samping atau bergantung pada keadaan (state) internal apa pun. Ini berarti mereka dapat dipanggil dari mana saja di aplikasi (`CalculationUtil.remainingDays(...)`) tanpa perlu membuat instance dari kelas, menjadikannya sangat efisien dan mudah digunakan.

2.  **Kemampuan Pengujian (Testability) melalui Injeksi Waktu**: Setiap fungsi menerima parameter opsional `{final DateTime? now}`. Ini adalah praktik desain yang sangat baik untuk kemampuan pengujian. Tanpa ini, menguji fungsi-fungsi ini akan menjadi mimpi buruk, karena mereka akan selalu menggunakan `DateTime.now()` yang sebenarnya. Dengan mengizinkan "injeksi" waktu, kita dapat menulis pengujian unit yang andal dan dapat direproduksi untuk setiap skenario yang mungkin:
    -   `test('should return green when 8 days are left', () { ... })`
    -   `test('should return "Berakhir" when time is in the past', () { ... })`

3.  **Pemisahan Tanggung Jawab (Separation of Concerns)**: Kelas ini secara efektif memisahkan **logika bisnis** dari **logika presentasi**. Kode UI (widget) tidak perlu tahu *bagaimana* cara menghitung sisa hari atau *aturan apa* yang menentukan bahwa 7 hari adalah ambang batas untuk warna oranye. Kode UI hanya perlu memanggil metode utilitas dan menampilkan hasilnya. Ini membuat kode UI lebih bersih dan lebih fokus pada pembangunan tata letak.

---

## Metode Utama

-   **`remainingDays(endDate, {now})`**: Ini adalah fungsi dasar. Ia melakukan satu hal: menghitung jumlah hari penuh antara sekarang dan `endDate`. Penggunaan `DateUtils.dateOnly` sangat penting di sini, karena ia mengabaikan komponen waktu dari `DateTime`, hanya membandingkan tanggalnya. Ini mencegah kesalahan "satu hari" (off-by-one errors) yang umum terjadi saat bekerja dengan tanggal. Jika tanggal berakhir sudah lewat, ia akan mengembalikan angka negatif.

-   **`getRemainingActivePeriodText(endDate, {now})`**: Fungsi ini mengubah data mentah (`int` dari `remainingDays`) menjadi string yang dapat dibaca manusia. Ia menerapkan logika berjenjang yang memberikan pengalaman pengguna yang lebih baik:
    -   Jika lebih dari satu hari, tampilkan hari.
    -   Jika kurang dari satu hari tetapi lebih dari satu jam, tampilkan jam.
    -   Jika kurang dari satu jam, tampilkan menit.
    -   Jika sudah berakhir, tampilkan "Berakhir".

-   **`getRemainingActivePeriodColor(endDate, {now})`**: Fungsi ini menerjemahkan sisa waktu menjadi isyarat visual. Ini adalah bagian dari logika bisnis yang didefinisikan secara terpusat:
    -   `> 7 hari`: Hijau (aman)
    -   `1-7 hari`: Oranye (peringatan)
    -   `<= 0 hari`: Merah ( Mendesak/berakhir)
    Menempatkan logika ini di sini memastikan bahwa semua bagian UI yang menampilkan status langganan akan menggunakan skema warna yang sama persis secara konsisten.

-   **`getExpiredPoints({startDate, now})`**: Ini menunjukkan fleksibilitas kelas. Ini menangani aturan bisnis yang berbeda—status "hangus" berdasarkan tanggal *mulai*, bukan tanggal akhir. Ini menunjukkan bagaimana utilitas serupa dapat dikelompokkan bersama dalam satu kelas.

---

## Kesimpulan

`CalculationUtil` adalah komponen penting untuk menjaga basis kode tetap bersih dan dapat dipelihara. Ia mematuhi prinsip DRY (Don't Repeat Yourself) dengan memusatkan logika perhitungan. Dengan menyediakan API yang statis, murni, dan dapat diuji, ia menjadi sumber kebenaran tunggal untuk semua hal yang berkaitan dengan perhitungan waktu langganan, memastikan konsistensi di seluruh aplikasi.
