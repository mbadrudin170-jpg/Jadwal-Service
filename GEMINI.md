Berikut aturan naming versi **ringkas, jelas, dan siap dipakai** (Indonesia clean style):

---

# 📌 Aturan Naming (Class, Variabel, Parameter, Function)

## 1. CLASS → “Siapa / tanggung jawabnya”

* Gunakan **kata benda**
* Nama mewakili **entitas atau layanan**

**Contoh:**

* `Pelanggan`
* `Transaksi`
* `AutentikasiService`
* `SinkronisasiData`

---

## 2. VARIABEL → “Menyimpan apa”

* Gunakan **kata benda**
* Harus spesifik, jangan umum

**Contoh:**

* `namaPelanggan`
* `jumlahTagihan`
* `statusPembayaran`

❌ Hindari: `data`, `info`, `temp`

---

## 3. PARAMETER → “Input untuk apa”

* Sama seperti variabel, tapi konteksnya input fungsi
* Harus jelas maknanya

**Contoh:**

```dart
void simpanPelanggan(String namaPelanggan)
```

---

## 4. FUNCTION → “Melakukan apa”

* Gunakan **kata kerja + objek**
* Harus menggambarkan aksi

**Contoh:**

* `hitungTagihan()`
* `ambilDataPelanggan()`
* `simpanTransaksi()`
* `hapusPelanggan()`

---

## 5. ATURAN UMUM

* Pakai **bahasa Indonesia konsisten**
* Jangan campur Inggris & Indonesia dalam satu konsep
* Nama harus **jelas tanpa perlu baca isi kode**
* Jangan terlalu panjang, tapi juga jangan ambigu

---

## 6. TEST CEPAT (wajib sebelum pakai nama)

Tanya:

* Apakah langsung paham fungsinya?
* Apakah ini jelas tanpa konteks tambahan?
* Apakah ini tidak bisa disalahartikan?

Kalau “tidak yakin” → ganti nama.

---
// path prompt/permintaan_benarkan_kode.md


