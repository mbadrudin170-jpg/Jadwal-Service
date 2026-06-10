// path: lib/fitur/akun/docs/akun_docs.md

# Dokumentasi fitur akun

lib/fitur/akun:
docs  page  provider

lib/fitur/akun/docs:
akun_docs.md

lib/fitur/akun/page:
daftar_akun_page.dart

lib/fitur/akun/provider:
akun_provider.dart  akun_provider.freezed.dart  akun_provider.g.dart

# akun_provider
lib/fitur/akun/provider/akun_provider.dart

# Fitur
## Datar Order
1. tujuan nya adalah menampilkan daftar semua  order yang isDeleted nya 0
2. admin : disini admin akan mengambil semua daftar dari database
3. user : disini sebuah daftar hanya akan menampilkan daftar yang userId nya sesuai dengan userId yang ada di userIdProvider.

## Tombol sortir daftar
1. akan menyortir sebuah daftar berdasarkan status nya.

## dialog ubah status
1. fungsi ini hanya dikhususkan hanya untuk admin.
2. fungsi ini akan muncul jika pengguna menekan onLongPress saja.


## dialog opsi ubah status
1. dialog ini akan muncul setelah pengguna mengklik tombol ubah status.
2. dialog ini akan menampilkan beberapa opsi untuk mengubah status data.
3. jika salah satu opsi di pilih maka otomatis akan mengubah kolom status di database dan akan menampilkan dialog konfirmasi.
4. jika pengguna sudah mengkonfirmasi tindakan ini maka akan otomatis menutup semua dialog ini.
5. dan sebuah daftar akan menampilkan daftar terbaru.

## fitur hapus 
1. fitur ini jika ditekan akan menampilkan dialog konfirmasi.
2. jika pengguna mengkonfirmasi maka satu data akan di di soft delete dari database.

# akun_provider
lib/fitur/akun/provider/akun_provider.dart

# update otomatis.
1. fungsi ini bertugas untuk memberitahui ui bahwa sebuah ada data baru dan ui akan merebuild ulang diririnya. tetapi yang akan merebuild ulang hanya data yang berubah saja bukan semuanya.

