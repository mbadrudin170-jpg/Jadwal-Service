#!/bin/bash

# Naik ke root project (script/docs/ → myapp)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$SCRIPT_DIR"

# Fungsi internal untuk memproses satu fitur
_proses_fitur() {
    local dir="$1"
    local output="$2"
    local feature=$(basename "$dir")
    local link_prefix="../../"

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
    } > "$output"
}

# Argumen: target fitur (default "all")
target="${1:-all}"

mkdir -p docs/fitur

if [[ "$target" == "all" ]]; then
    for dir in lib/fitur/*/; do
        feature=$(basename "$dir")
        output="docs/fitur/${feature}.md"
        _proses_fitur "$dir" "$output"
    done
    echo "✅ Dokumentasi semua fitur selesai di docs/fitur/"
else
    dir=$(find lib/fitur -maxdepth 1 -type d -iname "*${target}*" | head -1)
    if [[ -z "$dir" ]]; then
        echo "❌ Fitur '$target' tidak ditemukan di lib/fitur/"
        exit 1
    fi
    feature=$(basename "$dir")
    output="docs/fitur/${feature}.md"
    _proses_fitur "$dir" "$output"
    echo "✅ Dokumentasi fitur '$feature' selesai: $output"
fi