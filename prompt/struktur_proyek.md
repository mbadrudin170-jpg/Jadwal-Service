lib:
admin
data_dummy
fitur
main
services
shared
tes_fitur
user

lib/admin:
app_admin.dart
data
firebase_option
halaman
halaman_utama.dart
providers
splash_screen_admin.dart

lib/admin/data:
sqlite.dart

lib/admin/firebase_option:
firebase_option_admin_dev.dart
firebase_option_admin_prod.dart

lib/admin/halaman:
lainnya
tab
tes
widget

lib/admin/halaman/lainnya:
halaman_migrasi.dart

lib/admin/halaman/tab:
lainnya.dart

lib/admin/halaman/tes:
contoh_simpan_status.dart
halaman_tes.dart

lib/admin/halaman/widget:
box_info.dart
container_with_border.dart
tombol_aksi.dart

lib/admin/providers:
customer_provider.dart
customer_provider.g.dart

lib/data_dummy:
data_dummy.dart
dummy_dompet.dart
dummy_kategori.dart
dummy_paket.dart
dummy_pelanggan.dart
dummy_sub_kategori.dart
dummy_transaksi.dart
halaman_data_dummy.dart

lib/fitur:
akun
alarm
app_role
background
chating
database
dompet
event
feedback
info_perangkat
kategori
notifikasi
order
paket
pelanggan
pelanggan_aktif
poin
riwayat_aktivasi
settings
sinkronisasi
speedtest
statistik
transaksi
versi_apk
voucher
whatsapp

lib/fitur/akun:
page
provider

lib/fitur/akun/page:
daftar_akun_page.dart

lib/fitur/akun/provider:
akun_provider.dart
akun_provider.freezed.dart
akun_provider.g.dart

lib/fitur/alarm:
penjadwal_alarm_android.dart
penjadwal_alarm.dart

lib/fitur/app_role:
role_util.dart
role_util.g.dart

lib/fitur/background:
alarm_utils.dart
layanan_latar_belakang.dart
layanan_peluncuran.dart

lib/fitur/chating:
chating.dart
chating_dashboard.dart
dummy_chatting.dart
enum
model
operasi
provider

lib/fitur/chating/enum:
status_pesan_enum.dart

lib/fitur/chating/model:
chating_model.dart
chating_model.freezed.dart
lampiran.dart
lampiran.freezed.dart
percakapan.dart
percakapan.freezed.dart

lib/fitur/chating/operasi:
chating_op_supabase.dart

lib/fitur/chating/provider:
chating_provider.dart

lib/fitur/database:
provider

lib/fitur/database/provider:
operasi_sqlite_provider.dart
operasi_sqlite_provider.g.dart

lib/fitur/dompet:
model
operasi
page
provider

lib/fitur/dompet/model:
dompet_model.dart
dompet_model.freezed.dart

lib/fitur/dompet/operasi:
dompet_op_sqlite.dart

lib/fitur/dompet/page:
detail_dompet.dart
dompet_page.dart
form_dompet.dart

lib/fitur/dompet/provider:
dompet_provider.dart
dompet_provider.freezed.dart
dompet_provider.g.dart

lib/fitur/event:
model
operasi
page

lib/fitur/event/model:
event_model.dart
event_model.freezed.dart

lib/fitur/event/operasi:
event_op_supabase.dart

lib/fitur/event/page:
detail_event_a.dart
event_page_a.dart
event_page_u.dart
form_event.dart

lib/fitur/feedback:
model
operasi
page
provider

lib/fitur/feedback/model:
feedback_model.dart
feedback_model.freezed.dart

lib/fitur/feedback/operasi:
feedback_op_firebase.dart
feedback_op_global.dart
feedback_op_sqlite.dart

lib/fitur/feedback/page:
feedback_detail.dart
feedback_page.dart
form_feedback.dart

lib/fitur/feedback/provider:
feedback_provider.dart
feedback_provider.freezed.dart
feedback_provider.g.dart

lib/fitur/info_perangkat:
enum
model
page
service

lib/fitur/info_perangkat/enum:
arsitektur_apk.dart

lib/fitur/info_perangkat/model:
info_perangkat_model.dart
info_perangkat_model.freezed.dart

