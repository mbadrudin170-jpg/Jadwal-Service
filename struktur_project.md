jadwal-service-02257685:~/myapp{master}$ ls -R lib/
lib/:
admin  main  services  shared  uji_coba_fitur  user

lib/admin:
app_admin.dart  firebase_option  halaman_utama.dart
data            halaman          splash_screen_admin.dart

lib/admin/data:
sqlite.dart

lib/admin/firebase_option:
firebase_option_admin_dev.dart  firebase_option_admin_prod.dart

lib/admin/halaman:
detail  form  lainnya  pembantu  tab  tes  widget

lib/admin/halaman/detail:
active_customer_detail.dart  package_detail.dart
apk_version_detail.dart      subscription_history_detail.dart
customer_detail.dart         transaction_detail.dart
feedback_detail.dart         wallet_detail.dart

lib/admin/halaman/form:
active_customer_form.dart         package_form.dart
apk_version_form.dart             settings_form.dart
category_form.dart                transaction_form.dart
customer_form.dart                wallet_form.dart
form_edit_riwayat_langganan.dart

lib/admin/halaman/lainnya:
admin_settings.dart    halaman_migrasi.dart
apk_version_page.dart  package_activation_history.dart
category.dart          package.dart
customer.dart          tentang_aplikasi.dart
feedback.dart

lib/admin/halaman/pembantu:
admin_points_page.dart

lib/admin/halaman/tab:
active_customer_tab.dart  order_page.dart        wallet_page.dart
lainnya.dart              transaction_page.dart

lib/admin/halaman/tes:
contoh_simpan_status.dart  detail_pelanggan_uji.dart  halaman_tes.dart

lib/admin/halaman/widget:
box_info.dart               info_tambahan.dart        tombol_aksi.dart
container_with_border.dart  nama_pelanggan.dart
info_detail.dart            package_name_widget.dart

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
common    data   enum    model    page      theme  whatsapp
constant  debug  export  operasi  services  utils  widget

lib/shared/common:
text_input_field.dart

lib/shared/constant:
column_names.dart

lib/shared/data:
services  sync

lib/shared/data/services:
navigasi_servis.dart         preference_service.dart
new_data_check_service.dart  sync_check_service.dart

lib/shared/data/sync:
download_data.dart  initial_download.dart  upload_data.dart

lib/shared/debug:
log.dart

lib/shared/enum:
apk_architecture_enum.dart  payment_status_enum.dart
category_type_enum.dart     table_name_enum.dart
duration_type_enum.dart     transaction_type_enum.dart

lib/shared/export:
enum.dart  model.dart  operasi.dart

lib/shared/model:
active_customer_model.dart  package_model.dart
apk_version_model.dart      save_result_model.dart
category_model.dart         settings_model.dart
customer_model.dart         sub_category_model.dart
feedback_model.dart         transaction_model.dart
has_id.dart                 upload_status_model.dart
order_model.dart            wallet_model.dart

lib/shared/operasi:
active_customer_operation.dart  order_operation.dart
apk_version_operation.dart      package_operation.dart
base_operation.dart             settings_operation.dart
category_operation.dart         sub_category_operation.dart
customer_operation.dart         subscription_history_operation.dart
data_cleaning_operation.dart    transaction_operation.dart
feedback_operation.dart         upload_status_operation.dart
firebase_operasi                wallet_operation.dart

lib/shared/operasi/firebase_operasi:
customer_op_firebase.dart      settings_op_firebase.dart
notification_op_firebase.dart  transaction_op_firebase.dart
package_op_firebase.dart

lib/shared/page:

lib/shared/services:
expired_subscription_check_service.dart  kontrol_aplikasi_service.dart
info_perangkat_service.dart              notifikasi
internet_connection_check.dart           pembaruan_data_service.dart

lib/shared/services/notifikasi:
notifikasi_servis.dart

lib/shared/theme:
app_colors.dart      app_theme.dart
app_text_style.dart  theme_provider.dart

lib/shared/utils:
active_customer_sorter.dart  format_util.dart    sync_manager.dart
calculation_util.dart        snackbar_util.dart

lib/shared/whatsapp:
info_paket.dart

lib/shared/widget:
card                           poin_page_ui.dart
customer_detail_ui.dart        radio_group_widget.dart
customer_name.dart             summary_info_widget.dart
financial_summary_widget.dart  teks_pengaman_database_widget.dart
name_from_id.dart              thousands_input_formatter.dart
package_name.dart              transaction_list_widgets.dart

lib/shared/widget/card:
point_card.dart

lib/uji_coba_fitur:

lib/user:
app_user.dart  firebase_option        page      services
data           maintenance_page.dart  provider  widget

lib/user/data:
operasi

lib/user/data/operasi:
kritik_saran_operasi_user.dart

lib/user/firebase_option:
firebase_option_user_dev.dart  firebase_option_user_prod.dart

lib/user/page:
account_list_page.dart           points_page_user.dart
edit_profile_page.dart           profile_page.dart
feedback_history_user.dart       settings_page_user.dart
form_kritik_dan_saran_user.dart  splash_screen_user.dart
info_apk_page_user.dart          subscription_history_user.dart
login_page.dart                  transaction_detail_user.dart
main_page.dart                   user_customer_detail.dart
pesan_page.dart

lib/user/provider:

lib/user/services:
storage

lib/user/services/storage:
local_storage_service.dart

lib/user/widget:
ads                  error_message.dart   theme_menu_widget.dart
data_not_found.dart  loading_widget.dart

lib/user/widget/ads:
ad_helper.dart  banner_ad_widget.dart
jadwal-service-02257685:~/myapp{master}$ 