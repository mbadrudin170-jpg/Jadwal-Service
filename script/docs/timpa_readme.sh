#!/bin/bash

output="README.md"

file_list=(
    'lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart'
    'lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart'
    'lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart'
    'lib/fitur/pelanggan/provider/pelanggan_provider.dart'
    'lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart'
    'lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart'
    'lib/fitur/paket/provider/paket_provider.dart'
    'lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart'   # duplikat
    'lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart'     # duplikat
)

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