lib/fitur/info_perangkat/page:
info_apk_page_user.dart
tentang_aplikasi.dart

lib/fitur/info_perangkat/service:
layanan_info_paket.dart
layanan_info_perangkat.dart

lib/fitur/kategori:
enum
model
operasi
page

lib/fitur/kategori/enum:
tipe_kategori.dart

lib/fitur/kategori/model:
kategori_model.dart
kategori_model.freezed.dart
sub_kategori_model.dart
sub_kategori_model.freezed.dart

lib/fitur/kategori/operasi:
kategori_op_sqlite.dart
sub_kategori_op_sqlite.dart

lib/fitur/kategori/page:
form_kategori.dart
kategori.dart

lib/fitur/notifikasi:
enum
layanan_notifikasi.dart
model
operasi
pengingat_paket_belum_lunas.dart
penjadwal_notifikasi.dart

lib/fitur/notifikasi/enum:
tipe_notifikasi_enum.dart

lib/fitur/notifikasi/model:
notifikasi_model.dart
notifikasi_model.freezed.dart

lib/fitur/notifikasi/operasi:
notifikasi_op_firebase.dart
notifikasi_op_sqlite.dart

lib/fitur/order:
enum
model
operasi
page
provider

lib/fitur/order/enum:
status_order_enum.dart

lib/fitur/order/model:
order_model.dart
order_model.freezed.dart

lib/fitur/order/operasi:
order_op_firebase.dart
order_op_global.dart
order_op_sqlite.dart

lib/fitur/order/page:
order_page.dart

lib/fitur/order/provider:
order_provider.dart
order_provider.freezed.dart
order_provider.g.dart

lib/fitur/paket:
core
enum
model
operasi
page
provider
widget

lib/fitur/paket/core:
perhitungan_paket.dart

lib/fitur/paket/enum:
tipe_durasi_paket.dart

lib/fitur/paket/model:
paket_model.dart
paket_model.freezed.dart

lib/fitur/paket/operasi:
paket_op_firebase.dart
paket_op_global.dart
paket_op_sqlite.dart

lib/fitur/paket/page:
detail_paket.dart
form_paket.dart
paket.dart
paket_publik.dart

lib/fitur/paket/provider:
paket_provider.dart
paket_provider.freezed.dart
paket_provider.g.dart

lib/fitur/paket/widget:
nama_paket_widget.dart

lib/fitur/pelanggan:
core
helper
model
operasi
page
provider
widget

lib/fitur/pelanggan/core:
layanan_aktivitas_user.dart

lib/fitur/pelanggan/helper:
pengurut_pelanggan.dart
pengurut_pelanggan.g.dart

lib/fitur/pelanggan/model:
pelanggan_model.dart
pelanggan_model.freezed.dart

lib/fitur/pelanggan/operasi:
pelanggan_op_firebase.dart
pelanggan_op_global.dart
pelanggan_op_sqlite.dart

lib/fitur/pelanggan/page:
admin
user

lib/fitur/pelanggan/page/admin:
detail_pelanggan_a.dart
form_pelanggan.dart
pelanggan_page.dart

lib/fitur/pelanggan/page/user:
detail_pelanggan.dart

lib/fitur/pelanggan/provider:
pelanggan_provider.dart
pelanggan_provider.freezed.dart
pelanggan_provider.g.dart

lib/fitur/pelanggan/widget:
detail_pelanggan_ui.dart
nama_pelanggan_widget.dart

lib/fitur/pelanggan_aktif:
helper
model
operasi
page
provider

lib/fitur/pelanggan_aktif/helper:
pengurut_pelanggan_aktif.dart
pengurut_pelanggan_aktif.g.dart

lib/fitur/pelanggan_aktif/model:
detail_pelanggan_aktif_model.dart
pelanggan_aktif_model.dart
pelanggan_aktif_model.freezed.dart

lib/fitur/pelanggan_aktif/operasi:
pelanggan_aktif_op_firebase.dart
pelanggan_aktif_op_sqlite.dart

lib/fitur/pelanggan_aktif/page:
detail_pelanggan_aktif.dart
form_pelanggan_aktif.dart
pelanggan_aktif_page.dart

