# Dokumentasi: `lib/shared/widget/financial_summary_widget.dart`

File `financial_summary_widget.dart` menyediakan serangkaian komponen untuk menampilkan ringkasan keuangan. Inti dari file ini adalah `FinancialSummaryWidget`, sebuah kartu (Card) yang dirancang untuk memberikan gambaran visual cepat tentang pemasukan, pengeluaran, dan total saldo. Ia dirancang untuk menjadi komponen UI yang kuat dan dapat digunakan kembali.

---

## Arsitektur dan Desain

File ini terdiri dari tiga bagian utama yang bekerja sama:

1.  **`FinancialSummaryWidget` (Komponen Utama)**: Ini adalah `StatelessWidget` yang berfungsi sebagai komponen "bodoh" (dumb component). Ia menerima semua data yang diperlukannya (`income`, `expense`, `total`) dan flag status (`isLoading`, `errorMessage`) sebagai parameter. Tanggung jawabnya semata-mata adalah untuk me-render UI berdasarkan parameter tersebut. Ia tidak mengambil datanya sendiri, yang membuatnya sangat mudah untuk diuji dan digunakan kembali di berbagai bagian aplikasi (misalnya, di dasbor utama dan di halaman detail dompet).

2.  **`buildFinancialSummaryInfo` (Fungsi Pembantu)**: Ini adalah fungsi pembantu tingkat atas, bukan metode kelas. Ini mengambil data mentah (`label`, `amount`) dan mengembalikannya sebagai widget `Column` kecil yang telah diformat. `FinancialSummaryWidget` menggunakan fungsi ini tiga kali untuk membangun setiap bagian dari ringkasannya. Pendekatan ini mempromosikan penggunaan kembali kode bahkan di dalam file yang sama dan menjaga metode `build` utama tetap bersih.

3.  **`FinancialSummaryExtension` (Metode Utilitas)**: Ini adalah sebuah `extension` pada `BuildContext` yang menambahkan metode `showFinancialSummarySnackbar`. Ini menyediakan cara pintas yang nyaman untuk menampilkan ringkasan keuangan dalam format `SnackBar` dari mana saja yang memiliki akses ke `BuildContext`. Ini menunjukkan bagaimana fungsionalitas terkait dapat dikelompokkan secara logis.

### Penanganan Status yang Kuat

Salah satu fitur terkuat dari `FinancialSummaryWidget` adalah penanganan statusnya yang eksplisit, yang dikelola dalam metode `_buildContent`:
-   **Status Error**: Jika `errorMessage` diberikan, widget akan menampilkan ikon kesalahan, pesan, dan (jika `onRefresh` callback disediakan) tombol "Coba Lagi". Ini memberikan pengalaman pemulihan yang jelas bagi pengguna jika data gagal dimuat.
-   **Status Loading**: Jika `isLoading` adalah `true`, widget menampilkan `CircularProgressIndicator`, memberikan umpan balik visual yang jelas bahwa data sedang dalam proses diambil.
-   **Status Sukses**: Hanya ketika tidak ada error dan tidak sedang memuat, widget akan menampilkan data keuangan yang sebenarnya.

Logika kondisional yang jelas ini membuat widget menjadi sangat tangguh dan informatif dalam segala situasi.

---

## Penggunaan

Widget ini sangat mudah digunakan. Widget induk hanya perlu mengelola state (misalnya, mengambil data dari `bloc` atau `provider`) dan meneruskannya ke `FinancialSummaryWidget`.

```dart
// Contoh penggunaan dalam widget induk
FinancialSummaryWidget(
  isLoading: state.isLoading,
  errorMessage: state.error,
  onRefresh: () => context.read<FinancialBloc>().add(FetchFinancialData()),
  income: state.data.income,
  expense: state.data.expense,
  total: state.data.total,
);
```

---

## Kesimpulan

`FinancialSummaryWidget` adalah contoh yang sangat baik dari komponen UI yang dirancang dengan baik di Flutter. Ia modular, dapat digunakan kembali, dan tangguh karena pemisahan tanggung jawabnya yang jelas (menampilkan data vs. mengambil data) dan penanganan statusnya yang komprehensif. Dengan memecah UI menjadi komponen yang lebih kecil (`buildFinancialSummaryInfo`) dan menyediakan utilitas yang nyaman (`FinancialSummaryExtension`), file ini menyediakan toolkit yang lengkap untuk menampilkan data keuangan secara efektif.
