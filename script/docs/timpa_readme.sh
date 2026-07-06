#!/bin/bash

output="README.md"
# alias => s
file_list=(
'lib/fitur/investasi/page/ringkasan_saham.dart'
'lib/fitur/pelanggan/provider/pelanggan_provider.dart'
'lib/fitur/investasi/provider/investasi_provider.dart'
'lib/fitur/investasi/page/daftar_investor.dart'
'lib/fitur/investasi/page/detail_investor.dart'
'lib/fitur/investasi/page/form_saham.dart'
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