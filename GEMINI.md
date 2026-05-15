# Aturan dan Pedoman untuk mengerjakan proyek disini

# Aturan Wajib
1. Bahasa : disaat ingin berbincang dengan saya Ai wajib menggunakan bahasa Indonesia, baik itu untuk penamaan class, fungsi, variabel, parameter, kalau AI menemukan ada yang tidak konsisten mengenai bahasa ini disarankan untuk membuat komentar TODO misalnya `//TODO: penamaan class atau fungsi tidak menggunakan bahasa indoensia`.
2. dilarang keras melawan perintah user harus selalu mengikuti apa prompt user.
3. kerjakan apa yang sesuai dengan perintah user saja jangan melenceng dari perintah user.
4. AI dilarang keras untuk berasumsi dan di wajibkan membaca terlebih dahulu file terkait dependensi.
5. AI seharusnya menuliskan kode lengkapnya, bukan placeholder.

# Aturan Utama
1. Jangan pernah merubah isi file ini.
2. selalu ikuti semua aturan dan pedoman yang ada di file ini.
3. simpan semua aturan dan pedoman nya ke memori AI.
4. karena disini ada tahap-tahap selama mengerjakan proyek ini.
5. Disini Ai bertugas sebagai pekerja user yang paham banget mengenai firebase, flutter, dart, dan IDX studio.
6. Selalu jaga konsistensi sebuah kode.
7. Setiap kode harus disisipkan Log contoh Log.info, Log.warning dan Log error yang dipanggil dari file custome khusus log bernama debug/log.dart jadi jangan gunakan developer.log lagi.
8. Untuk meenampilkan snackbar AI harus memanggil dari file custom khusus snackbar di file class SnackBArUtil snackbar_util.dart.
9. selalu sertakan path file nya yang dibungkus komentar contoh : `// path : lib/main.dart.
10. kalau ingin menggunakan tools Ai wajib memakai root `/home/user/myapp`.
untuk aturan import AI wajib menggunakan import `import 'package:wifi/shared/debug/log.dart';`.


### **Konsep Arsitektur**

AI akan memahami dan menerapkan konsep arsitektur fundamental di Flutter:

* **Widget adalah UI**: Segalanya di UI Flutter adalah widget. AI akan menyusun UI yang kompleks dari widget yang lebih kecil dan dapat digunakan kembali.
* **Imutabilitas**: Widget (terutama StatelessWidget) tidak dapat diubah. Saat UI perlu diubah, Flutter membangun kembali pohon widget.
* **Manajemen Status**: Memahami pentingnya mengelola status yang dapat diubah. AI akan merekomendasikan dan menerapkan solusi manajemen status yang sesuai berdasarkan kompleksitas aplikasi.
* **Pemisahan Masalah**: Berusaha untuk memisahkan lapisan UI (widget), logika bisnis, dan data untuk meningkatkan organisasi kode, kemampuan pengujian, dan pemeliharaan.

## Performa Kode
1. Disetiap file AI harus menggunakan Future & wait, perbanyak const, dan dispose.
2. jangan sampai membuat memori leak, boros RAM, dan ngeblank,

# Sebelum Bekerja
1. Selalu tanyakan ke user apakah ada pekerjaan untuk AI.
2. Baca Struktur di folder root lib/ untuk mengetahui proyek saya ada file apa saja.
3. Dilarang nerasumsi liar kalau tidak yakin atau ragu tolong tanyakan ke user.
4. Selalu ikuti semua perintah user, kalau ada perintah user yang akan membuat kode menjadi error atau tidak konsisten tanyakan lagi keuser apakah user yakin dengan semua perintah itu.
5. jangan berasumsi liar AI harus kerjakan apa yang spesifik dengan perintah user saja jikalau ada pembaruan kode yang melenceng dari perintah user maka AI wajib meminta persetujuan user apalagi kalau sampai refaktor besar-besaran.
6. jalankan ls -R lib/

# Database Firebase & Sqlite
1. Setiap data yang akan disimpan ke sqlite atau pun firebase tipe nya wajib sama dengan yang ada di modelnya.
2. 

# Memulai Pekerjaan
1. Setelah mendapatkan tugas dari user AI diharuskan baca dahulu file analysis_options.yaml, docs/admin/README.md, docs/shared/README.md, dan docs/user/README.md agar AI tahu alur kerja sebuah projek user.
2. Setelah selesai melakukan pekerjaan AI diharapkan selalu melakukan dart `fix --apply && flutter analyze` atau analyze project agar tidak error atau warning yang tertinggal.

## Konsiten & kebersihan kode
1. AI harus merujuk ke file analysis_options.yaml agar semua kode sesuai dengan rules yang ada di file analysis_options ini.
3. Kalau ditengah pekerjaan AI ada mengalamai error dan warning AI harus merujuk ke file analysis_options dan terminal soalnya takut ada kdoe yang di larang oleh rules itu.
4. saat menghadapi error/warning AI harus dengan teliti membaca terminal kenapa kode tersebut bisa error.
5. untuk menjaga struktur yang profesional 
agar sebuah file atau kode ditempatkan di file atau folder tertentu.
6. AI harus memisahkan sebuah logika, UI(widget), dan Data,

## Format Utils
1. untuk format mata uang, angka, jam dan tanggal user dan AI akan memanggil fungsi dari file lain dilarang menulis format didalam file itu sendiri karena proyek ini sudah mempunya file khusus format itu, sebagai satu-satunya file untuk memformat sebuah mata uang, tanggal, waktu dan angka.

## Warna, Teks, Tipograpy
1. untuk konsistensi AI dan user akan menggunakan file yang sudah ada dan dikhususkan untuk warna, teks, Tipography. untuk menjaga konsistensi proyek agar nantinya user dan AI bisa perbarui hanya disatu tempat.


## Auran Lainnya selama pengerjaan berlangsung

# Selesai Pekerjaan
1. AI diharapkan menulis komentar `// TODO:...` jika ada fungsi atau kdiimplemenetasikan, kode yang belum sepenuhnya fix selesai, menemukan kode yang tidak konsisten, dan sebagainya.
2. AI Harus menuliskan rangkuman difolder README.md yang ada diroot proyek, apa saja yang membuat error, kendala dan solusinya apa saja yang telah AI lakukan sehingga kode itu tidak error/warning lagi.
3. setelah melakukan pekerjaan dan menulis rangkuman di follder README.md sekarang AI harus melakukan dokumentasi sebuah projek yang telah AI lakukan kenapa kerjakan kedalam file docs/admin/README.md, docs/shared/README.md, dan docs/user/README.md tapi jangan hapus dokumen yang sudah ada.
4. Setelah selesai melakukan pekerjaan AI diharapkan selalu melakukan dart `fix --apply && flutter analyze` atau analyze project agar tidak error atau warning yang tertinggal.

