# Disini semua catatan error dan warning serta cara penyelesaiannya

1.  **unawaited_futures**:
    *   **Kendala**: Peringatan ini muncul karena ada pemanggilan fungsi yang mengembalikan `Future` tanpa menggunakan `await`. Ini berisiko karena eksekusi kode berlanjut tanpa menunggu hasilnya, yang bisa menyebabkan *race condition* atau perilaku tak terduga, terutama dalam pengujian.
    *   **Penyelesaian**: Menambahkan `await` pada setiap pemanggilan fungsi yang mengembalikan `Future` untuk memastikan operasi selesai sebelum melanjutkan ke baris berikutnya. Contohnya pada `NavigasiServis.navigateTo` di file `test/shared/data/services/navigasi_servis_test.dart`.

2.  **subtype_of_sealed_class** & **avoid_implementing_value_types**:
    *   **Kendala**: Terjadi *error* saat mencoba membuat *mock* untuk kelas-kelas dari *package* `cloud_firestore` (seperti `Query`, `DocumentReference`, `DocumentSnapshot`) menggunakan `mocktail`. Kelas-kelas ini bersifat `sealed` atau meng-override operator `==`, sehingga tidak boleh diimplementasikan atau di-extend secara sembarangan untuk *mocking*.
    *   **Penyelesaian**:
        1.  Menambahkan anotasi `@TestOn('vm')` di bagian atas file pengujian. Ini memastikan *test* hanya berjalan di lingkungan Dart VM, di mana aturan ini dapat ditangani dengan lebih fleksibel untuk keperluan *mocking*.
        2.  Memastikan kelas *mock* menggunakan `implements` dan bukan `extends` saat mengimplementasikan *interface* dari *package* lain, sesuai dengan praktik standar `mocktail`.

3.  **Kesalahan Tipe & Mocking pada File Pengujian**:
    *   **Kendala**: Banyak file pengujian (contoh: `unggah_data_test.dart`) mengalami `argument_type_not_assignable` dan *error* lainnya karena *mock* tidak dikonfigurasi dengan benar. Misalnya, sebuah *mock method* diharapkan mengembalikan `Future<void>` tetapi diatur untuk mengembalikan `void`.
    *   **Penyelesaian**: Melakukan refaktor pada file pengujian dengan:
        *   Mendefinisikan ulang kelas *mock* dengan benar untuk `cloud_firestore` dan `sqflite`.
        *   Menggunakan `registerFallbackValue` untuk tipe data kompleks yang digunakan dalam `when()`.
        *   Memperbaiki tipe kembalian pada `thenAnswer()` agar sesuai dengan definisi fungsi aslinya.
        *   Menyesuaikan *lint rules* seperti `prefer_final_parameters` dan `unnecessary_async` untuk meningkatkan kualitas kode.

4.  **Linting Umum dan Error Lainnya**:
    *   **Kendala**: Proyek memiliki banyak isu minor dari *analyzer* seperti `missing_required_argument`, `undefined_named_parameter`, `directives_ordering`, dan `avoid_redundant_argument_values`.
    *   **Penyelesaian**: Secara sistematis memperbaiki setiap file satu per satu sesuai dengan laporan dari `flutter analyze` untuk memastikan kode menjadi lebih bersih, konsisten, dan bebas dari *error* potensial.

5.  **Ketidakcocokan Model dengan Data Dummy di Test**:
    *   **Kendala**: File test sering menggunakan data *dummy* yang tidak cocok dengan model terbaru, terutama setelah model di-*refactor*. Contoh: `PengaturanModel` tidak lagi memiliki properti `namaAplikasi`, `namaPerusahaan`, dll., tetapi `pengaturan_operasi_test.dart` masih menggunakannya. Begitu pula `PesananModel` yang menggunakan `idPelanggan`/`idPaket` tetapi test menggunakan `pelangganId`/`paketId`.
    *   **Penyelesaian**:
        *   Sebelum menulis test, selalu periksa definisi model terkini di `lib/shared/model/`.
        *   Sesuaikan data *dummy* dan pemanggilan konstruktor di test agar cocok dengan parameter yang ada, termasuk yang bersifat *required*.
        *   Untuk file `pengaturan_operasi_test.dart`, properti diubah menjadi `intervalSinkronisasiOtomatis`, `hapusOtomatisDataArsip`, `modePemeliharaan`, `infoPemeliharaan`.
        *   Untuk file `pesanan_operasi_test.dart`, properti diubah menjadi `idPelanggan`, `idPaket`, dan map-nya menggunakan key `id_pelanggan`, `id_paket` sesuai `toSqlite()`.