lib/fitur/pelanggan_aktif/provider:
pelanggan_aktif_provider.dart
pelanggan_aktif_provider.freezed.dart
pelanggan_aktif_provider.g.dart

lib/fitur/poin:
operasi
page
poin.dart
provider
service
widget

lib/fitur/poin/operasi:
firebase_points_data_source.dart
sqlite_points_data_source.dart

lib/fitur/poin/page:
halaman_poin.dart

lib/fitur/poin/provider:
points_page_data_source.dart

lib/fitur/poin/service:
poin_transaction_service.dart

lib/fitur/poin/widget:
kartu_total_poin.dart
ui_halaman_poin.dart

lib/fitur/riwayat_aktivasi:
page
provider

lib/fitur/riwayat_aktivasi/page:
detail_riwayat_aktivasi.dart
form_riwayat_aktivasi.dart
riwayat_aktivasi_paket.dart

lib/fitur/riwayat_aktivasi/provider:
detail_langganan_provider.dart
detail_langganan_provider.freezed.dart
detail_langganan_provider.g.dart
riwayat_aktivasi_paket_provider.dart
riwayat_aktivasi_paket_provider.g.dart

lib/fitur/settings:
model
operasi
page
provider

lib/fitur/settings/model:
settings_model.dart
settings_model.freezed.dart

lib/fitur/settings/operasi:
settings_op_firebase.dart
settings_op_sqlite.dart

lib/fitur/settings/page:
form_settings.dart
settings_page_a.dart
settings_page_u.dart

lib/fitur/settings/provider:
settings_provider.dart
settings_provider.freezed.dart
settings_provider.g.dart

lib/fitur/sinkronisasi:
layanan_cek_sinkronisasi.dart
layanan_unduhan_awal.dart
layanan_unduh_data.dart
layanan_unggah_data.dart
pengelola_sinkronisasi.dart

lib/fitur/speedtest:
page
provider

lib/fitur/speedtest/page:
uji_kecepatan_page.dart

lib/fitur/speedtest/provider:
ping_provider.dart
ping_provider.g.dart
uji_kecepatan_provider.dart
uji_kecepatan_provider.freezed.dart
uji_kecepatan_provider.g.dart

lib/fitur/statistik:
model
page

lib/fitur/statistik/model:
paket_terlaris_model.dart

lib/fitur/statistik/page:
statistik_page_a.dart

lib/fitur/transaksi:
enum
helper
model
operasi
operasi_provider.dart
page
provider
transaksi_provider.freezed.dart
transaksi_provider.g.dart
transaksi_provider_usang.dart
widget

lib/fitur/transaksi/enum:
status_pembayaran.dart
tipe_transaksi.dart

lib/fitur/transaksi/helper:
pengurut_transaksi.dart
pengurut_transaksi.g.dart

lib/fitur/transaksi/model:
transaksi_model.dart
transaksi_model.freezed.dart

lib/fitur/transaksi/operasi:
transaksi_op_firebase.dart
transaksi_op_global.dart
transaksi_op_sqlite.dart

lib/fitur/transaksi/operasi_provider.dart:
transaksi_op_provider.dart
transaksi_op_provider.freezed.dart
transaksi_op_provider.g.dart
transaksi_provider.dart
transaksi_provider.freezed.dart
transaksi_provider.g.dart

lib/fitur/transaksi/page:
detail_transaksi_a.dart
detail_transaksi_u.dart
form_transaksi.dart
transaksi_a.dart
transaksi_u.dart

lib/fitur/transaksi/provider:
transaksi_provider.freezed.dart
transaksi_provider.g.dart

lib/fitur/transaksi/widget:
daftar_transaksi_widget.dart

lib/fitur/versi_apk:
model
operasi
page
service

lib/fitur/versi_apk/model:
versi_apk_model.dart
versi_apk_model.freezed.dart

lib/fitur/versi_apk/operasi:
versi_apk_op_firebase.dart
versi_apk_op_sqlite.dart

lib/fitur/versi_apk/page:
detail_versi_apk.dart
form_versi_apk.dart
update_apk_page_u.dart
versi_apk_page.dart

lib/fitur/versi_apk/service:
layanan_cek_update_apk.dart
update_service.dart

