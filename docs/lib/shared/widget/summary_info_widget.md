# Dokumentasi: `lib/shared/widget/summary_info_widget.dart`

File ini tidak berisi `Widget` dalam bentuk kelas, melainkan sebuah fungsi pembantu (helper function) tingkat atas bernama `buildSummaryInfo`. Fungsi ini dirancang untuk membuat komponen UI kecil yang dapat digunakan kembali yang menampilkan sepotong informasi ringkas, yang terdiri dari label dan nilai numerik yang diformat sebagai mata uang.

Fungsi ini sangat mirip dengan `buildFinancialSummaryInfo` yang ditemukan di `financial_summary_widget.dart`, tetapi lebih generik dan dapat dikonfigurasi.

---

## Arsitektur dan Desain

1.  **Pola Fungsi Pembantu UI (UI Helper Function Pattern)**: Untuk komponen UI yang sangat kecil dan tidak memiliki state internal atau logika yang kompleks, membungkusnya dalam kelas `StatelessWidget` bisa menjadi berlebihan. Pola fungsi pembantu adalah alternatif yang lebih ringan. Fungsi ini hanya mengambil beberapa parameter dan mengembalikan pohon widget (`Column`) yang sudah dikonfigurasi. Ini sederhana, efisien, dan sangat mudah dibaca.

2.  **Ketergantungan pada Abstraksi (Dependency on Abstraction)**: Fungsi ini tidak meng-hardcode logika pemformatan mata uang. Sebaliknya, ia mendelegasikan tugas ini ke `CurrencyFormat.formatCurrency(amount)`. Ini adalah praktik desain yang baik karena memisahkan *presentasi* (bagaimana `buildSummaryInfo` mengatur widget) dari *logika pemformatan*. Jika format mata uang perlu diubah di seluruh aplikasi (misalnya, dari 'Rp' menjadi 'IDR'), perubahan itu hanya perlu dilakukan di satu tempat: kelas `CurrencyFormat`.

3.  **Konfigurasi dan Fleksibilitas**: Meskipun sederhana, fungsi ini menyediakan beberapa titik kustomisasi:
    -   `label` dan `amount`: Konten utama yang akan ditampilkan.
    -   `color`: Memungkinkan pemanggil untuk secara visual membedakan berbagai jenis informasi (mis. hijau untuk pemasukan, merah untuk pengeluaran).
    -   `alignment`: Memberikan kontrol atas perataan horizontal, membuatnya dapat beradaptasi dengan tata letak yang berbeda (mis. rata tengah di `Row`, atau rata kiri di `Column`).
    -   `textKey`: Parameter yang bijaksana untuk pengujian. Dengan mengizinkan pemanggil untuk menyediakan `Key`, ini membuat widget `Text` yang berisi jumlah menjadi mudah ditemukan dalam suite pengujian widget, memungkinkan verifikasi nilai yang ditampilkan.

---

## Penggunaan

Fungsi ini dimaksudkan untuk dipanggil di dalam metode `build` dari widget lain untuk membangun bagian dari UI secara konsisten.

```dart
// Contoh di dalam sebuah Row untuk menampilkan beberapa statistik

Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    buildSummaryInfo(
      context: context,
      label: 'Total Penjualan',
      amount: 1500000,
      color: Colors.blue,
      textKey: const Key('total_sales_summary'), // Untuk pengujian
    ),
    buildSummaryInfo(
      context: context,
      label: 'Keuntungan',
      amount: 450000,
      color: Colors.green,
    ),
  ],
);
```

---

## Kesimpulan

Pola fungsi `buildSummaryInfo` adalah alat yang sangat baik untuk menjaga kode UI tetap DRY (Don't Repeat Yourself) tanpa overhead dari sebuah kelas `Widget`. Dengan menyediakan API yang jelas dan fleksibel serta mendelegasikan tugas-tugas spesifik seperti pemformatan, ia menciptakan cara yang kuat dan dapat dipelihara untuk membangun UI yang konsisten dari potongan-potongan kecil yang dapat dikelola.
