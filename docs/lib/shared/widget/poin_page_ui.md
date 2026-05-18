# Dokumentasi: `lib/shared/widget/poin_page_ui.dart`

`PoinPageUi` adalah `StatelessWidget` yang berfungsi sebagai kerangka atau templat UI yang dapat digunakan kembali untuk setiap halaman yang berhubungan dengan poin. Ini adalah contoh yang sangat baik dari widget "presentasional" atau "bodoh" (dumb widget), yang tanggung jawabnya murni untuk tata letak dan penampilan, sementara semua logika bisnis dan manajemen state didelegasikan ke widget induknya.

---

## Arsitektur dan Desain

1.  **Pola Template/Scaffold**: Desain inti dari widget ini adalah untuk menyediakan struktur halaman yang konsisten. Ia mendefinisikan elemen-elemen yang akan sama di semua halaman poin: `AppBar`, `Header` yang menampilkan total poin (`TotalPointCard`), dan `SegmentedButton` untuk navigasi tab. Dengan melakukan ini, ia memastikan bahwa semua layar yang terkait dengan poin memiliki tampilan dan nuansa yang seragam.

2.  **Injeksi Konten (Content Injection)**: Fleksibilitas widget ini berasal dari parameter `contentView`. Widget ini tidak tahu atau tidak peduli konten apa yang akan ditampilkan di area utama. Ia hanya menyediakan `Expanded` `Column` sebagai wadah. Widget induk yang "pintar" (smart widget) yang menggunakan `PoinPageUi` inilah yang memutuskan widget apa yang akan "diinjeksikan" ke dalam `contentView` berdasarkan state aplikasi (misalnya, widget daftar hadiah atau widget riwayat poin).

3.  **Komponen Terkontrol (Controlled Component)**: Manajemen state untuk `SegmentedButton` adalah contoh klasik dari pola komponen terkontrol. `PoinPageUi` tidak mengelola state menu yang dipilih secara internal. Sebaliknya:
    -   Ia menerima menu yang sedang aktif melalui parameter `menuPilihan`.
    -   Ketika pengguna mengetuk segmen yang berbeda, ia tidak mengubah state-nya sendiri. Ia hanya memanggil *callback* `onSelectionChanged` dan mengirimkan pilihan baru ke atas.
    -   Widget induk kemudian memperbarui state-nya dan membangun kembali `PoinPageUi` dengan `menuPilihan` yang baru dan `contentView` yang sesuai. Pola ini membuat aliran data menjadi sangat jelas dan dapat diprediksi (aliran data searah).

4.  **Penggunaan Enum untuk State yang Jelas**: Penggunaan `enum MenuPoin` untuk mendefinisikan kemungkinan pilihan menu (`penukaran`, `riwayat`) jauh lebih unggul daripada menggunakan *string* atau *integer* biasa. Ini memberikan keamanan tipe (type-safety) dan membuat kode lebih mudah dibaca dan dipelihara.

---

## Alur Kerja Penggunaan

Widget induk (`StatefulWidget` atau yang menggunakan state management seperti Bloc/Provider) akan mengelola state saat ini dan logika untuk beralih konten.

```dart
// Di dalam State widget induk

MenuPoin _currentMenu = MenuPoin.penukaran;
int _totalPoints = 0; // Diambil dari database/API

Widget _buildCurrentView() {
  switch (_currentMenu) {
    case MenuPoin.penukaran:
      return RewardCatalogWidget(); // Daftar hadiah yang bisa ditukar
    case MenuPoin.riwayat:
      return PointHistoryWidget(); // Daftar riwayat transaksi poin
  }
}

@override
Widget build(BuildContext context) {
  return PoinPageUi(
    appBarTitle: Text('Poin Saya'),
    totalPoin: _totalPoints,
    menuPilihan: _currentMenu,
    onSelectionChanged: (newSelection) {
      setState(() {
        _currentMenu = newSelection.first;
      });
    },
    contentView: _buildCurrentView(),
  );
}
```

---

## Kesimpulan

`PoinPageUi` adalah komponen arsitektur yang sangat baik. Dengan memisahkan tata letak statis dari konten dinamis dan manajemen state, ia mencapai tingkat penggunaan kembali yang tinggi, memberlakukan konsistensi UI, dan menyederhanakan widget induk. Widget induk dapat fokus sepenuhnya pada *logika bisnis*—data apa yang akan ditampilkan dan bagaimana menanggapi interaksi pengguna—tanpa dibebani oleh detail implementasi tata letak.