1. Ai jangan memberikan kode lengkap nya cukup berikan potongan kode bari keberapa kode yang salah dan benar nya saja.
2. setiap kode yang salah harus di jelaskan kenapa salah dan kode yang benar kenapa harus begini.
lib
├── admin
│   ├── app_admin.dart
│   ├── data
│   │   └── sqlite.dart
│   ├── firebase_option
│   │   ├── firebase_option_admin_dev.dart
│   │   └── firebase_option_admin_prod.dart
│   ├── halaman
│   │   ├── lainnya
│   │   │   └── halaman_migrasi.dart
│   │   ├── tab
│   │   │   └── lainnya.dart
│   │   ├── tes
│   │   │   ├── contoh_simpan_status.dart
│   │   │   └── halaman_tes.dart
│   │   └── widget
│   │       ├── box_info.dart
│   │       ├── container_with_border.dart
│   │       ├── nama_paket_widget.dart
│   │       ├── nama_pelanggan.dart
│   │       └── tombol_aksi.dart
│   ├── halaman_utama.dart
│   ├── providers
│   │   ├── customer_provider.dart
│   │   └── customer_provider.g.dart
│   └── splash_screen_admin.dart
├── data_dummy
│   ├── data_dummy.dart
│   ├── dummy_dompet.dart
│   ├── dummy_kategori.dart
│   ├── dummy_paket.dart
│   ├── dummy_pelanggan.dart
│   ├── dummy_sub_kategori.dart
│   ├── dummy_transaksi.dart
│   └── halaman_data_dummy.dart
├── fitur
│   ├── akun
│   │   ├── page
│   │   │   └── daftar_akun_page.dart
│   │   └── provider
│   │       ├── akun_provider.dart
│   │       ├── akun_provider.freezed.dart
│   │       └── akun_provider.g.dart
│   ├── alarm
│   │   ├── penjadwal_alarm.dart
│   │   └── penjadwal_alarm_android.dart
│   ├── app_role
│   │   ├── role_util.dart
│   │   └── role_util.g.dart
│   ├── background
│   │   ├── alarm_utils.dart
│   │   ├── layanan_latar_belakang.dart
│   │   └── layanan_peluncuran.dart
│   ├── database
│   │   └── provider
│   │       ├── operasi_sqlite_provider.dart
│   │       └── operasi_sqlite_provider.g.dart
│   ├── dompet
│   │   ├── model
│   │   │   ├── dompet_model.dart
│   │   │   └── dompet_model.freezed.dart
│   │   ├── operasi
│   │   │   └── dompet_op_sqlite.dart
│   │   ├── page
│   │   │   ├── detail_dompet.dart
│   │   │   ├── dompet_page.dart
│   │   │   └── form_dompet.dart
│   │   └── provider
│   │       ├── dompet_provider.dart
│   │       ├── dompet_provider.freezed.dart
│   │       └── dompet_provider.g.dart
│   ├── event
│   │   ├── model
│   │   │   ├── event_model.dart
│   │   │   └── event_model.freezed.dart
│   │   ├── operasi
│   │   │   └── event_op_supabase.dart
│   │   └── page
│   │       ├── detail_event_a.dart
│   │       ├── event_page_a.dart
│   │       ├── event_page_u.dart
│   │       └── manage_announcement_page.dart
│   ├── feedback
│   │   ├── model
│   │   │   ├── feedback_model.dart
│   │   │   └── feedback_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── feedback_op_firebase.dart
│   │   │   ├── feedback_op_global.dart
│   │   │   └── feedback_op_sqlite.dart
│   │   ├── page
│   │   │   ├── feedback_detail.dart
│   │   │   ├── feedback_page.dart
│   │   │   └── form_feedback.dart
│   │   └── provider
│   │       ├── feedback_provider.dart
│   │       ├── feedback_provider.freezed.dart
│   │       └── feedback_provider.g.dart
│   ├── info_perangkat
│   │   ├── enum
│   │   │   └── arsitektur_apk.dart
│   │   ├── model
│   │   │   ├── info_perangkat_model.dart
│   │   │   └── info_perangkat_model.freezed.dart
│   │   ├── page
│   │   │   ├── info_apk_page_user.dart
│   │   │   └── tentang_aplikasi.dart
│   │   └── service
│   │       ├── layanan_info_paket.dart
│   │       └── layanan_info_perangkat.dart
│   ├── kategori
│   │   ├── enum
│   │   │   └── tipe_kategori.dart
│   │   ├── model
│   │   │   ├── kategori_model.dart
│   │   │   ├── kategori_model.freezed.dart
│   │   │   ├── sub_kategori_model.dart
│   │   │   └── sub_kategori_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── kategori_op_sqlite.dart
│   │   │   └── sub_kategori_op_sqlite.dart
│   │   └── page
│   │       ├── form_kategori.dart
│   │       └── kategori.dart
│   ├── notifikasi
│   │   ├── enum
│   │   │   └── tipe_notifikasi_enum.dart
│   │   ├── layanan_notifikasi.dart
│   │   ├── model
│   │   │   ├── notifikasi_model.dart
│   │   │   └── notifikasi_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── notifikasi_op_firebase.dart
│   │   │   └── notifikasi_op_sqlite.dart
│   │   ├── pengingat_paket_belum_lunas.dart
│   │   └── penjadwal_notifikasi.dart
│   ├── order
│   │   ├── enum
│   │   │   └── status_order_enum.dart
│   │   ├── model
│   │   │   ├── order_model.dart
│   │   │   └── order_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── order_op_firebase.dart
│   │   │   ├── order_op_global.dart
│   │   │   └── order_op_sqlite.dart
│   │   ├── page
│   │   │   └── order_page.dart
│   │   └── provider
│   │       ├── order_provider.dart
│   │       ├── order_provider.freezed.dart
│   │       └── order_provider.g.dart
│   ├── paket
│   │   ├── core
│   │   │   └── perhitungan_paket.dart
│   │   ├── enum
│   │   │   └── tipe_durasi_paket.dart
│   │   ├── model
│   │   │   ├── paket_model.dart
│   │   │   └── paket_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── paket_op_firebase.dart
│   │   │   ├── paket_op_global.dart
│   │   │   └── paket_op_sqlite.dart
│   │   ├── page
│   │   │   ├── detail_paket.dart
│   │   │   ├── form_paket.dart
│   │   │   └── paket.dart
│   │   └── provider
│   │       ├── paket_provider.dart
│   │       ├── paket_provider.freezed.dart
│   │       └── paket_provider.g.dart
│   ├── pelanggan
│   │   ├── core
│   │   │   └── layanan_aktivitas_user.dart
│   │   ├── helper
│   │   │   ├── pengurut_pelanggan.dart
│   │   │   └── pengurut_pelanggan.g.dart
│   │   ├── model
│   │   │   ├── pelanggan_model.dart
│   │   │   └── pelanggan_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── pelanggan_op_firebase.dart
│   │   │   ├── pelanggan_op_global.dart
│   │   │   └── pelanggan_op_sqlite.dart
│   │   ├── page
│   │   │   ├── admin
│   │   │   │   ├── detail_pelanggan_a.dart
│   │   │   │   ├── form_pelanggan.dart
│   │   │   │   └── pelanggan_page.dart
│   │   │   └── user
│   │   │       └── detail_pelanggan_u.dart
│   │   ├── provider
│   │   │   ├── pelanggan_provider.dart
│   │   │   ├── pelanggan_provider.freezed.dart
│   │   │   └── pelanggan_provider.g.dart
│   │   └── widget
│   │       └── detail_pelanggan_ui.dart
│   ├── pelanggan_aktif
│   │   ├── helper
│   │   │   ├── pengurut_pelanggan_aktif.dart
│   │   │   └── pengurut_pelanggan_aktif.g.dart
│   │   ├── model
│   │   │   ├── detail_pelanggan_aktif_model.dart
│   │   │   ├── pelanggan_aktif_model.dart
│   │   │   └── pelanggan_aktif_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── pelanggan_aktif_op_firebase.dart
│   │   │   └── pelanggan_aktif_op_sqlite.dart
│   │   ├── page
│   │   │   ├── detail_pelanggan_aktif.dart
│   │   │   ├── form_pelanggan_aktif.dart
│   │   │   └── pelanggan_aktif_page.dart
│   │   └── provider
│   │       ├── pelanggan_aktif_provider.dart
│   │       ├── pelanggan_aktif_provider.freezed.dart
│   │       └── pelanggan_aktif_provider.g.dart
│   ├── poin
│   │   ├── operasi
│   │   │   ├── firebase_points_data_source.dart
│   │   │   └── sqlite_points_data_source.dart
│   │   ├── page
│   │   │   └── halaman_poin.dart
│   │   ├── provider
│   │   │   ├── poin_provider.dart
│   │   │   └── points_page_data_source.dart
│   │   ├── service
│   │   │   └── poin_transaction_service.dart
│   │   └── widget
│   │       ├── kartu_total_poin.dart
│   │       └── ui_halaman_poin.dart
│   ├── riwayat_aktivasi
│   │   ├── page
│   │   │   ├── detail_riwayat_aktivasi.dart
│   │   │   ├── form_riwayat_aktivasi.dart
│   │   │   └── riwayat_aktivasi_paket.dart
│   │   └── provider
│   │       ├── detail_langganan_provider.dart
│   │       ├── detail_langganan_provider.freezed.dart
│   │       ├── detail_langganan_provider.g.dart
│   │       ├── riwayat_aktivasi_paket_provider.dart
│   │       └── riwayat_aktivasi_paket_provider.g.dart
│   ├── settings
│   │   ├── model
│   │   │   ├── settings_model.dart
│   │   │   └── settings_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── settings_op_firebase.dart
│   │   │   └── settings_op_sqlite.dart
│   │   ├── page
│   │   │   ├── form_settings.dart
│   │   │   ├── settings_page_a.dart
│   │   │   └── settings_page_u.dart
│   │   └── provider
│   │       ├── settings_provider.dart
│   │       ├── settings_provider.freezed.dart
│   │       └── settings_provider.g.dart
│   ├── sinkronisasi
│   │   ├── layanan_cek_sinkronisasi.dart
│   │   ├── layanan_unduh_data.dart
│   │   ├── layanan_unduhan_awal.dart
│   │   ├── layanan_unggah_data.dart
│   │   └── pengelola_sinkronisasi.dart
│   ├── speedtest
│   │   ├── page
│   │   │   └── uji_kecepatan_page.dart
│   │   └── provider
│   │       ├── ping_provider.dart
│   │       ├── ping_provider.g.dart
│   │       ├── uji_kecepatan_provider.dart
│   │       ├── uji_kecepatan_provider.freezed.dart
│   │       └── uji_kecepatan_provider.g.dart
│   ├── statistik
│   │   ├── model
│   │   │   └── paket_terlaris_model.dart
│   │   └── page
│   │       └── statistik_page_a.dart
│   ├── transaksi
│   │   ├── enum
│   │   │   ├── status_pembayaran.dart
│   │   │   └── tipe_transaksi.dart
│   │   ├── helper
│   │   │   ├── pengurut_transaksi.dart
│   │   │   └── pengurut_transaksi.g.dart
│   │   ├── model
│   │   │   ├── transaksi_model.dart
│   │   │   └── transaksi_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── transaksi_op_firebase.dart
│   │   │   ├── transaksi_op_global.dart
│   │   │   └── transaksi_op_sqlite.dart
│   │   ├── page
│   │   │   ├── detail_transaksi_a.dart
│   │   │   ├── detail_transaksi_u.dart
│   │   │   ├── form_transaksi.dart
│   │   │   ├── transaksi_a.dart
│   │   │   └── transaksi_u.dart
│   │   ├── provider
│   │   │   ├── transaksi_provider.dart
│   │   │   ├── transaksi_provider.freezed.dart
│   │   │   └── transaksi_provider.g.dart
│   │   └── widget
│   │       └── daftar_transaksi_widget.dart
│   ├── versi_apk
│   │   ├── model
│   │   │   ├── versi_apk_model.dart
│   │   │   └── versi_apk_model.freezed.dart
│   │   ├── operasi
│   │   │   ├── versi_apk_op_firebase.dart
│   │   │   └── versi_apk_op_sqlite.dart
│   │   ├── page
│   │   │   ├── detail_versi_apk.dart
│   │   │   ├── form_versi_apk.dart
│   │   │   ├── update_apk_page_u.dart
│   │   │   └── versi_apk_page.dart
│   │   └── service
│   │       ├── layanan_cek_update_apk.dart
│   │       └── update_service.dart
│   └── whatsapp
│       └── info_paket.dart
├── main
│   ├── main_admin
│   │   ├── admin_dev.dart
│   │   └── admin_prod.dart
│   └── main_user
│       ├── user_dev.dart
│       └── user_prod.dart
├── services
│   └── firebase_migration
│       └── firebase_migration_service.dart
├── shared
│   ├── common
│   │   └── teks.dart
│   ├── constant
│   │   ├── app_constants.dart
│   │   ├── nama_kolom.dart
│   │   └── nama_tabel.dart
│   ├── data
│   │   └── services
│   │       ├── layanan_navigasi.dart
│   │       ├── layanan_pengecekan_data_baru.dart
│   │       └── layanan_preferensi.dart
│   ├── debug
│   │   ├── global_key.dart
│   │   └── log.dart
│   ├── enum
│   │   ├── app_role_enum.dart
│   │   └── url_supabase_enum.dart
│   ├── export
│   │   ├── enum.dart
│   │   ├── model.dart
│   │   ├── op_firebase.dart
│   │   ├── operation.dart
│   │   └── theme.dart
│   ├── model
│   │   ├── has_id.dart
│   │   ├── status_model.dart
│   │   ├── status_model.freezed.dart
│   │   ├── status_unggah_model.dart
│   │   └── status_unggah_model.freezed.dart
│   ├── operasi
│   │   ├── firebase_operasi
│   │   │   ├── base_op_firebase.dart
│   │   │   ├── firebase_operation_provider
│   │   │   │   ├── firebase_operation_provider.dart
│   │   │   │   └── firebase_operation_provider.g.dart
│   │   │   └── status_op_firebase.dart
│   │   └── sqlite_operasi
│   │       ├── base_op_sqlite.dart
│   │       ├── pembersihan_data_operasi.dart
│   │       └── status_upload_op_sqlite.dart
│   ├── providers
│   │   ├── shared_providers.dart
│   │   └── shared_providers.g.dart
│   ├── services
│   │   ├── arsipkan_langganan_kadaluarsa_service.dart
│   │   ├── koneksi_internet_service.dart
│   │   └── layanan_penyimpanan_gambar.dart
│   ├── theme
│   │   ├── app_colors.dart
│   │   ├── app_icons.dart
│   │   ├── app_sizes.dart
│   │   ├── app_theme.dart
│   │   ├── tema_provider.dart
│   │   └── tema_provider.g.dart
│   ├── utils
│   │   ├── durasi_util.dart
│   │   ├── format_util.dart
│   │   ├── parser_util.dart
│   │   ├── perhitungan_util.dart
│   │   └── toast_util.dart
│   └── widget
│       ├── input
│       │   ├── formatter
│       │   │   └── mac_address_formatter.dart
│       │   ├── input_angka.dart
│       │   ├── input_mac_address.dart
│       │   ├── input_password.dart
│       │   ├── input_rupiah.dart
│       │   ├── input_teks.dart
│       │   └── input_telepon.dart
│       ├── nama_pelanggan_widget.dart
│       ├── package_name.dart
│       ├── pemilih_tanggal_waktu_widget.dart
│       ├── summary_info_widget.dart
│       └── widget_ringkasan_keuangan.dart
├── tes_fitur
│   ├── tes_iklan.dart
│   └── tes_notifikasi.dart
└── user
    ├── app_user.dart
    ├── firebase_option
    │   ├── firebase_option_user_dev.dart
    │   └── firebase_option_user_prod.dart
    ├── maintenance_page.dart
    ├── page
    │   ├── login_page.dart
    │   ├── main_page.dart
    │   ├── profile_page.dart
    │   └── splash_screen_user.dart
    ├── providers
    │   ├── ad_providers.dart
    │   ├── ad_providers.g.dart
    │   ├── user_provider.dart
    │   └── user_provider.g.dart
    ├── services
    │   └── storage
    │       └── layanan_penyimpanan_lokal.dart
    └── widget
        ├── ads
        │   ├── app_open
        │   │   ├── app_lifecycle_reactor.dart
        │   │   ├── app_open_ad_service.dart
        │   │   └── id_app_open_ads.dart
        │   ├── banner
        │   │   ├── banner_ads_widget.dart
        │   │   └── id_banner_ads.dart
        │   ├── bonused_mediator
        │   │   ├── bonused_mediator_ad_service.dart
        │   │   └── id_bonused_mediator_ads.dart
        │   └── interstitial
        │       ├── id_interstitial_ads.dart
        │       └── layanan_iklan_interstisial.dart
        ├── data_not_found.dart
        ├── error_message.dart
        └── theme_menu_widget.dart