lib/fitur/voucher:
enum
model
operasi
page
provider

lib/fitur/voucher/enum:
tipe_voucher.dart

lib/fitur/voucher/model:
voucher_model.dart
voucher_model.freezed.dart

lib/fitur/voucher/operasi:
voucher_op_firebase.dart

lib/fitur/voucher/page:
detail_voucher.dart
form_voucher.dart
voucher.dart

lib/fitur/voucher/provider:
voucher_provider.dart
voucher_provider.freezed.dart
voucher_provider.g.dart

lib/fitur/whatsapp:
info_paket.dart

lib/main:
main_admin
main_user

lib/main/main_admin:
admin_dev.dart
admin_prod.dart
bootstrap_admin.dart

lib/main/main_user:
bootstrap_user.dart
user_dev.dart
user_prod.dart

lib/services:
firebase_migration

lib/services/firebase_migration:
firebase_migration_service.dart

lib/shared:
common
constant
data
debug
enum
export
model
operasi
providers
services
theme
utils
widget

lib/shared/common:
teks.dart

lib/shared/constant:
app_constants.dart
nama_kolom.dart
nama_tabel.dart

lib/shared/data:
services

lib/shared/data/services:
layanan_navigasi.dart
layanan_pengecekan_data_baru.dart
layanan_preferensi.dart

lib/shared/debug:
global_key.dart
log.dart

lib/shared/enum:
app_role_enum.dart
url_supabase_enum.dart

lib/shared/export:
enum.dart
operation.dart
op_firebase.dart
theme.dart

lib/shared/model:
has_id.dart
status_model.dart
status_model.freezed.dart
status_unggah_model.dart
status_unggah_model.freezed.dart

lib/shared/operasi:
firebase_operasi
sqlite_operasi

lib/shared/operasi/firebase_operasi:
base_op_firebase.dart
firebase_operation_provider
status_op_firebase.dart

lib/shared/operasi/firebase_operasi/firebase_operation_provider:
firebase_operation_provider.dart
firebase_operation_provider.g.dart

lib/shared/operasi/sqlite_operasi:
base_op_sqlite.dart
pembersihan_data_operasi.dart
status_upload_op_sqlite.dart

lib/shared/providers:
shared_providers.dart
shared_providers.g.dart

lib/shared/services:
arsipkan_langganan_kadaluarsa_service.dart
koneksi_internet_service.dart
layanan_penyimpanan_gambar.dart

lib/shared/theme:
app_colors.dart
app_icons.dart
app_sizes.dart
app_theme.dart
tema_provider.dart
tema_provider.g.dart

lib/shared/utils:
durasi_util.dart
format_util.dart
future_util.dart
parser_util.dart
perhitungan_util.dart
toast_util.dart

lib/shared/widget:
input
pemilih_tanggal_waktu_widget.dart
ringkasan_keuangan_widget.dart

lib/shared/widget/input:
formatter
input_angka.dart
input_mac_address.dart
input_password.dart
input_rupiah.dart
input_teks.dart
input_telepon.dart

lib/shared/widget/input/formatter:
mac_address_formatter.dart

lib/tes_fitur:
tes_iklan.dart
tes_notifikasi.dart

lib/user:
app_user.dart
firebase_option
maintenance_page.dart
page
providers
services
widget

lib/user/firebase_option:
firebase_option_user_dev.dart
firebase_option_user_prod.dart

lib/user/page:
login_page.dart
main_page.dart
profile_page.dart
splash_screen_user.dart

lib/user/providers:
ad_providers.dart
ad_providers.g.dart
user_provider.dart
user_provider.g.dart

lib/user/services:
storage

lib/user/services/storage:
layanan_penyimpanan_lokal.dart

lib/user/widget:
ads
data_not_found.dart
error_message.dart
theme_menu_widget.dart

lib/user/widget/ads:
app_open
banner
bonused_mediator
interstitial

lib/user/widget/ads/app_open:
app_lifecycle_reactor.dart
app_open_ad_service.dart
id_app_open_ads.dart

lib/user/widget/ads/banner:
banner_ads_widget.dart
id_banner_ads.dart

