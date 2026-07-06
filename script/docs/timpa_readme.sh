#!/bin/bash

output="README.md"
# alias => s
file_list=(
'lib/fitur/investor/page/portofolio.dart'
'lib/fitur/app_role/role_util.dart'
'lib/fitur/pelanggan/page/admin/form_pelanggan.dart'
'lib/fitur/pelanggan/model/pelanggan_model.dart'
'lib/admin/data/sqlite.dart'
'lib/shared/constant/nama_kolom.dart'
'lib/main/main_admin/bootstrap_admin.dart'
'lib/main/main_user/bootstrap_user.dart'
'lib/user/page/login_page.dart'
) # Isi path file nya disini

# Hapus duplikasi dari array
mapfile -t file_list < <(printf '%s\n' "${file_list[@]}" | sort -u)

# Kosongkan file output
> "$output"

# Proses setiap file (sekarang sudah unik)
for file in "${file_list[@]}"; do
    if [ -f "$file" ]; then
        # Tulis header path file
        echo -e "\n// File: $file\n" >> "$output"
        # Bungkus isi file dengan blok kode dart
        echo '```dart' >> "$output"
        cat "$file" >> "$output"
        echo '```' >> "$output"
    else
        echo "⚠️ File '$file' tidak ditemukan, dilewati." >&2
    fi
done

echo "✅ README.md berhasil ditimpa dengan ${#file_list[@]} file (setelah penghapusan duplikat)."