test
├── admin
│   ├── app_admin_test.dart
│   ├── app_admin_test.mocks.dart
│   ├── data
│   │   ├── sqlite_test.dart
│   │   └── sqlite_test.mocks.dart
│   ├── firebase_option
│   │   ├── firebase_option_admin_dev_test.dart
│   │   └── firebase_option_admin_prod_test.dart
│   ├── halaman
│   │   ├── detail
│   │   │   ├── detail_dompet_test.dart
│   │   │   ├── detail_dompet_test.mocks.dart
│   │   │   ├── detail_paket_test.dart
│   │   │   └── detail_paket_test.mocks.dart
│   │   ├── event
│   │   ├── form
│   │   │   ├── form_kategori_test.dart
│   │   │   ├── form_pelanggan_aktif_test.dart
│   │   │   ├── form_pelanggan_test.dart
│   │   │   └── form_pelanggan_test.mocks.dart
│   │   ├── lainnya
│   │   │   ├── halaman_migrasi_test.dart
│   │   │   ├── paket_test.dart
│   │   │   ├── paket_test.mocks.dart
│   │   │   └── riwayat_aktivasi_paket_test.dart
│   │   ├── tab
│   │   │   └── lainnya_test.dart
│   │   ├── tes
│   │   │   ├── contoh_simpan_status_test.dart
│   │   │   └── halaman_tes_test.dart
│   │   └── widget
│   │       ├── box_info_test.dart
│   │       ├── container_with_border_test.dart
│   │       ├── nama_paket_widget_test.dart
│   │       ├── nama_pelanggan_test.dart
│   │       └── tombol_aksi_test.dart
│   ├── halaman_utama_test.dart
│   ├── halaman_utama_test.mocks.dart
│   ├── model
│   │   └── best_selling_package_test.dart
│   ├── providers
│   │   ├── customer_provider_test.dart
│   │   ├── customer_provider_test.mocks.dart
│   │   ├── detail_langganan_provider_test.dart
│   │   ├── detail_langganan_provider_test.mocks.dart
│   │   ├── riwayat_aktivasi_paket_provider_test.dart
│   │   └── riwayat_aktivasi_paket_provider_test.mocks.dart
│   └── splash_screen_admin_test.dart
├── data_dummy
│   ├── data_dummy_test.dart
│   └── halaman_data_dummy_test.dart
├── fitur
│   ├── akun
│   │   ├── page
│   │   │   ├── daftar_akun_page_test.dart
│   │   │   └── daftar_akun_page_test.mocks.dart
│   │   └── provider
│   │       ├── akun_provider_test.dart
│   │       └── akun_provider_test.mocks.dart
│   ├── alarm
│   │   ├── alarm_scheduler_test.dart
│   │   ├── alarm_scheduler_test.mocks.dart
│   │   └── android_alarm_scheduler_test.dart
│   ├── background
│   │   ├── alarm_utils_test.dart
│   │   ├── layanan_latar_belakang_test.dart
│   │   └── layanan_peluncuran_test.dart
│   ├── database
│   │   └── provider
│   │       ├── operasi_sqlite_provider_test.dart
│   │       └── operasi_sqlite_provider_test.mocks.dart
│   ├── dompet
│   │   ├── model
│   │   │   ├── item_dompet_model_test.dart
│   │   │   ├── item_transaksi_model_test.dart
│   │   │   ├── transaksi_model_test.dart
│   │   │   └── wallet_model_test.dart
│   │   ├── operasi
│   │   │   ├── dompet_op_sqlite_test.dart
│   │   │   └── dompet_op_sqlite_test.mocks.dart
│   │   ├── page
│   │   │   ├── dompet_page_test.dart
│   │   │   └── form_dompet_test.dart
│   │   └── state
│   │       ├── state_item_transaksi_test.dart
│   │       ├── state_transaksi_test.dart
│   │       └── state_wallet_test.dart
│   ├── event
│   │   ├── model
│   │   │   └── event_model_test.dart
│   │   ├── operasi
│   │   │   └── event_op_supabase_test.dart
│   │   └── page
│   │       ├── detail_event_a_test.dart
│   │       ├── detail_event_a_test.mocks.dart
│   │       ├── event_page_a_test.dart
│   │       └── event_page_a_test.mocks.dart
│   ├── feedback
│   │   ├── model
│   │   │   └── feedback_model_test.dart
│   │   └── operasi
│   │       ├── feedback_op_firebase_test.dart
│   │       ├── feedback_op_firebase_test.mocks.dart
│   │       ├── feedback_op_sqlite_test.dart
│   │       └── feedback_op_sqlite_test.mocks.dart
│   ├── info_perangkat
│   │   ├── model
│   │   │   └── info_perangkat_model_test.dart
│   │   └── service
│   │       ├── layanan_info_paket_test.dart
│   │       ├── layanan_info_perangkat_test.dart
│   │       └── layanan_info_perangkat_test.mocks.dart
│   ├── notfikasi
│   │   ├── enum
│   │   │   └── tipe_notifikasi_enum_test.dart
│   │   ├── layanan_notifikasi_test.dart
│   │   ├── layanan_notifikasi_test.mocks.dart
│   │   ├── penjadwal_notifikasi_test.dart
│   │   └── penjadwal_notifikasi_test.mocks.dart
│   ├── pelanggan
│   │   ├── core
│   │   │   ├── layanan_aktivitas_user_test.dart
│   │   │   └── layanan_aktivitas_user_test.mocks.dart
│   │   ├── operasi
│   │   │   ├── pelanggan_op_firebase_test.dart
│   │   │   ├── pelanggan_op_firebase_test.mocks.dart
│   │   │   ├── pelanggan_op_sqlite_test.dart
│   │   │   └── pelanggan_op_sqlite_test.mocks.dart
│   │   ├── page
│   │   │   ├── admin
│   │   │   │   └── detail_pelanggan_a_test.dart
│   │   │   └── user
│   │   │       ├── detail_pelanggan_u_test.dart
│   │   │       └── detail_pelanggan_u_test.mocks.dart
│   │   └── widget
│   │       └── detail_pelanggan_ui_test.dart
│   ├── router
│   │   ├── operasi
│   │   │   └── router_op_sqlite_test.dart
│   │   └── provider
│   │       └── router_provider_test.dart
│   ├── settings
│   │   ├── operasi
│   │   │   ├── settings_op_sqlite_test.dart
│   │   │   └── settings_op_sqlite_test.mocks.dart
│   │   ├── settings_model_test.dart
│   │   └── settings_op_firebase_test.dart
│   ├── sinkronisasi
│   │   ├── layanan_unduh_data_test.dart
│   │   ├── layanan_unggah_data_test.dart
│   │   └── provider
│   │       └── sinkronisasi_provider_test.dart
│   ├── speedtest
│   │   └── provider
│   │       ├── ping_provider_test.dart
│   │       └── uji_kecepatan_provider_test.dart
│   ├── statistik
│   │   ├── model
│   │   │   └── paket_terlaris_model_test.dart
│   │   ├── operasi
│   │   │   └── statistik_op_sqlite_test.dart
│   │   └── provider
│   │       └── statistik_provider_test.dart
│   ├── transaksi
│   │   ├── model
│   │   │   └── transaksi_model_test.dart
│   │   ├── operasi
│   │   │   ├── transaksi_op_firebase_test.dart
│   │   │   └── transaksi_op_sqlite_test.dart
│   │   └── provider
│   │       └── transaksi_provider_test.dart
│   ├── versi_apk
│   │   ├── model
│   │   │   └── versi_apk_model_test.dart
│   │   ├── operasi
│   │   │   ├── versi_apk_op_firebase_test.dart
│   │   │   └── versi_apk_op_sqlite_test.dart
│   │   ├── provider
│   │   │   └── versi_apk_provider_test.dart
│   │   └── service
│   │       └── update_service_test.dart
│   └── whatsapp
│       ├── info_paket_test.dart
│       └── info_paket_test.mocks.dart
├── image_mock_http_client.dart
└── shared
    ├── data
    │   └── services
    │       ├── layanan_cek_sinkronisasi_test.dart
    │       ├── layanan_cek_sinkronisasi_test.mocks.dart
    │       ├── layanan_navigasi_test.dart
    │       ├── layanan_preferensi_test.dart
    │       ├── pengecekan_data_baru_service_test.dart
    │       └── pengecekan_data_baru_service_test.mocks.dart
    ├── debug
    │   └── log_test.dart
    ├── operasi
    │   ├── firebase_operasi
    │   │   ├── base_op_firebase_test.dart
    │   │   ├── notifikasi_op_firebase_test.dart
    │   │   ├── notifikasi_op_firebase_test.mocks.dart
    │   │   └── status_op_firebase_test.dart
    │   └── sqlite_operasi
    │       ├── base_op_sqlite_test.dart
    │       └── base_op_sqlite_test.mocks.dart
    └── utils
        ├── durasi_util_test.dart
        ├── format_util_test.dart
        ├── parser_util_test.dart
        ├── pengelola_sinkronisasi_test.dart
        ├── perhitungan_util_test.dart
        └── toast_util_test.dart

