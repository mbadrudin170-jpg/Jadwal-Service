#!/bin/bash
# // path: script/docs/md_fitur_gabung.sh

# Fungsi internal untuk memproses satu fitur dan menambahkannya ke outfile
_proses_fitur() {
    local dir="$1"
    local outfile="$2"
    local feature=$(basename "$dir")
    local link_prefix="./"

    {
        echo "# Dokumentasi Fitur: $feature"
        echo ""
        echo "## Daftar file"
        echo ""
        find "$dir" -name "*.dart" -type f ! -name "*.freezed.dart" ! -name "*.g.dart" | sort | while read -r file; do
            echo "- [${file}](${link_prefix}${file})"
        done
        echo ""
        echo "## Isi file"
        echo ""
        find "$dir" -name "*.dart" -type f ! -name "*.freezed.dart" ! -name "*.g.dart" | sort | while read -r file; do
            echo "### File: \`$file\`"
            echo '```dart'
            cat "$file"
            echo '```'
            echo ""
        done
    } >> "$outfile"
}

# --- KONFIGURASI ---
output="README.md"               # ganti sesuai keinginan
# -------------------

# Tentukan array fitur yang akan diproses
if [[ $# -eq 0 ]]; then
    # Jika tanpa argumen, proses semua fitur di lib/fitur/
    echo "📦 Memproses SEMUA fitur..."
    features=()
    for dir in lib/fitur/*/; do
        features+=("$(basename "$dir")")
    done
else
    features=("$@")
fi

# Buat file sementara
temp_file=$(mktemp)

# Proses setiap fitur
for target in "${features[@]}"; do
    dir=$(find lib/fitur -maxdepth 1 -type d -iname "*${target}*" | head -1)
    if [[ -z "$dir" ]]; then
        echo "⚠️  Fitur '$target' tidak ditemukan, dilewati." >&2
        continue
    fi
    feature=$(basename "$dir")
    echo "📄 Memproses fitur: $feature" >&2
    _proses_fitur "$dir" "$temp_file"
    echo "" >> "$temp_file"
done

# Pindahkan ke file output akhir
mv "$temp_file" "$output"
echo "✅ Dokumentasi gabungan selesai → $output"