lib/user/widget/ads/bonused_mediator:
bonused_mediator_ad_service.dart
id_bonused_mediator_ads.dart

lib/user/widget/ads/interstitial:
id_interstitial_ads.dart
layanan_iklan_interstisial.dart

test:
admin
data_dummy
fitur
image_mock_http_client.dart
shared

test/admin:
app_admin_test.dart
app_admin_test.mocks.dart
data
firebase_option
halaman
halaman_utama_test.dart
halaman_utama_test.mocks.dart
model
providers
splash_screen_admin_test.dart

test/admin/data:
sqlite_test.dart
sqlite_test.mocks.dart

test/admin/firebase_option:
firebase_option_admin_dev_test.dart
firebase_option_admin_prod_test.dart

test/admin/halaman:
detail
event
form
lainnya
tab
tes
widget

test/admin/halaman/detail:
detail_dompet_test.dart
detail_dompet_test.mocks.dart
detail_paket_test.dart
detail_paket_test.mocks.dart

test/admin/halaman/event:

test/admin/halaman/form:
form_kategori_test.dart
form_pelanggan_aktif_test.dart
form_pelanggan_test.dart
form_pelanggan_test.mocks.dart

test/admin/halaman/lainnya:
halaman_migrasi_test.dart
paket_test.dart
paket_test.mocks.dart
riwayat_aktivasi_paket_test.dart

test/admin/halaman/tab:
lainnya_test.dart

test/admin/halaman/tes:
contoh_simpan_status_test.dart
halaman_tes_test.dart

test/admin/halaman/widget:
box_info_test.dart
container_with_border_test.dart
nama_paket_widget_test.dart
tombol_aksi_test.dart

test/admin/model:
best_selling_package_test.dart

test/admin/providers:
customer_provider_test.dart
customer_provider_test.mocks.dart
detail_langganan_provider_test.dart
detail_langganan_provider_test.mocks.dart
riwayat_aktivasi_paket_provider_test.dart
riwayat_aktivasi_paket_provider_test.mocks.dart

test/data_dummy:
data_dummy_test.dart
halaman_data_dummy_test.dart

test/fitur:
akun
alarm
background
database
dompet
event
feedback
info_perangkat
notfikasi
pelanggan
router
settings
sinkronisasi
speedtest
statistik
transaksi
versi_apk
whatsapp

test/fitur/akun:
page
provider

test/fitur/akun/page:
daftar_akun_page_test.dart
daftar_akun_page_test.mocks.dart

test/fitur/akun/provider:
akun_provider_test.dart
akun_provider_test.mocks.dart

test/fitur/alarm:
alarm_scheduler_test.dart
alarm_scheduler_test.mocks.dart
android_alarm_scheduler_test.dart

test/fitur/background:
alarm_utils_test.dart
layanan_latar_belakang_test.dart
layanan_peluncuran_test.dart

test/fitur/database:
provider

test/fitur/database/provider:
operasi_sqlite_provider_test.dart
operasi_sqlite_provider_test.mocks.dart

test/fitur/dompet:
model
operasi
page
state

test/fitur/dompet/model:
item_dompet_model_test.dart
item_transaksi_model_test.dart
transaksi_model_test.dart
wallet_model_test.dart

test/fitur/dompet/operasi:
dompet_op_sqlite_test.dart
dompet_op_sqlite_test.mocks.dart

test/fitur/dompet/page:
dompet_page_test.dart
form_dompet_test.dart

test/fitur/dompet/state:
state_item_transaksi_test.dart
state_transaksi_test.dart
state_wallet_test.dart

test/fitur/event:
model
operasi
page

test/fitur/event/model:
event_model_test.dart

test/fitur/event/operasi:
event_op_supabase_test.dart

test/fitur/event/page:
detail_event_a_test.dart
detail_event_a_test.mocks.dart
event_page_a_test.dart
event_page_a_test.mocks.dart

test/fitur/feedback:
model
operasi

test/fitur/feedback/model:
feedback_model_test.dart

test/fitur/feedback/operasi:
feedback_op_firebase_test.dart
feedback_op_firebase_test.mocks.dart
feedback_op_sqlite_test.dart
feedback_op_sqlite_test.mocks.dart