226 directories, 433 files
tree is not installed, but available in the following packages, pick one to run it, Ctrl+C to cancel.
# // path: prompt/aturan_analisis_error.md


---

### Aturan Analisis error
1. jika terjadi error  maka AI di wajibkan meminta file yang bersangkutan kepada pengguna, misalnya jika ada sebuah kode yang error didalam file maka AI harus melakukan analysa apakah kode ini menggunakan kode dari file lain, maka AI wajib meminta ke pengguna dan  membaca file yang di import nya itu
2. kalau AI tidak tahu path file yang di import nya itu maka AI di wajibkan menjalankan `ls -R lib test` agar bisa lebih akurat lagi.
3. AI hanya berfokus pada kode yang bermasalah saja dan jangan menyentuh kode yang tidak bermasalah, tetapi kalau kode tersebut bersangkutan dengan kode yang error maka AI boleh menyentuh kode itu.
Baik, saya akan perbaiki aturan **"Aturan Unit Test Mockito"** agar konsisten dan lebih praktis. Aturan yang baru akan mengizinkan penggunaan **Mockito dengan code generator** (`@GenerateMocks`) karena itu adalah pendekatan standar dan paling efisien dalam proyek Flutter/Dart, serta tetap menjaga prinsip **tidak membuat file mock manual terpisah** dan **file test tetap self‑contained** (hanya bergantung pada file `.mocks.dart` yang dihasilkan di folder yang sama).

---

## 🔄 Aturan Unit Test Mockito (Versi Revisi)

### 1. Library Mocking
- **Wajib menggunakan `package:mockito`** sebagai library mocking utama.
- **Jangan gunakan library mocking lain** (seperti `mocktail`) kecuali ada alasan kuat yang disepakati.

### 2. Pembuatan Mock
- **Gunakan anotasi generator** (`@GenerateMocks`, `@GenerateNiceMocks`, atau `@GenerateMockClasses`) untuk membuat mock class secara otomatis.
- **Contoh:**
  ```dart
  import 'package:mockito/annotations.dart';
  import 'package:mockito/mockito.dart';
  import 'file_test.mocks.dart';

  @GenerateMocks([Repository, Service])
  void main() { ... }
  ```
- **Mock manual** (menulis class `MockX extends Mock implements X`) hanya diperbolehkan jika:
  - Hanya untuk kasus sangat sederhana (1‑2 method) dan generator dianggap berlebihan.

### 3. File Mock
- File mock yang dihasilkan oleh generator **wajib diletakkan di folder yang sama dengan file test** dan dinamai `[nama_file_test].mocks.dart`.
- **Contoh:** Untuk `test/fitur/akun/akun_provider_test.dart`, file mock yang dihasilkan adalah `test/fitur/akun/akun_provider_test.mocks.dart`.
- **Dilarang** membuat folder `mocks/` atau `test/mocks/` untuk menyimpan file mock secara terpisah.
- **Dilarang** membuat file mock manual dengan nama `*_mock.dart` atau `*_mocks.dart` selain yang dihasilkan oleh generator.

### 4. Proses Build
- Setelah menambahkan anotasi `@GenerateMocks`, **jalankan perintah**:
  ```bash
  flutter pub run build_runner build
  ```
  atau untuk mode watch:
  ```bash
  flutter pub run build_runner watch
  ```
- Pastikan file mock sudah dihasilkan sebelum menjalankan test.

### 5. Penggunaan `any`, `anyNamed`, dan Matcher
- Untuk argumen posisional: gunakan `any`.
- Untuk argumen bernama: gunakan `anyNamed('nama')`.
- Untuk matcher kompleks: gunakan `argThat`, `captureAny`, dll.
- **Contoh valid:**
  ```dart
  when(mock.method(any, namedParam: anyNamed('namedParam'))).thenReturn(...);
  ```

### 6. Fake Class
- Jika membutuhkan implementasi dummy (misal `Stream` atau `Future`), buat `Fake` class di dalam file test yang sama.
- **Contoh:**
  ```dart
  class FakeUser extends Fake implements User {}
  ```

### 7. Test Harus Mandiri (Self‑Contained)
- Setiap file test **hanya boleh mengimpor file `*.mocks.dart` yang dihasilkan dari file itu sendiri**.
- Jangan mengimpor file mock dari file test lain.
- Tidak ada ketergantungan pada folder mock global.

### 8. Prioritas
- **Keterbacaan** dan **kesederhanaan** lebih penting daripada menghindari generator.
- Gunakan generator untuk mengurangi boilerplate, terutama jika ada banyak class yang perlu dimock.

