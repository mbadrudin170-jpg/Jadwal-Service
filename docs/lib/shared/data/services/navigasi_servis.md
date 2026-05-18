# Dokumentasi: `lib/shared/data/services/navigasi_servis.dart`

`NavigasiServis` adalah kelas utilitas statis yang menyediakan solusi untuk salah satu tantangan umum dalam arsitektur aplikasi Flutter: **bagaimana cara menavigasi tanpa memiliki akses ke `BuildContext`?**

---

## Masalah yang Dipecahkan

Di Flutter, navigasi (membuka halaman baru) biasanya dilakukan dengan `Navigator.of(context).push(...)`. Ini bekerja dengan baik dari dalam sebuah *widget*, di mana `context` tersedia secara alami. Namun, ada banyak skenario di mana kita perlu memicu navigasi dari luar pohon widget, seperti:

-   **Dari Layanan Notifikasi**: Saat pengguna mengetuk notifikasi *push* saat aplikasi berjalan (atau di latar belakang), dan kita ingin membuka halaman tertentu yang relevan dengan notifikasi tersebut.
-   **Dari Layanan Latar Belakang (Background Service)**: Setelah sebuah proses sinkronisasi data selesai di latar belakang, kita mungkin ingin menampilkan halaman ringkasan.
-   **Dari Logika Bisnis Kompleks**: Dalam model atau *controller* yang tidak memiliki (dan tidak seharusnya memiliki) akses langsung ke `BuildContext`.

`NavigasiServis` memecahkan masalah ini dengan memegang referensi global ke `NavigatorState` aplikasi.

---

## Desain dan Arsitektur

Desainnya sederhana, elegan, dan efektif, berdasarkan pada `GlobalKey`.

1.  **`GlobalKey<NavigatorState>`**: Ini adalah inti dari solusinya. `GlobalKey` adalah sebuah kunci yang unik di seluruh aplikasi. Ketika kunci ini ditetapkan ke `navigatorKey` dari sebuah `MaterialApp`, Flutter memastikan bahwa kita dapat menggunakan kunci ini dari mana saja untuk mendapatkan akses ke *state* dari widget tersebut (dalam hal ini, `NavigatorState`).

    ```dart
    // Di file main.dart
    MaterialApp(
      navigatorKey: NavigasiServis.navigatorKey, // Kunci dihubungkan di sini
      // ... rute dan konfigurasi lainnya
    )
    ```

2.  **Anggota Statis**: Semua anggota (`navigatorKey`, `context`, `navigateTo`) adalah `static`. Ini berarti kita tidak perlu membuat instance dari `NavigasiServis` untuk menggunakannya. Kita dapat langsung memanggil metodenya, contoh: `NavigasiServis.navigateTo(...)`. Ini membuatnya berfungsi sebagai utilitas global yang mudah diakses.

---

## Anggota Kelas

-   **`navigatorKey`**: `GlobalKey<NavigatorState>` yang harus didaftarkan di `MaterialApp`. Ini adalah "jembatan" antara aplikasi dan layanan navigasi.

-   **`context`**: Sebuah *getter* statis yang menyediakan akses ke `BuildContext` dari `Navigator`. Meskipun tujuan utama layanan ini adalah untuk menavigasi *tanpa* konteks, terkadang memiliki akses ke konteks navigator global bisa berguna untuk menampilkan dialog atau `SnackBar` dari lokasi non-UI. Penggunaannya harus dilakukan dengan hati-hati.

-   **`navigateTo(String routeName, {Object? arguments})`**: Ini adalah metode pembantu (*helper method*) utama. Ia menyederhanakan panggilan navigasi. Daripada menulis `NavigasiServis.navigatorKey.currentState?.pushNamed(...)` setiap saat, kita bisa menulis `NavigasiServis.navigateTo(...)` yang lebih bersih dan mudah dibaca. Penggunaan *null-aware operator* (`?.`) membuatnya aman bahkan jika `currentState` karena alasan tertentu adalah `null`.

---

## Contoh Skenario Penggunaan (Layanan Notifikasi)

Bayangkan sebuah layanan notifikasi menerima data yang berisi `{'type': 'customer_detail', 'customerId': '123'}`.

```dart
// Di dalam logika penanganan notifikasi

void handleNotificationPayload(Map<String, dynamic> payload) {
  if (payload['type'] == 'customer_detail') {
    final customerId = payload['customerId'];

    // Navigasi tanpa context!
    NavigasiServis.navigateTo(
      '/customer_details',
      arguments: customerId,
    );
  }
}
```

Tanpa `NavigasiServis`, melakukan navigasi ini akan sangat rumit, mungkin melibatkan penggunaan *stream* atau *event bus* untuk berkomunikasi dengan UI. Layanan ini menyediakan solusi yang jauh lebih langsung dan bersih.