6.  **Konstruktor Kelas Operasi Tidak Mendukung Dependency Injection untuk Testing**:
    *   **Kendala**: Kelas seperti `SubKategoriOperasi`, `TransaksiOperasi`, dan `PengaturanOperasi` sering kali membuat instance `OperasiDasar` dan `DatabaseHelper` langsung di dalam konstruktor tanpa opsi untuk injeksi dari luar. Akibatnya, test tidak bisa memasukkan *mock* dan memunculkan error `undefined_named_parameter` (`operasiDasar`, `dbHelper`).
    *   **Penyelesaian**:
        *   Menambahkan parameter opsional di konstruktor untuk menerima `OperasiDasar` dan `DatabaseHelper`. Jika tidak diberikan, gunakan *instance default* (`DatabaseHelper.instance`, `OperasiDasar()`).
        *   Contoh: `SubKategoriOperasi({DatabaseHelper? dbHelper, OperasiDasar? operasiDasar}) : dbHelper = dbHelper ?? DatabaseHelper.instance, _operasiDasar = operasiDasar ?? OperasiDasar();`
        *   Untuk `TransaksiOperasi`, ubah `_dbHelper` dari `static` menjadi *instance variable* agar bisa diinjeksi tanpa menggangu operasi normal.

7.  **Tipe Data `isDeleted` di Model SQLite**:
    *   **Kendala**: Pada model seperti `SubKategoriModel`, `isDeleted` di SQLite disimpan sebagai `INTEGER` (0 atau 1), tetapi di Dart model menggunakan tipe `bool`. Test yang masih menggunakan `0` atau `1` langsung akan menyebabkan `argument_type_not_assignable`.
    *   **Penyelesaian**: Selalu gunakan `true`/`false` untuk properti `isDeleted` saat membuat instance model di Dart. Konversi ke `0`/`1` hanya terjadi di method `toSqlite()`. Saat membuat data *dummy* untuk *mock* database, gunakan `0`/`1` karena itulah yang disimpan di SQLite.

8.  **Verifikasi Navigasi di Widget Test**:
    *   **Kendala**: Saat memverifikasi navigasi dengan `NavigatorObserver`, sering terjadi error karena pemanggilan `route.builder` dengan argumen yang salah. Kode asli menggunakan `r.settings as BuildContext` yang tidak valid karena `settings` bertipe `RouteSettings`, bukan `BuildContext`.
    *   **Penyelesaian**: Gunakan `tester.element(find.byType(MaterialApp))` sebagai *BuildContext* yang valid untuk memanggil `lastRoute.builder(...)`. Kemudian periksa tipe widget hasilnya dengan `isA<DetailVersiApkUser>()`. Contoh:
      ```dart
      final lastRoute = navigatorObserver.pushedRoutes.last as MaterialPageRoute;
      final builtWidget = lastRoute.builder(tester.element(find.byType(MaterialApp)));
      expect(builtWidget, isA<DetailVersiApkUser>());
```

9.  **strict_raw_type di List**:
    *   **Kendala**: Peringatan `strict_raw_type` muncul ketika sebuah `List` dibuat tanpa memberikan argumen tipe eksplisit. Contoh: `List` atau `List<dynamic>` pada `List<Map<String, dynamic>>`. Hal ini membuat kode kurang aman karena *analyzer* tidak dapat memverifikasi tipe elemen di dalam `List`.
    *   **Penyelesaian**: Selalu berikan argumen tipe yang spesifik saat mendeklarasikan `List`. Contohnya, ubah `final listSub = hasilMap['id_sub_kategori'] as List;` menjadi `final listSub = hasilMap['id_sub_kategori'] as List<Map<String, dynamic>>;` di file `test/shared/model/kategori_model_test.dart` untuk memastikan keamanan tipe.
10. 📝 Perubahan
Menambahkan satu baris komentar sebelum setiap // ignore: yang menjelaskan secara singkat mengapa ignore diperlukan.

Tidak ada perubahan logika atau struktur test.