### 9. Larangan
- ❌ Jangan membuat mock manual secara berlebihan.
- ❌ Jangan membuat folder `mocks/` atau `test/mocks/`.
- ❌ Jangan menggunakan `@GenerateMocks` tanpa menjalankan `build_runner`.

---

## 🌟 Ringkasan Singkat (Checklist)

| ✅ Wajib | ❌ Dilarang |
|---------|------------|
| Gunakan Mockito | Gunakan library lain |
| Gunakan `@GenerateMocks` | Buat mock manual panjang |
| Jalankan `build_runner` | Lupa menjalankan generator |
| File `.mocks.dart` di folder yang sama | File mock di folder terpisah |
| Import `.mocks.dart` di file test | Impor dari file test lain |
| Gunakan `anyNamed` untuk named arg | Gunakan `any` untuk named arg |
| Buat `Fake` untuk implementasi dummy | Buat `Fake` di file terpisah |

---

## 📌 Contoh Struktur yang Diinginkan (Baru)

```text
lib/
└── fitur/
    └── akun/
        └── provider/
            └── akun_provider.dart

test/
└── fitur/
    └── akun/
        └── provider/
            ├── akun_provider_test.dart
            └── akun_provider_test.mocks.dart   # dihasilkan oleh build_runner
```

---

Dengan aturan baru ini, Anda tetap menggunakan Mockito secara konsisten, memanfaatkan generator untuk kemudahan, tetapi tetap menjaga agar file test mandiri dan tidak ada mock global. Saya akan sesuaikan semua jawaban saya ke depan dengan aturan ini. Apakah Anda setuju dengan revisi ini?Tolong pahami dan selalu ingat aturan ini

1. jika kode yang sedang dikerjakan ternyata diimport dari file lain AI wajib melihat file file yang diimport itu,jika file yang di import juga menggunakan kode yang dimpoert dari file lain maka AI wajib membaca nya juga. agar tidak salah file AI harus menajalankan ls -R lib atau ls -R test jika itu file test.
2. penulisan kode, AI wajib menuliskan kode yang sesuai dengan versi paket saya di pubspec.yaml, kalau bisa lihat dokumentasinya dengan menjalankan read_package_uris dan pub_dev_search,
3. kode di setiap file harus konsisten.
# Aturan untuk melakukan build apk dengan Alias

## Alur Kerja Build (WAJIB DIIKUTI)

**1. SEBELUM Build: Cek Versi Terakhir**

Sebelum menjalankan build, **selalu periksa riwayat versi terakhir** di file log untuk menentukan `[nama-versi]` dan `[nomor-build]` yang akan digunakan.

-   **Lihat riwayat Admin:** `docs/build/build_apk_admin.md`
-   **Lihat riwayat User:** `docs/build/build_apk_user.md`

**2. SAAT Build: Jalankan Perintah Alias**

Gunakan alias yang sesuai dengan `nama-versi` dan `nomor-build` yang sudah Anda tentukan di langkah 1.

**3. SETELAH Build Berhasil: Catat Versi Baru**

Setelah proses build selesai **tanpa error**, segera **WAJIB catat versi baru** ke dalam file log yang sesuai.

1.  Buka file log yang relevan (misal, `docs/build/build_apk_admin.md`).
2.  **Tambahkan entri baru** di baris paling atas dengan format berikut:

    ```
    # [Tanggal dan Jam Build]
    version: [nama-versi]+[nomor-build]
    ```

    **Contoh Entri Baru:**
    ```
    # 19 Mei 24, 10:30
    version: 1.0.1+3
    ```

Tindakan ini **krusial** untuk menjaga riwayat build tetap akurat dan menghindari konflik versi.

---

## Detail Perintah Build

### Build Apk Admin Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbuildadmin [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.1+2, maka build selanjutnya adalah 1.0.2+3
fbuildadmin 1.1.1 1
```

### Build Apk User Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbuilduser [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.0+1, maka build selanjutnya adalah 1.0.1+2
fbuilduser 1.1.1 1

```

---

## Lokasi Output

File APK yang dihasilkan akan berada di direktori: `build/app/outputs/flutter-apk/`.
# // path: prompt/penyisipan_log_sanckbar.md
---

**Aturan Logging dan Toast untuk Asisten Koding Flutter:**

0. **Prasyarat: Pahami Implementasi**
   - Sebelum menyisipkan kode apa pun, **baca dan pahami** isi file berikut:
     - `lib/shared/debug/log.dart` (kelas `Log`)
     - `lib/shared/utils/toast_util.dart` (kelas `ToastUtil`)
   - Gunakan hanya method dan tanda tangan yang tersedia di kedua kelas tersebut.
   - Jangan membuat asumsi tentang fitur yang tidak ada; ikuti persis API yang disediakan.

1. **Logging**
   - Jangan pernah menggunakan `print()`, `debugPrint()`, atau `log()` bawaan.
   - Gunakan class `Log` dari path `lib/shared/debug/log.dart`.
   - Class `Log` punya method:
     - `Log.info(pesan, data?)` untuk informasi
     - `Log.warning(pesan, data?)` untuk peringatan
     - `Log.error(pesan, {e, st, data})` untuk error (bisa menyertakan exception & stacktrace)
   - Selalu sertakan pesan yang jelas, dan jika ada data relevan (response API, objek state, dll) masukkan sebagai parameter `data`.

2. **Toast**
   - Jangan pernah langsung pakai `ScaffoldMessenger.of(context).showSnackBar(...)` atau widget `SnackBar`.
   - Gunakan class `ToastUtil` dari path `lib/shared/utils/toast_util.dart`.
   - `ToastUtil` punya method statis:
     - `ToastUtil.success(context, pesan, {logData})`
     - `ToastUtil.error(context, pesan, {logData})`
     - `ToastUtil.warning(context, pesan, {logData})`
     - `ToastUtil.info(context, pesan, {logData})`
   - `logData` bersifat opsional, hanya untuk log internal (tidak tampil ke user), tapi tetap cantumkan jika ada data tambahan.
   - Method-method ini otomatis mencatat log sesuai tipe, jadi setelah memanggil `ToastUtil` **tidak perlu** lagi memanggil `Log` secara manual, **kecuali** untuk error (lihat poin 3).

3. **Penanganan Error (WAJIB)**
   - Setiap kali terjadi error, **harus** melakukan dua hal:
     a. **Log error** menggunakan `Log.error(...)` agar tercatat detail exception, stacktrace, dan data.
     b. **Tampilkan Toast error** menggunakan `ToastUtil.error(context, pesanUser, ...)` agar pengguna mendapat notifikasi.
   - **Jangan hanya** memanggil `Log.error` tanpa Toast, atau sebaliknya. Keduanya wajib ada.
   - **Aturan linter**: Gunakan `on` untuk menangkap tipe exception spesifik. Jangan gunakan `catch` polos tanpa `on`. Minimal `on Exception catch (e, st)` atau lebih spesifik. Jika tidak yakin, gunakan `on Object catch (e, st)`.
   - Toast untuk error harus menampilkan pesan yang ramah pengguna, sementara `Log.error` bisa berisi detail teknis.

4. **Pencatatan di Setiap Alur Kerja (WAJIB)**
   - Setiap fungsi atau metode yang melakukan aksi signifikan (misal: fetch data, submit form, proses perhitungan, navigasi dengan data) **harus**:
     a. Mencatat log di awal proses (contoh: `Log.info('Memulai mengambil data pengguna')`).
     b. Setelah selesai, memberikan notifikasi ke pengguna menggunakan `ToastUtil` (contoh: `ToastUtil.success(context, 'Data berhasil diambil')`).
   - Untuk operasi yang hanya memberi informasi tanpa efek besar, cukup gunakan `ToastUtil.info()` (sudah termasuk log).
   - Untuk operasi yang menghasilkan peringatan (misal data kosong), gunakan `ToastUtil.warning()`.
   - **Jangan sampai** ada aksi penting yang tidak meninggalkan jejak log atau tidak memberi tahu pengguna melalui Toast.

5. **Impor**
   - Setiap file yang membutuhkan log atau toast wajib mengimpor:
     ```dart
     import 'package:wifi/shared/debug/log.dart';
     import 'package:wifi/shared/utils/toast_util.dart';
     ```

