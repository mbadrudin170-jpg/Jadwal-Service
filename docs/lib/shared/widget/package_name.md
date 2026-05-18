# Dokumentasi: `lib/shared/widget/package_name.dart`

`PackageNameWidget` adalah `StatelessWidget` yang dirancang untuk menampilkan nama sebuah paket dari operasi asinkron. Berbeda dengan widget `NameFromIdWidget` atau `CustomerNameWidget` yang menerima ID dan melakukan pengambilan data di dalamnya, `PackageNameWidget` mengambil `Future<PackageModel?>` yang sudah ada sebagai argumen. Perbedaan desain ini membuatnya menjadi komponen yang lebih umum dan terdekopel.

---

## Arsitektur dan Desain

1.  **Dekopling dari Sumber Data (Data Source Decoupling)**: Ini adalah karakteristik arsitektur yang paling penting dari widget ini. Dengan menerima `Future` secara langsung alih-alih ID, `PackageNameWidget` tidak tahu dan tidak peduli dari mana data berasal. `Future` tersebut dapat dibuat dari `PackageOperation` (SQLite), `PackageOpFirebase` (Firebase), atau panggilan API di masa depan. Tanggung jawab untuk *memulai* pengambilan data terletak pada widget induk, bukan pada `PackageNameWidget` itu sendiri. Ini membuatnya sangat fleksibel dan dapat digunakan kembali dalam berbagai skenario.

2.  **Pola Komponen "Presenter"**: Karena ia tidak mengambil datanya sendiri, widget ini lebih bertindak sebagai "presenter" untuk hasil dari sebuah `Future`. Ia berfokus murni pada tugas me-render UI untuk berbagai status dari `Future` tersebut (memuat, error, berhasil).

3.  **Manajemen State Asinkron dengan `FutureBuilder`**: Seperti widget serupa lainnya, ia menggunakan `FutureBuilder` untuk secara deklaratif menangani siklus hidup dari `packageFuture`.

4.  **Penanganan Status yang Rinci**:
    -   **Pemuatan (`ConnectionState.waiting`)**: Menampilkan `CircularProgressIndicator` kecil untuk memberikan umpan balik instan bahwa data sedang dalam perjalanan.
    -   **Kegagalan/Tidak Ditemukan (`snapshot.hasError` atau data `null`)**: Dengan anggun menampilkan teks *fallback* "Paket tidak tersedia" dengan warna merah untuk menarik perhatian pada masalah tersebut.
    -   **Keberhasilan**: Menampilkan nama paket dari data yang berhasil diselesaikan.

---

## Penggunaan

Untuk menggunakan widget ini, widget induk harus terlebih dahulu membuat `Future` dan kemudian meneruskannya. Ini memberikan kontrol penuh kepada widget induk atas sumber data.

```dart
// Di dalam widget induk

// 1. Dapatkan instance dari operasi data yang Anda inginkan.
final packageOperation = PackageOperation(); // Bisa juga PackageOpFirebase()

// 2. Buat Future di dalam metode build atau dari state manager.
final Future<PackageModel?> packageFuture = packageOperation.getPackageById(subscription.packageId);

// 3. Teruskan Future ke PackageNameWidget.
return ListTile(
  title: Text('Langganan Aktif:'),
  subtitle: PackageNameWidget(
    packageFuture: packageFuture,
    style: TextStyle(fontSize: 16),
  ),
);
```

---

## Kesimpulan

`PackageNameWidget` adalah contoh yang sangat baik dari komponen UI yang sangat terdekopel dan dapat digunakan kembali. Dengan memisahkan logika *presentasi* dari logika *pengambilan data*, ia mencapai fleksibilitas yang lebih besar daripada widget yang menggabungkan keduanya. Desain ini memungkinkan pengembang untuk dengan mudah menukar sumber data di tingkat yang lebih tinggi tanpa perlu memodifikasi widget tampilan ini sama sekali, yang merupakan inti dari arsitektur perangkat lunak yang baik.
