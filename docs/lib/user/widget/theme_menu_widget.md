# Dokumentasi: ThemeMenuWidget

- **Path:** `lib/user/widget/theme_menu_widget.dart`
- **Tipe:** Widget Presentasional Murni

## 1. Deskripsi

`ThemeMenuWidget` adalah sebuah komponen UI yang menampilkan tombol *popup menu* untuk memungkinkan pengguna memilih tema aplikasi. Pilihan yang tersedia adalah:

-   Terang (`ThemeMode.light`)
-   Gelap (`ThemeMode.dark`)
-   Otomatis (`ThemeMode.system`)

Widget ini bersifat "murni" atau presentasional, artinya ia tidak mengelola *state* sendiri. Semua data yang dibutuhkan (tema saat ini) dan logika (apa yang harus dilakukan saat tema baru dipilih) harus disediakan oleh *parent widget* yang memanggilnya.

## 2. Properti (Props)

| Nama Properti      | Tipe                     | Wajib? | Deskripsi                                                               |
| ------------------ | ------------------------ | ------ | ----------------------------------------------------------------------- |
| `currentThemeMode` | `ThemeMode`              | Ya     | Mode tema yang sedang aktif. Ikon pada tombol akan disesuaikan.         |
| `onThemeSelected`  | `ValueChanged<ThemeMode>` | Ya     | *Callback* yang akan dieksekusi ketika pengguna memilih mode tema baru. |

## 3. Cara Penggunaan

Karena widget ini tidak mengelola *state*-nya sendiri, Anda perlu menyediakannya dari sumber lain. Dalam aplikasi ini, kita menggunakan `ThemeProvider` untuk mengelola tema secara global.

Untuk menggunakan `ThemeMenuWidget`, bungkus widget ini dengan `Consumer<ThemeProvider>` untuk mendapatkan akses ke `themeMode` saat ini dan fungsi `setTheme`.

### Contoh Implementasi:

```dart
// Import yang dibutuhkan
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

// ... di dalam widget build Anda

ListTile(
  leading: const Icon(Icons.brightness_6_outlined),
  title: const Text('Tema Aplikasi'),
  trailing: Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return ThemeMenuWidget(
        currentThemeMode: themeProvider.themeMode,
        onThemeSelected: (mode) {
          // Panggil setTheme dari provider untuk mengubah dan menyimpan tema
          themeProvider.setTheme(mode);
        },
      );
    },
  ),
),
```

Pendekatan ini memastikan bahwa `ThemeMenuWidget` tetap dapat digunakan kembali di mana saja, sementara logika manajemen tema tetap terpusat di `ThemeProvider`.