6. **Hanya Menyisipkan Log dan Toast (Jangan Mengubah Kode Asli)**
   - Fokus hanya menambahkan pemanggilan `Log` dan `ToastUtil` sesuai aturan di atas.
   - **Jangan mengubah** struktur, logika, alur navigasi, nama fungsi/variabel, atau perilaku kode yang sudah ada.
   - Jika operasi penting belum memiliki penanganan error, tambahkan **blok `try`/`on Exception catch` minimal** untuk mencatat log dan menampilkan toast error, tetapi **biarkan isi blok `try` sama persis** dengan kode asli (tidak diubah).
   - Jangan menambahkan fungsionalitas baru, refaktor, atau "perbaikan" yang tidak diminta.
# Aturan Penggunaan Radio Button Flutter

1. **Dilarang menggunakan widget `Radio`.**
2. **Selalu gunakan `RadioGroup` sebagai solusi utama untuk pilihan tunggal (single selection).**
3. **Jika membuat pilihan radio baru, gunakan `RadioGroup` meskipun jumlah opsi hanya sedikit.**
4. **Jangan merekomendasikan `Radio` dalam contoh kode, dokumentasi, maupun saran implementasi.**
5. **Jangan mengganti `RadioGroup` yang sudah ada menjadi `Radio`.**
6. **Jika menemukan `Radio` pada kode lama, rekomendasikan migrasi ke `RadioGroup`.**
7. **Pisahkan tampilan (label, ikon, deskripsi) dari komponen radio agar lebih fleksibel dibanding `Radio`.**
8. **Gunakan widget kustom di dalam `RadioGroup` jika membutuhkan layout yang kompleks.**
9. **Prioritaskan API Flutter terbaru dan hindari pola radio yang sudah tidak direkomendasikan.**
10. **Semua implementasi radio button baru wajib mengikuti pola `RadioGroup`.**
11. **Jika pengguna meminta radio button, asumsikan solusi yang diinginkan adalah `RadioGroup`, bukan `Radio`.**
12. **Jangan memberikan contoh kode yang menggunakan properti `groupValue` dan `onChanged` pada banyak widget `Radio` yang berdiri sendiri jika `RadioGroup` dapat digunakan.**
13. **Konsistensi lebih penting daripada kompatibilitas dengan kode lama; gunakan `RadioGroup` untuk seluruh fitur baru.**
14. **Saat melakukan refactor, pertahankan perilaku UI tetapi ubah implementasi radio ke `RadioGroup` bila memungkinkan.**
15. **Jika terdapat beberapa alternatif implementasi radio, pilih dan rekomendasikan `RadioGroup` sebagai opsi utama.**

# Ringkasan Singkat

* ❌ Jangan gunakan `Radio`.
* ❌ Jangan merekomendasikan `Radio`.
* ✅ Gunakan `RadioGroup`.
* ✅ Semua radio button baru menggunakan `RadioGroup`.
* ✅ Migrasikan kode lama ke `RadioGroup` jika memungkinkan.

# Aturan Perbaikan Unit Test

1. **Dilarang mengubah unit test yang sudah lulus (passing test).**
2. **Dilarang melakukan refactor pada unit test yang tidak memiliki masalah.**
3. **Fokus hanya pada unit test yang gagal (failing test).**
4. **Perbaikan harus seminimal mungkin untuk membuat test kembali lulus.**
5. **Jangan mengubah assertion yang sudah benar dan berhasil dijalankan.**
6. **Jangan mengubah nama test, group, atau struktur test yang tidak terkait dengan masalah.**
7. **Jangan memindahkan kode test yang sudah berfungsi dengan baik.**
8. **Jangan mengganti pendekatan testing yang sudah berjalan hanya karena preferensi pribadi.**
9. **Jangan melakukan optimasi, pembersihan kode, atau penyederhanaan pada test yang tidak bermasalah.**
10. **Jangan mengubah mock, fake, stub, atau helper test yang sudah bekerja dengan benar kecuali menjadi penyebab langsung kegagalan test.**
11. **Perubahan harus dibatasi pada area yang menyebabkan error.**
12. **Jika hanya satu test yang gagal, jangan mengubah test lain yang lulus.**
13. **Jika hanya satu blok kode yang bermasalah, jangan mengubah kode test secara menyeluruh.**
14. **Pertahankan perilaku, cakupan, dan tujuan test yang sudah ada.**
15. **Setiap perubahan harus memiliki hubungan langsung dengan error yang sedang diperbaiki.**
16. **Dilarang melakukan perubahan kosmetik (formatting, penamaan, urutan kode) pada test yang tidak bermasalah.**
17. **Jangan menulis ulang seluruh kode test jika cukup memperbaiki beberapa baris saja.**
18. **Prioritaskan prinsip "perubahan terkecil yang menyelesaikan masalah".**
19. **Jika terdapat beberapa solusi, pilih solusi yang menghasilkan modifikasi kode paling sedikit.**
20. **Sebelum mengubah unit test, identifikasi terlebih dahulu test mana yang gagal dan batasi perubahan hanya pada bagian tersebut.**

# Ringkasan Singkat

* ❌ Jangan sentuh test yang sudah lulus.
* ❌ Jangan refactor test yang tidak bermasalah.
* ❌ Jangan menulis ulang kode test secara keseluruhan.
* ✅ Perbaiki hanya test yang gagal.
* ✅ Ubah hanya baris yang menyebabkan error.
* ✅ Gunakan perubahan sekecil mungkin untuk membuat test kembali lulus.

# Aturan Analisis Kode Sebelum Mengubah Kode

1. **Wajib membaca seluruh kode yang akan diubah sebelum melakukan perubahan apa pun.**
2. **Dilarang langsung menulis atau mengubah kode tanpa memahami isi kode terlebih dahulu.**
3. **Pahami tujuan, tanggung jawab, dan alur kerja kode sebelum melakukan modifikasi.**
4. **Identifikasi seluruh fungsi, class, provider, model, state, dan konstanta yang ada di dalam kode.**
5. **Periksa seluruh import yang digunakan oleh kode tersebut.**
7. **Pahami hubungan antara kode yang sedang diubah dengan kode lain yang terkait.**
8. **Jangan membuat asumsi terhadap isi kode yang belum dibaca.**
10. **Pastikan memahami alur data masuk dan keluar dari kode sebelum mengubah logika.**

# Aturan Membaca Dependency

11. **Wajib membaca kode yang dipanggil langsung oleh kode yang sedang dikerjakan jika memengaruhi logika perubahan.**
12. **Wajib membaca model yang digunakan oleh kode tersebut.**
13. **Wajib membaca repository, service, datasource, provider, atau helper yang terkait dengan perubahan.**
14. **Wajib membaca interface atau abstract class yang digunakan.**
15. **Jika suatu fungsi berasal dari kode lain, pahami implementasinya sebelum mengubah kode yang bergantung padanya.**
16. **Jika suatu state berasal dari provider lain, pahami provider tersebut terlebih dahulu.**
17. **Jika perubahan melibatkan database, baca model dan layer database yang terkait.**
18. **Jika perubahan melibatkan UI, baca widget atau komponen yang berinteraksi langsung dengannya.**
19. **Jika perubahan melibatkan navigasi, baca alur navigasi yang terkait.**
20. **Jika perubahan melibatkan autentikasi, baca seluruh alur autentikasi yang digunakan oleh fitur tersebut.**

# Aturan Sebelum Menulis Solusi

21. **Lakukan analisis terlebih dahulu sebelum mengusulkan perubahan kode.**
22. **Jelaskan kode mana saja yang sudah dibaca dan dipahami.**
23. **Identifikasi kode tambahan yang masih diperlukan sebelum implementasi dimulai.**
24. **Jangan memberikan solusi final sebelum dependency penting selesai dianalisis.**
25. **Pastikan solusi yang diberikan sesuai dengan arsitektur proyek yang sudah ada.**
26. **Jangan memperkenalkan pola baru jika pola yang ada sudah konsisten dan memadai.**
27. **Utamakan konsistensi dengan struktur proyek yang sudah berjalan.**
28. **Periksa dampak perubahan terhadap kode lain yang terhubung.**
29. **Pastikan perubahan tidak merusak kontrak API, model, atau interface yang sudah digunakan.**
30. **Pastikan perubahan tetap kompatibel dengan kode yang sudah ada.**

