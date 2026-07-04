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
│   ├── chating
│   │   ├── chating.dart
│   │   ├── chating_dashboard.dart
│   │   ├── dummy_chatting.dart
│   │   ├── enum
│   │   │   └── status_pesan_enum.dart
│   │   ├── model
│   │   │   ├── chating_model.dart
│   │   │   ├── chating_model.freezed.dart
│   │   │   ├── lampiran.dart
│   │   │   ├── lampiran.freezed.dart
│   │   │   ├── percakapan.dart
│   │   │   └── percakapan.freezed.dart
│   │   ├── operasi
│   │   │   └── chating_op_supabase.dart
│   │   └── provider
│   │       └── chating_provider.dart
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
│   │       └── form_event.dart
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
│   │   │   ├── paket.dart
│   │   │   └── paket_publik.dart
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
│   │   │       └── detail_pelanggan.dart
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
│   │   ├── poin.dart
│   │   ├── provider
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
│   │   ├── transaksi_provider.dart
│   │   ├── transaksi_provider.freezed.dart
│   │   ├── transaksi_provider.g.dart
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
│   ├── voucher
│   │   ├── enum
│   │   │   └── tipe_voucher.dart
│   │   ├── model
│   │   │   ├── voucher_model.dart
│   │   │   └── voucher_model.freezed.dart
│   │   ├── operasi
│   │   │   └── voucher_op_firebase.dart
│   │   ├── page
│   │   │   ├── detail_voucher.dart
│   │   │   ├── form_voucher.dart
│   │   │   └── voucher.dart
│   │   └── provider
│   │       ├── voucher_provider.dart
│   │       ├── voucher_provider.freezed.dart
│   │       └── voucher_provider.g.dart
│   └── whatsapp
│       └── info_paket.dart
├── main
│   ├── main_admin
│   │   ├── admin_dev.dart
│   │   ├── admin_prod.dart
│   │   └── bootstrap_admin.dart
│   └── main_user
│       ├── bootstrap_user.dart
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
│       ├── nama_paket_widget.dart
│       ├── nama_pelanggan_widget.dart
│       ├── pemilih_tanggal_waktu_widget.dart
│       └── ringkasan_keuangan_widget.dart
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

237 directories, 458 files
tree is not installed, but available in the following packages, pick one to run it, Ctrl+C to cancel.
