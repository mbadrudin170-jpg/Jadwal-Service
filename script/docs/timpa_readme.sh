#!/bin/bash

output="README.md"

# alias => s
# Daftar file yang ingin ditimpa (definisikan di sini)
file_list=(
    
    # Tambahkan file lain di bawah ini sesuai kebutuhan
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