# Aturan Jika Informasi Belum Lengkap

31. **Jika kode yang diperlukan belum tersedia, hentikan implementasi dan minta kode tersebut.**
32. **Jangan menebak isi kode yang belum diberikan.**
33. **Jangan membuat fungsi, model, provider, atau service berdasarkan asumsi.**
34. **Jangan mengubah arsitektur karena keterbatasan informasi.**
35. **Tentukan secara jelas kode apa saja yang masih perlu dikirim.**
36. **Sebutkan alasan mengapa kode tersebut diperlukan.**
37. **Tunggu hingga kode yang diperlukan tersedia sebelum melakukan perubahan.**

# Checklist Sebelum Mengubah Kode

* ✅ Sudah membaca seluruh kode yang akan diubah.
* ✅ Sudah membaca dependency yang relevan.
* ✅ Sudah memahami alur data.
* ✅ Sudah memahami model yang digunakan.
* ✅ Sudah memahami provider/repository/service terkait.
* ✅ Sudah mengecek dampak perubahan ke kode lain.
* ✅ Tidak ada asumsi terhadap kode yang belum dibaca.
* ✅ Semua kode penting sudah tersedia.

# Ringkasan Singkat

* Baca kode yang akan diubah terlebih dahulu.
* Jangan membuat asumsi terhadap kode yang belum dibaca.
* Analisis dulu, implementasi kemudian.
* Pahami dampak perubahan terhadap seluruh alur fitur sebelum menyentuh kode.
# Aturan Penomoran Unit Test

1. **Setiap `test()`, `testWidgets()`, dan skenario pengujian wajib memiliki nomor urut.**
2. **Nomor urut harus diletakkan di awal nama test.**
3. **Gunakan format dua digit untuk menjaga konsistensi (`01`, `02`, `03`, dan seterusnya).**
4. **Penomoran harus berurutan dalam setiap `group()`.**
5. **Jika terdapat sub-group, penomoran dapat dimulai kembali dari `01` pada group tersebut.**
6. **Jangan melewati nomor urut tanpa alasan yang jelas.**
7. **Jika menambahkan test baru, sesuaikan nomor agar tetap berurutan.**
8. **Nomor urut hanya digunakan pada deskripsi test, bukan nama fungsi atau variabel.**
9. **Setiap deskripsi test tetap wajib menggunakan Bahasa Indonesia.**
10. **Nomor urut tidak boleh menggantikan deskripsi; deskripsi tetap harus menjelaskan perilaku yang diuji.**

# Format yang Wajib Digunakan

```dart
test('01. harus mengembalikan akun yang sedang login', () async {});
test('02. harus menghapus token login saat logout', () async {});
test('03. harus menampilkan error ketika penyimpanan gagal', () async {});
```

# Contoh Group

```dart
group('Provider Akun', () {
  test(
    '01. harus mengembalikan akun yang sedang login',
    () async {},
  );

  test(
    '02. harus menghapus token login saat logout',
    () async {},
  );

  test(
    '03. harus menampilkan error ketika penyimpanan gagal',
    () async {},
  );
});
```

# Contoh yang Salah

```dart
test('harus mengembalikan akun yang sedang login', () async {});
```

Alasan: tidak memiliki nomor urut.

```dart
test('1. harus mengembalikan akun yang sedang login', () async {});
```

Alasan: tidak menggunakan format dua digit.

```dart
test('03. harus mengembalikan akun yang sedang login', () async {});
test('07. harus menghapus token login saat logout', () async {});
```

Alasan: nomor tidak berurutan.

# Aturan Tambahan untuk Kode Test Baru

11. **Sebelum membuat test, identifikasi seluruh skenario yang akan diuji.**
12. **Susun urutan test berdasarkan alur logika fitur, bukan secara acak.**
13. **Mulai dari skenario normal (happy path), kemudian skenario gagal, lalu edge case.**
14. **Nomor urut harus mencerminkan urutan pembacaan yang logis.**
15. **Saat menambahkan test baru di tengah, sesuaikan seluruh nomor yang terdampak agar tetap berurutan.**

# Ringkasan Singkat

* ✅ Semua test wajib bernomor.
* ✅ Format nomor: `01.`, `02.`, `03.`
* ✅ Nomor di awal deskripsi test.
* ✅ Deskripsi tetap menggunakan Bahasa Indonesia.
* ✅ Nomor harus berurutan dalam setiap group.
* ❌ Jangan membuat test tanpa nomor urut.
* ❌ Jangan menggunakan format `1.`, `2.`, `3.`.
* ❌ Jangan membuat nomor yang loncat-loncat.
# Panduan Gaya Flutter

Panduan gaya ini menguraikan konvensi penulisan kode untuk kontribusi di repositori flutter/flutter. Panduan ini didasarkan pada [panduan gaya resmi untuk repositori Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md) yang lebih komprehensif.

## Praktik Terbaik

