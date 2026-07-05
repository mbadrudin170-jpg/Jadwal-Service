#!/bin/bash

output="README.md"

# alias => s
# Daftar file yang ingin ditimpa (definisikan di sini)
file_list=(
    'lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart'
    'lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart'
   'lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart'
  'lib/fitur/pelanggan/provider/pelanggan_provider.dart'
  'lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart'
  'lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart'
  'lib/fitur/paket/provider/paket_provider.dart'
  'lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart'
  'lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart'  # Tambahkan file lain di bawah ini sesuai kebutuhan
)

# Kosongkan file output
> "$output"

# Proses setiap file dalam daftar
for file in "${file_list[@]}"; do
    if [ -f "$file" ]; then
        echo -e "\n// File: $file\n" >> "$output"
        cat "$file" >> "$output"
    else
        echo "⚠️ File '$file' tidak ditemukan, dilewati." >&2
    fi
done

echo "✅ README.md berhasil ditimpa dengan ${#file_list[@]} file."