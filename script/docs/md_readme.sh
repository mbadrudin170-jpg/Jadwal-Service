#!/bin/bash

# Naik ke root project (script/docs/ → myapp)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$SCRIPT_DIR"

# Fungsi internal (sebelumnya _proses_fitur_readme)
_proses_fitur_readme() {
    local dir="$1"
    local outfile="$2"
    local feature=$(basename "$dir")
    local link_prefix="./"

    {
        echo "## Fitur: $feature"
        echo ""
        echo "### Daftar file"
        echo ""
        find "$dir" -name "*.dart" -type f ! -name "*.freezed.dart" ! -name "*.g.dart" | sort | while read -r file; do
            echo "- [${file}](${link_prefix}${file})"
        done
        echo ""
        echo "### Isi file"
        echo ""
        find "$dir" -name "*.dart" -type f ! -name "*.freezed.dart" ! -name "*.g.dart" | sort | while read -r file; do
            echo "#### File: \`$file\`"
            echo '```dart'
            cat "$file"
            echo '```'
            echo ""
        done
    } >> "$outfile"   # APPEND ke file gabungan
}

# Jika tidak ada argumen, tampilkan cara pakai
if [[ $# -eq 0 ]]; then
    echo "Penggunaan: $0 <fitur1> [fitur2 ...]"
    echo "Contoh: $0 voucher paket transaksi"
    exit 1
fi

output="README.md"
temp_file=$(mktemp)

# Tulis header utama
echo "# Dokumentasi Fitur" > "$temp_file"
echo "" >> "$temp_file"

for target in "$@"; do
    dir=$(find lib/fitur -maxdepth 1 -type d -iname "*${target}*" | head -1)
    if [[ -z "$dir" ]]; then
        echo "⚠️  Fitur '$target' tidak ditemukan, dilewati." >&2
        continue
    fi
    feature=$(basename "$dir")
    echo "📄 Memproses fitur: $feature" >&2
    _proses_fitur_readme "$dir" "$temp_file"
    echo "" >> "$temp_file"
done

mv "$temp_file" "$output"
echo "✅ Dokumentasi gabungan selesai → $output"