test/fitur/info_perangkat:
model
service

test/fitur/info_perangkat/model:
info_perangkat_model_test.dart

test/fitur/info_perangkat/service:
layanan_info_paket_test.dart
layanan_info_perangkat_test.dart
layanan_info_perangkat_test.mocks.dart

test/fitur/notfikasi:
enum
layanan_notifikasi_test.dart
layanan_notifikasi_test.mocks.dart
penjadwal_notifikasi_test.dart
penjadwal_notifikasi_test.mocks.dart

test/fitur/notfikasi/enum:
tipe_notifikasi_enum_test.dart

test/fitur/pelanggan:
core
operasi
page
widget

test/fitur/pelanggan/core:
layanan_aktivitas_user_test.dart
layanan_aktivitas_user_test.mocks.dart

test/fitur/pelanggan/operasi:
pelanggan_op_firebase_test.dart
pelanggan_op_firebase_test.mocks.dart
pelanggan_op_sqlite_test.dart
pelanggan_op_sqlite_test.mocks.dart

test/fitur/pelanggan/page:
admin
user

test/fitur/pelanggan/page/admin:
detail_pelanggan_a_test.dart

test/fitur/pelanggan/page/user:
detail_pelanggan_u_test.dart
detail_pelanggan_u_test.mocks.dart

test/fitur/pelanggan/widget:
detail_pelanggan_ui_test.dart

test/fitur/router:
operasi
provider

test/fitur/router/operasi:
router_op_sqlite_test.dart

test/fitur/router/provider:
router_provider_test.dart

test/fitur/settings:
operasi
settings_model_test.dart
settings_op_firebase_test.dart

test/fitur/settings/operasi:
settings_op_sqlite_test.dart
settings_op_sqlite_test.mocks.dart

test/fitur/sinkronisasi:
layanan_unduh_data_test.dart
layanan_unggah_data_test.dart
provider

test/fitur/sinkronisasi/provider:
sinkronisasi_provider_test.dart

test/fitur/speedtest:
provider

test/fitur/speedtest/provider:
ping_provider_test.dart
uji_kecepatan_provider_test.dart

test/fitur/statistik:
model
operasi
provider

test/fitur/statistik/model:
paket_terlaris_model_test.dart

test/fitur/statistik/operasi:
statistik_op_sqlite_test.dart

test/fitur/statistik/provider:
statistik_provider_test.dart

test/fitur/transaksi:
model
operasi
provider

test/fitur/transaksi/model:
transaksi_model_test.dart

test/fitur/transaksi/operasi:
transaksi_op_firebase_test.dart
transaksi_op_sqlite_test.dart

test/fitur/transaksi/provider:
transaksi_provider_test.dart

test/fitur/versi_apk:
model
operasi
provider
service

test/fitur/versi_apk/model:
versi_apk_model_test.dart

test/fitur/versi_apk/operasi:
versi_apk_op_firebase_test.dart
versi_apk_op_sqlite_test.dart

test/fitur/versi_apk/provider:
versi_apk_provider_test.dart

test/fitur/versi_apk/service:
update_service_test.dart

test/fitur/whatsapp:
info_paket_test.dart
info_paket_test.mocks.dart

test/shared:
data
debug
operasi
utils

test/shared/data:
services

test/shared/data/services:
layanan_cek_sinkronisasi_test.dart
layanan_cek_sinkronisasi_test.mocks.dart
layanan_navigasi_test.dart
layanan_preferensi_test.dart
pengecekan_data_baru_service_test.dart
pengecekan_data_baru_service_test.mocks.dart

test/shared/debug:
log_test.dart

test/shared/operasi:
firebase_operasi
sqlite_operasi

test/shared/operasi/firebase_operasi:
base_op_firebase_test.dart
notifikasi_op_firebase_test.dart
notifikasi_op_firebase_test.mocks.dart
status_op_firebase_test.dart

test/shared/operasi/sqlite_operasi:
base_op_sqlite_test.dart
base_op_sqlite_test.mocks.dart

test/shared/utils:
durasi_util_test.dart
format_util_test.dart
parser_util_test.dart
pengelola_sinkronisasi_test.dart
perhitungan_util_test.dart
toast_util_test.dart
