# Dokumentasi: `lib/shared/theme/app_icons.dart`

`AppIcons` adalah kelas utilitas yang berfungsi sebagai perpustakaan ikon terpusat untuk keseluruhan aplikasi. Tujuannya adalah untuk mendefinisikan semua ikon yang digunakan di seluruh UI dalam satu lokasi yang mudah diakses dan dikelola.

---

## Arsitektur dan Desain

1.  **Pola Kelas Utilitas Statis**: `AppIcons` dirancang sebagai kelas yang tidak dapat diinstansiasi. Ini dicapai dengan mendeklarasikan konstruktor privat `AppIcons._();`. Semua anggotanya adalah `static const`, yang berarti mereka diakses langsung melalui nama kelas (mis. `AppIcons.save`) tanpa perlu membuat objek dari kelas tersebut. Pola ini sangat efisien karena tidak ada alokasi memori yang tidak perlu untuk instance, dan ikon-ikon tersebut menjadi konstanta waktu kompilasi.

2.  **Single Source of Truth (Satu Sumber Kebenaran)**: Dengan memusatkan semua definisi ikon di sini, kelas ini menjadi "satu-satunya sumber kebenaran" untuk aset ikon. Manfaat utamanya adalah kemudahan pemeliharaan. Jika tim desain memutuskan untuk mengganti ikon "simpan" dari `Icons.save` menjadi ikon kustom lainnya, perubahan hanya perlu dilakukan di satu baris dalam file ini. Perubahan tersebut akan secara otomatis diterapkan di setiap bagian dari aplikasi yang mereferensikan `AppIcons.save`.

3.  **Abstraksi dari Implementasi**: Kode UI yang menggunakan ikon-ikon ini (mis. `Icon(AppIcons.add)`) tidak perlu tahu `IconData` spesifik apa yang sedang digunakan (`Icons.add`). Kode tersebut hanya meminta "ikon tambah". `AppIcons` bertindak sebagai lapisan abstraksi yang memisahkan *niat* (menampilkan ikon tambah) dari *implementasi* (ikon spesifik yang digunakan). Ini membuat kode UI lebih bersih, lebih deskriptif, dan lebih mudah beradaptasi terhadap perubahan desain.

4.  **Pengorganisasian dan Keterbacaan**: Ikon-ikon di dalam kelas ini dikelompokkan secara logis ke dalam beberapa kategori menggunakan komentar (mis. `Navigasi & Aksi Umum`, `Menu Utama & Halaman`, `Entitas & Status`). Pengorganisasian ini tidak memengaruhi fungsionalitas tetapi secara drastis meningkatkan keterbacaan dan kemudahan navigasi file, memudahkan pengembang untuk menemukan ikon yang mereka butuhkan atau untuk melihat ikon apa yang sudah tersedia.

5.  **Dokumentasi Inline**: Setiap ikon atau grup ikon dilengkapi dengan komentar dokumentasi Dart (`///`). Ini memungkinkan IDE seperti VS Code atau Android Studio untuk menampilkan deskripsi tooltip saat pengembang mengarahkan kursor ke `AppIcons.search`, meningkatkan pengalaman pengembangan.

---

## Penggunaan

Penggunaan kelas ini sangat mudah dan konsisten di seluruh aplikasi.

```dart
// Contoh 1: Di dalam sebuah IconButton
IconButton(
  icon: Icon(AppIcons.logout), // Menggunakan ikon logout yang sudah diabstraksi
  tooltip: 'Keluar',
  onPressed: () {
    // Logika untuk logout
  },
);

// Contoh 2: Di dalam sebuah ListTile
ListTile(
  leading: Icon(AppIcons.settings), // Menggunakan ikon pengaturan
  title: Text('Pengaturan Aplikasi'),
  onTap: () {
    // Navigasi ke halaman pengaturan
  },
);

// Contoh 3: Menampilkan status
Icon(
  AppIcons.success, // Menggunakan ikon sukses
  color: Colors.green, // Warna masih bisa disesuaikan di tempat penggunaan
);

```

---

## Kesimpulan

`AppIcons` adalah contoh textbook tentang cara mengelola aset bersama dalam proyek Flutter. Ia mempromosikan konsistensi, mengurangi duplikasi, menyederhanakan pemeliharaan, dan meningkatkan keterbacaan kode. Dengan menyediakan lapisan abstraksi yang sederhana namun kuat, ia membebaskan komponen UI dari detail implementasi ikon, membuat keseluruhan basis kode lebih bersih dan lebih tangguh terhadap perubahan desain di masa depan.