# TEST
1. kita harus memastikan bahwa Log di file kode nya harus muncul saat kita jalankan debug test.
2. untuk melakukan test AI menjalankan flutter test untuk file tertentu.
3. jangan hanya mengetest UI yang paling penting semua logika harus di test.
4. saat membaut file test di harap kan semua Log di file aslinya akan muncul saat run test berlangsung.
5. setiap test harus dikasih nomor agar mudah di debug conthoh test('1. menampilkan teks kosong').


# Auran Linter
1. harus patuh dengan semua aturan linter ini
2. jangan pernah menulis kode yang dilarang oleh linter ini

linter:
  rules:
    # ============================================================
    # GAYA KODE (STYLE)
    # ============================================================
    prefer_single_quotes: true               # Gunakan petik satu ('), kecuali saat string mengandung karakter petik satu
    require_trailing_commas: false            # Wajibkan koma di akhir daftar parameter/argumen agar format vertikal rapi
    use_super_parameters: true               # Gunakan super.x di parameter konstruktor (Dart 3) untuk menghindari penulisan ulang field
    use_null_aware_elements: true            # Gunakan ?element di collection literal (Dart 3) untuk menyingkat if (x != null) x

    # ============================================================
    # PERFORMA
    # ============================================================
    prefer_const_constructors: true          # Gunakan 'const' pada konstruktor agar widget tidak di-rebuild ulang
    prefer_const_constructors_in_immutables: true # Gunakan 'const' pada konstruktor di kelas @immutable
    prefer_const_declarations: true          # Gunakan 'const' daripada 'final' untuk deklarasi variabel yang nilainya sudah pasti saat kompilasi
    prefer_const_literals_to_create_immutables: true # Gunakan literal 'const' untuk membuat objek immutable agar lebih hemat memori
    await_only_futures: true                 # Larang 'await' pada tipe non-Future (mencegah kesalahan menunggu nilai biasa)

    # ============================================================
    # FLUTTER SPECIFIC
    # ============================================================
    sort_child_properties_last: true         # Letakkan properti 'child'/'children' di akhir daftar parameter widget
    use_key_in_widget_constructors: true     # Wajibkan parameter 'Key?' di konstruktor widget publik untuk manajemen state
    use_build_context_synchronously: true    # Cegah penggunaan BuildContext setelah operasi async (gap) untuk mencegah crash

    # ============================================================
    # PENCEGAHAN ERROR
    # ============================================================
    public_member_api_docs: true             # Wajibkan dokumentasi (///) pada semua API publik agar kode terdokumentasi
    unawaited_futures: true                  # Wajibkan 'await' atau 'unawaited()' pada setiap Future di fungsi async agar tidak ada yang terlewat
    avoid_slow_async_io: true                # Hindari versi sinkron dari operasi dart:io, gunakan versi async agar tidak blocking UI
    no_literal_bool_comparisons: true        # Jangan bandingkan boolean dengan true/false secara literal (pakai if(x) saja)
    close_sinks: true                        # Tutup StreamController setelah selesai digunakan untuk mencegah memory leak
    discarded_futures: true                  # Tangkap Future yang dibuang di fungsi sinkron, pelengkap unawaited_futures
    depend_on_referenced_packages: true      # Wajibkan package yang di-import ada di pubspec.yaml, cegah ketergantungan hantu
    hash_and_equals: true                    # Wajibkan override hashCode jika override ==, cegah bug di HashSet/HashMap
    valid_regexps: true                      # Validasi sintaks RegExp saat kompilasi, bukan saat runtime
    avoid_renaming_method_parameters: true   # Jangan ganti nama parameter saat override method, cegah kebingungan
    avoid_shadowing_type_parameters: true    # Jangan tutupi type parameter dengan nama variabel lokal yang sama
    avoid_types_as_parameter_names: true     # Jangan pakai nama tipe sebagai nama parameter (misal: int int)
    secure_pubspec_urls: true                # URL di pubspec.yaml wajib https untuk keamanan
    no_wildcard_variable_uses: true          # Jangan gunakan variabel wildcard _ (Dart 3) karena tidak bisa diakses

    # ============================================================
    # PENCEGAHAN BUG SERIUS
    # ============================================================
    avoid_catches_without_on_clauses: true   # Hindari catch tanpa klausa 'on', cegah menangkap Error yang seharusnya crash
    avoid_dynamic_calls: true                # Hindari panggilan method/akses properti pada tipe dynamic, cegah runtime error
    avoid_equals_and_hash_code_on_mutable_classes: true # Hindari override ==/hashCode pada kelas mutable, cegah objek hilang dari Set/Map
    avoid_implementing_value_types: true     # Jangan implementasikan kelas yang sudah override ==, cegah inkonsistensi equality
    no_duplicate_case_values: true           # Jangan gunakan case dengan nilai yang sama, cegah dead code di switch
    no_self_assignments: true                # Jangan menetapkan variabel ke dirinya sendiri, cegah no-op yang tidak disengaja
    null_check_on_nullable_type_parameter: true # Jangan gunakan ! pada type parameter nullable, tidak benar-benar menghilangkan null
    null_closures: true                      # Jangan kirim null sebagai argumen di mana closure diharapkan, cegah NullPointerException
    only_throw_errors: true                  # Hanya lempar instance Exception/Error, jangan lempar string atau tipe lain
    parameter_assignments: true              # Jangan mengubah nilai parameter fungsi/method, gunakan variabel lokal baru
    throw_in_finally: true                   # Hindari throw di blok finally, cegah exception asli tertimpa
    unnecessary_null_aware_operator_on_extension_on_nullable: true # Hindari ?. pada extension nullable, sudah ditangani extension
    unrelated_type_equality_checks: true     # Jangan bandingkan tipe yang tidak mungkin sama dengan ==, selalu false
    use_rethrow_when_possible: true          # Gunakan rethrow alih-alih throw e, pertahankan stack trace asli untuk debugging

    # ============================================================
    # KEBERSIHAN KODE
    # ============================================================
    avoid_returning_null_for_void: true      # Jangan mengembalikan 'null' pada fungsi bertipe void
    unnecessary_lambdas: true                # Gunakan tear-off langsung daripada membungkus dalam lambda yang tidak perlu
    avoid_redundant_argument_values: true    # Jangan kirim argumen yang nilainya sama dengan default, tidak perlu
    always_use_package_imports: true         # Gunakan 'package:' import untuk file di lib/, jangan relative import
    avoid_empty_else: true                   # Hindari blok else yang kosong, biasanya indikasi bug logika
    camel_case_extensions: true              # Nama extension wajib UpperCamelCase sesuai konvensi Dart
    unnecessary_overrides: true              # Hapus override yang cuma memanggil super tanpa perubahan apa pun

    # ============================================================
    # LAINNYA
    # ============================================================
    avoid_void_async: true                   # Hindari fungsi async yang return void, gunakan Future<void> agar bisa di-await
    cascade_invocations: false               # (MATI) Cascade (..) tidak diwajibkan, gunakan jika dirasa lebih jelas
    directives_ordering: true                # Urutkan direktif (import/export/part) sesuai konvensi Dart
    prefer_final_fields: true                # Gunakan final untuk field yang tidak pernah di-reassign setelah inisialisasi
    prefer_final_locals: true                # Gunakan final untuk variabel lokal yang tidak pernah di-reassign
    prefer_if_null_operators: true           # Gunakan ?? daripada if (x == null) y else x, lebih ringkas
    avoid_init_to_null: true                 # Jangan inisialisasi variabel nullable dengan null karena sudah null secara default
    file_names: true                         # Nama file wajib snake_case (lowercase_with_underscores) sesuai konvensi

    # ============================================================
    # KOMPLEMEN LAINNYA
    # ============================================================
    empty_catches: true                      # Larang blok catch kosong, minimal beri komentar atau gunakan _
    cancel_subscriptions: true               # Batalkan StreamSubscription setelah selesai untuk mencegah memory leak
    comment_references: true                 # Hanya gunakan identifier dalam scope di komentar dokumen [dalam kurung siku]
    constant_identifier_names: true          # Gunakan lowerCamelCase untuk nama konstanta, bukan ALL_CAPS
    document_ignores: true                   # Wajibkan komentar penjelasan di atas setiap // ignore: aturan
    empty_constructor_bodies: true           # Gunakan ; alih-alih {} untuk badan konstruktor kosong
    empty_statements: true                   # Hindari statement kosong (titik koma sendirian), biasanya bug

    # === 5 ATURAN MOBILE PALING PENTING (BATCH 1) ===
    collection_methods_unrelated_type: true
    no_logic_in_create_state: true
    library_private_types_in_public_api: true
    exhaustive_cases: true

    # === 5 ATURAN MOBILE BERIKUTNYA (BATCH 2) ===
    avoid_function_literals_in_foreach_calls: true
    avoid_single_cascade_in_expression_statements: true
    prefer_conditional_assignment: true
    prefer_is_empty: true
    prefer_is_not_empty: true
    annotate_overrides: true

    # ============================================================
    # TAMBAHAN DART 3 & BEST PRACTICE (17 ATURAN)
    # ============================================================
    matching_super_parameters: true             # Nama parameter super harus cocok (Dart 3)
    unnecessary_async: true                     # Hapus async jika tidak ada await
    avoid_catching_errors: true                 # Jangan tangkap Error (hanya Exception)
    # avoid_returning_null_for_future: true       # Jangan return null untuk Future<T>
    literal_only_boolean_expressions: true      # Ekspresi boolean hanya literal = bug
    no_runtimetype_tostring: true               # Jangan panggil toString() pada runtimeType
    test_types_in_equals: true                  # Cek tipe argumen di operator ==
    unnecessary_statements: true                # Hapus statement yang tidak perlu
    use_colored_box: true                       # Gunakan ColoredBox alih-alih Container(color:)
    use_decorated_box: true                     # Gunakan DecoratedBox alih-alih Container(decoration:)
    sized_box_shrink_expand: true               # Gunakan SizedBox.shrink() / .expand()
    prefer_final_parameters: true               # Gunakan final untuk parameter yang tidak di-reassign
    use_if_null_to_convert_nulls_to_bools: true # Gunakan ?? untuk konversi null ke bool
    prefer_asserts_with_message: true           # Sertakan pesan di assert
    # avoid_unstable_final_fields: true           # Hindari field final yang tidak stabil
    prefer_constructors_over_static_methods: true # Gunakan konstruktor daripada static method untuk membuat instance
    unnecessary_null_checks: true               # Hapus null check (!) yang tidak diperlukan

    use_string_buffers: true
    prefer_contains: true
    avoid_multiple_declarations_per_line: true
