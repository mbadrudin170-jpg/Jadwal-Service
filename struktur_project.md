jadwal-service-02257685:~/myapp{master}$ ls -R lib/
lib/:
admin  services  uji_coba_fitur
main   shared    user

lib/admin:
app_admin.dart   halaman
data             halaman_utama.dart
firebase_option  splash_screen_admin.dart

lib/admin/data:
sqlite.dart

lib/admin/firebase_option:
firebase_option_admin_dev.dart
firebase_option_admin_prod.dart

lib/admin/halaman:
detail  lainnya   tab  widget
form    pembantu  tes

lib/admin/halaman/detail:
active_customer_detail.dart
apk_version_detail.dart
customer_detail.dart
feedback_detail.dart
package_detail.dart
subscription_history_detail.dart
transaction_detail.dart
wallet_detail.dart

lib/admin/halaman/form:
active_customer_form.dart
apk_version_form.dart
category_form.dart
customer_form.dart
form_edit_riwayat_langganan.dart
package_form.dart
settings_form.dart
transaction_form.dart
wallet_form.dart

lib/admin/halaman/lainnya:
admin_settings.dart
apk_version_page.dart
category.dart
customer.dart
feedback.dart
halaman_migrasi.dart
package_activation_history.dart
package.dart
tentang_aplikasi.dart

lib/admin/halaman/pembantu:
admin_points_page.dart

lib/admin/halaman/tab:
active_customer_tab.dart
lainnya.dart
order_page.dart
transaction_page.dart
wallet_page.dart

lib/admin/halaman/tes:
contoh_simpan_status.dart  halaman_tes.dart
detail_pelanggan_uji.dart

lib/admin/halaman/widget:
box_info.dart
container_with_border.dart
info_detail.dart
info_tambahan.dart
nama_paket.dart
nama_pelanggan.dart
tombol_aksi.dart

lib/main:
main_admin  main_user

lib/main/main_admin:
admin_dev.dart  admin_prod.dart

lib/main/main_user:
user_dev.dart  user_prod.dart

lib/services:
firebase_migration

lib/services/firebase_migration:
firebase_migration_service.dart

lib/shared:
common    debug   model    services  whatsapp
constant  enum    operasi  theme     widget
data      export  page     utils

lib/shared/common:
text_input_field.dart

lib/shared/constant:
column_names.dart

lib/shared/data:
services  sync

lib/shared/data/services:
navigasi_servis.dart
new_data_check_service.dart
preference_service.dart
sync_check_service.dart

lib/shared/data/sync:
download_data.dart     upload_data.dart
initial_download.dart

lib/shared/debug:
log.dart

lib/shared/enum:
apk_architecture_enum.dart
category_type_enum.dart
duration_type_enum.dart
payment_status_enum.dart
table_name_enum.dart
transaction_type_enum.dart

lib/shared/export:
enum.dart  model.dart  operasi.dart

lib/shared/model:
active_customer_model.dart
apk_version_model.dart
category_model.dart
customer_model.dart
feedback_model.dart
has_id.dart
order_model.dart
package_model.dart
save_result_model.dart
settings_model.dart
sub_category_model.dart
transaction_model.dart
upload_status_model.dart
wallet_model.dart

lib/shared/operasi:
active_customer_operation.dart
apk_version_operation.dart
base_operation.dart
category_operation.dart
customer_operation.dart
data_cleaning_operation.dart
feedback_operation.dart
firebase_operasi
order_operation.dart
package_operation.dart
settings_operation.dart
sub_category_operation.dart
subscription_history_operation.dart
transaction_operation.dart
upload_status_operation.dart
wallet_operation.dart

lib/shared/operasi/firebase_operasi:
customer_op_firebase.dart
notification_op_firebase.dart
package_op_firebase.dart
settings_op_firebase.dart
transaction_op_firebase.dart

lib/shared/page:

lib/shared/services:
data_cleaning_operation.dart
expired_subscription_check_service.dart
info_perangkat_service.dart
internet_connection_check.dart
kontrol_aplikasi_service.dart
notifikasi
pembaruan_data_service.dart

lib/shared/services/notifikasi:
notifikasi_servis.dart

lib/shared/theme:
app_colors.dart      app_theme.dart
app_text_style.dart  theme_provider.dart

lib/shared/utils:
active_customer_sorter.dart
calculation_util.dart
format_util.dart
snackbar_util.dart
sync_manager.dart

lib/shared/whatsapp:
info_paket.dart

lib/shared/widget:
card
customer_detail_ui.dart
customer_name.dart
financial_summary_widget.dart
name_from_id.dart
package_name.dart
poin_page_ui.dart
radio_group_widget.dart
summary_info_widget.dart
teks_pengaman_database_widget.dart
thousands_input_formatter.dart
transaction_list_widgets.dart

lib/shared/widget/card:
point_card.dart

lib/uji_coba_fitur:

lib/user:
app_user.dart          page
data                   provider
firebase_option        services
maintenance_page.dart  widget

lib/user/data:
operasi

lib/user/data/operasi:
kritik_saran_operasi_user.dart

lib/user/firebase_option:
firebase_option_user_dev.dart
firebase_option_user_prod.dart

lib/user/page:
account_list_page.dart
edit_profile_page.dart
feedback_history_user.dart
form_kritik_dan_saran_user.dart
info_apk_page_user.dart
login_page.dart
main_page.dart
pesan_page.dart
points_page_user.dart
profile_page.dart
settings_page_user.dart
splash_screen_user.dart
subscription_history_user.dart
transaction_detail_user.dart
user_customer_detail.dart

lib/user/provider:
theme_provider.dart

lib/user/services:
storage

lib/user/services/storage:
local_storage_service.dart

lib/user/widget:
ads                  loading_widget.dart
data_not_found.dart  theme_menu_widget.dart
error_message.dart

lib/user/widget/ads:
ad_helper.dart  banner_ad_widget.dart
jadwal-service-02257685:~/myapp{master}$ 