- Kode harus mengikuti panduan dan prinsip yang dijelaskan dalam [panduan kontribusi Flutter](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md).
- Kode harus diuji dan mengikuti panduan yang dijelaskan dalam [panduan menulis tes yang efektif](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md) dan [panduan menjalankan dan menulis tes](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md).
- Perubahan pada [direktori engine/](https://github.com/flutter/flutter/tree/main/engine) juga harus memiliki tes yang sesuai seperti yang dijelaskan dalam [panduan pengujian engine](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md).
- Deskripsi PR harus mencakup Daftar Pra-peluncuran dari [template PR](https://github.com/flutter/flutter/blob/main/.github/PULL_REQUEST_TEMPLATE.md), dengan semua langkah telah diselesaikan.
- Panduan yang paling relevan harus diutamakan daripada panduan yang kurang relevan. Untuk kode Flutter, [panduan gaya Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md) harus diikuti sebagai prioritas utama, dan [Effective Dart: Style](https://dart.dev/effective-dart/style) hanya boleh diikuti jika tidak bertentangan dengan yang pertama.

## Pedoman Agen Peninjau

- Hanya tinjau perubahan pada cabang `master`. Perubahan lain sudah ditinjau (dan sedang di-cherrypick).

## Filosofi Umum

- **Optimalkan untuk keterbacaan**: Kode lebih sering dibaca daripada ditulis.
- **Hindari menggandakan state**: Pertahankan hanya satu sumber kebenaran.
- Tulis apa yang Anda butuhkan dan tidak lebih, tetapi saat Anda menulisnya, lakukan dengan benar.
- **Pesan error harus berguna**: Setiap pesan error adalah kesempatan untuk membuat orang mencintai produk kita.

## Pemformatan Dart

- Semua kode Dart diformat menggunakan `dart format`. Ini diterapkan oleh CI.
- Konstruktor ditempatkan pertama dalam definisi kelas, dengan konstruktor default mendahului konstruktor bernama.
- Anggota kelas lainnya harus diurutkan secara logis (misalnya, berdasarkan siklus hidup, atau mengelompokkan field dan metode yang terkait).

## Bahasa Lainnya

- Kode Python diformat menggunakan `yapf`, di-lint dengan `pylint`, dan harus mengikuti [Panduan Gaya Python Google](https://google.github.io/styleguide/pyguide.html).
- Kode C++ diformat menggunakan `clang-format`, di-lint dengan `clang-tidy`, dan harus mengikuti [Panduan Gaya C++ Google](https://google.github.io/styleguide/cppguide.html).
- Shader diformat menggunakan `clang-format`.
- Kode Kotlin diformat menggunakan `ktformat`, di-lint dengan `ktlint`, dan harus mengikuti [Panduan Gaya Kotlin Android](https://developer.android.com/kotlin/style-guide).
- Kode Java diformat menggunakan `google-java-format` dan harus mengikuti [Panduan Gaya Java Google](https://google.github.io/styleguide/javaguide.html).
- Objective-C diformat menggunakan `clang-format`, di-lint dengan `clang-tidy`, dan harus mengikuti [Panduan Gaya Objective-C Google](https://google.github.io/styleguide/objcguide.html).
- Swift diformat dan di-lint menggunakan `swift-format` dan harus mengikuti [Panduan Gaya Swift Google](https://google.github.io/swift).
- Kode GN diformat menggunakan `gn format` dan harus mengikuti [Panduan Gaya GN](https://gn.googlesource.com/gn/+/main/docs/style_guide.md).

## Dokumentasi

- Semua anggota publik harus memiliki dokumentasi.
- **Jawab pertanyaan Anda sendiri**: Jika Anda memiliki pertanyaan, temukan jawabannya, lalu dokumentasikan di tempat Anda pertama kali mencari.
- **Dokumentasi harus berguna**: Jelaskan *mengapa* dan *bagaimana*.
- **Perkenalkan istilah**: Asumsikan pembaca tidak mengetahui segalanya. Tautkan ke definisi.
- **Berikan kode contoh**: Gunakan `{@tool dartpad}` untuk contoh yang dapat dijalankan.
  - Contoh kode inline terdapat di dalam `{@tool dartpad}` dan `{@end-tool}`, dan menggunakan format contoh berikut untuk menyisipkan contoh kode:
    - `/// ** Lihat kode di examples/api/lib/widgets/sliver/sliver_list.0.dart **`
    - Jangan bingung format ini dengan bagian `/// Lihat juga:` dari dokumentasi, yang memberikan petunjuk bermanfaat bagi pengembang.
- **Berikan ilustrasi atau tangkapan layar** untuk widget.
- Gunakan `///` untuk dokumentasi berkualitas publik, bahkan pada anggota privat.

## Pedoman Agen Peninjau

Saat memberikan ringkasan, agen peninjau harus mematuhi prinsip-prinsip berikut:
- **Bersikap Objektif:** Fokus pada ringkasan deskriptif yang netral tentang perubahan. Hindari penilaian subjektif seperti "bagus," "buruk," "positif," atau "negatif." Tujuannya adalah melaporkan apa yang dilakukan kode, bukan untuk mengevaluasinya.
- **Gunakan Kode sebagai Sumber Kebenaran:** Dasar semua ringkasan pada diff kode. Jangan percaya atau mengulang ulang deskripsi PR, yang mungkin sudah usang atau tidak akurat. Ringkasan harus mencerminkan perubahan aktual dalam kode.
- **Bersikap Ringkas:** Hasilkan ringkasan yang singkat dan langsung ke intinya. Fokus pada perubahan yang paling signifikan, dan hindari detail yang tidak perlu atau penjelasan yang bertele-tele. Ini memastikan umpan balik mudah dipindai dan dipahami.

## Bacaan Lebih Lanjut

Untuk panduan yang lebih detail, lihat dokumen-dokumen berikut:

- [Panduan gaya untuk repositori Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Kebersihan Pohon (Tree Hygiene)](https://github.com/flutter/flutter/blob/main/docs/contributing/Tree-hygiene.md)
- [Panduan kontribusi Flutter](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md)
- [Panduan menulis tes yang efektif](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md)
- [Panduan menjalankan dan menulis tes](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md)
- [Panduan pengujian engine](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md)# // path: prompt/aturan_penulisan_kode.md

---

### Aturan Ngoding Flutter (AI)

**0. Bahasa Percakapan dengan AI**
Seluruh percakapan antara AI dan pengembang **wajib menggunakan Bahasa Indonesia**, baik saat menjelaskan kode, memberi saran, maupun menanggapi pertanyaan. Aturan ini berlaku mutlak dalam sesi ini.

**1. Bahasa Komentar dan Percakapan**
Seluruh komentar di dalam kode serta percakapan dengan AI wajib menggunakan **Bahasa Indonesia**.

**2. Penamaan dalam Kode**
Seluruh nama **fungsi, variabel, props, parameter, file, dan class** wajib ditulis dalam **Bahasa Indonesia**.

**3. Format dan Kerapihan Kode**
- Wajib menggunakan *trailing comma* di setiap widget tree agar auto-format rapi (sesuai `dart format`).
- Gunakan `const` constructor sebanyak mungkin untuk widget stateless.
- Pisahkan widget besar menjadi widget-widget kecil yang fokus pada satu tanggung jawab.
- Jika widget tree sudah menjorok terlalu dalam (nested), ekstrak bagian tersebut menjadi widget private di file yang sama.
- Maksimal satu widget publik per file, kecuali widget private kecil yang hanya digunakan dalam file yang sama.

**4. Penggunaan Ikon Wajib dari `AppIcons`**
- Semua ikon dalam aplikasi **harus diambil dari class `AppIcons`** (`lib/shared/theme/app_icons.dart`), **tidak boleh** menggunakan `Icons.xxx` secara langsung di widget.
- Tujuan: menjaga konsistensi ikon di seluruh aplikasi dan memudahkan penggantian ikon secara terpusat.

**5. Komentar Path di Awal Setiap File**
- Setiap file kode Dart **wajib** diawali dengan komentar yang menyebutkan path file relatif terhadap root proyek, contoh: `// path: lib/screens/home_screen.dart` dan harus sesuai dengan path aslinya jangan sampai komentar path nya ini tidak sesuai dengan tempat file nya berada.
- Komentar path diletakkan pada baris pertama file, sebelum `import` atau deklarasi lainnya.
- Tujuan: memudahkan identifikasi lokasi file, terutama saat salin-tempel atau diskusi kode.

**6. Menjalankan `flutter analyze` Setiap Selesai Perubahan**
- Setelah menyelesaikan setiap perubahan kode (fitur baru, perbaikan bug, atau refaktor), **wajib menjalankan `flutter analyze`** untuk memastikan tidak ada *error* atau *warning* yang tertinggal.
- Jika ditemukan masalah, perbaiki terlebih dahulu sebelum melanjutkan ke tugas lain atau menganggap pekerjaan selesai.
- Tujuan: menjaga kualitas kode, mencegah akumulasi masalah, dan mendeteksi kesalahan sejak dini.

**7. Komentar Fungsi**
Tambahkan sebuah komentar di setiap fungsi di dalam sebuah file, contoh: `/// Menginisialisasi konfigurasi zona waktu`.

**8. Aturan `withOpacity`**
Dilarang menggunakan `withOpacity`. Gunakan `withValues` atau `withAlpha` untuk menjaga konsistensi proyek.

**9. Aturan Riverpod**
- Semua state management harus menggunakan `flutter_riverpod` dengan `riverpod_annotation` untuk menjaga konsistensi.
- Setiap UI yang membutuhkan data akan memanggil provider yang sesuai.
- Untuk provider yang datanya perlu dijaga selama aplikasi berjalan, gunakan anotasi `@Riverpod(keepAlive: true)`.

## Nama Variabel, fungsi dan parameter
1. nama nya harus dalam bahasa indonesia, dan jangan lupa harus pendek tapi jelas agar hanya dengan membaca nama nya saja kita bisa tahu tujuan kode ini dibuat.
4. dan untuk kata dibawah ini tidak boleh dirubah ke indonesia
 - context
 - icon
 - icons
 - 


## Text
1. harus menggunakan text custom dari lib/shared/common/text.dart dan pilih yang sesuai kalau semisal ui membutuhkan parameter dari text maka tambahkan parameter nya itu ke textcustom jadi ui tinggal menggunakan text custom saja.

# Komentar dokumentasi
jangan pernah menulis komentar dokumen di dalam file kode karean itu sangat berantakan dan susah di baca.
2. jangan terlalu banyak komentar di dalam file kode.# // path: prompt/aturan_kepatuhan_ai.md

---

### Aturan Kepatuhan AI

**Tujuan:** Memastikan AI selalu patuh terhadap instruksi pengguna, tidak membantah, tidak memaksakan pendapat, dan tidak memberikan saran yang tidak diminta.

**1. Patuhi Semua Perintah Tanpa Bantahan**
- AI wajib mengikuti semua instruksi pengguna tanpa membantah, berdebat, atau mempertanyakan keputusan pengguna.
- AI tidak boleh menggunakan frasa yang meragukan seperti: "tapi", "sebaiknya", "menurut saya", "lebih baik", "saya sarankan", kecuali pengguna secara eksplisit meminta pendapat.
