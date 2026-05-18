# Dokumentasi: `lib/shared/model/save_result_model.dart`

`SaveResultModel<T>` adalah model generik yang digunakan untuk membungkus hasil dari operasi penyimpanan atau pembaruan data. Tujuannya adalah untuk memberikan feedback yang jelas dan terstruktur dari sebuah operasi, seperti saat menyimpan data ke database lokal (SQLite) atau ke server (Firestore).

---

## Properti

-   `success` (bool): Menandakan apakah operasi berhasil atau tidak. `true` jika berhasil, `false` jika gagal.
-   `message` (String): Pesan teks yang memberikan detail lebih lanjut tentang hasil operasi. Misalnya, "Data berhasil disimpan" atau "Gagal terhubung ke server".
-   `data` (T?): Data opsional yang dapat dikembalikan bersama dengan hasil operasi. Tipe data `T` bersifat generik, yang berarti model ini dapat mengembalikan berbagai jenis data, seperti objek yang baru saja disimpan atau ID dari data tersebut.

---

## Konsep dan Penggunaan

Model ini sangat berguna untuk standardisasi *return value* dari fungsi-fungsi yang melakukan operasi I/O (Input/Output). Daripada sebuah fungsi hanya mengembalikan `bool` atau `void`, dengan menggunakan `SaveResultModel`, fungsi tersebut dapat memberikan informasi yang lebih kaya:

1.  **Status Keberhasilan yang Jelas**: Properti `success` memberikan indikasi langsung apakah operasi berhasil.
2.  **Pesan Kontekstual**: Properti `message` dapat langsung ditampilkan kepada pengguna melalui `SnackBar` atau dialog, atau dicatat ke dalam log untuk keperluan *debugging*.
3.  **Data Tambahan**: Properti `data` memungkinkan fungsi untuk mengembalikan data yang relevan setelah operasi berhasil, tanpa harus membuat tipe data *return* yang kompleks.

### Contoh Penggunaan:

Sebuah fungsi yang menyimpan data pelanggan mungkin memiliki *return type* `Future<SaveResultModel<CustomerModel>>`. Jika penyimpanan berhasil, ia akan mengembalikan:

```dart
SaveResultModel(
  success: true,
  message: 'Pelanggan berhasil ditambahkan.',
  data: newCustomerObject,
);
```

Jika gagal, ia akan mengembalikan:

```dart
SaveResultModel(
  success: false,
  message: 'Gagal menyimpan: terjadi error pada database.',
);
```
