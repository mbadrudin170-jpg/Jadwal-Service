#!/bin/bash
# // path: script/package/flutter_test.sh

OUTPUT_FILE="docs/flutter_test.md"
PACKAGE_CACHE="/home/user/.pub-cache/hosted/pub.dev"
FLUTTER_CORE="/home/user/flutter/bin/cache/pkg/sky_engine"

# ============================================================
# DAFTAR FILE (UNIK - TANPA DUPLIKAT)
# ============================================================

files=(
    '/home/user/flutter/packages/flutter_test/lib/src/widget_tester.dart'
   )

# ============================================================
# FUNGSI DETEKSI JENIS FILE
# ============================================================

detect_file_type() {
    local file_path="$1"
    
    # Cek apakah di flutter core
    if [[ "$file_path" == *"sky_engine"* ]]; then
        echo "core"
        return
    fi
    
    # Cek apakah di pub-cache
    if [[ "$file_path" == *".pub-cache"* ]]; then
        echo "package"
        return
    fi
    
    # Cek apakah di project sendiri
    if [[ "$file_path" == *"$PROJECT_ROOT"* ]]; then
        echo "project"
        return
    fi
    
    echo "unknown"
}

# ============================================================
# EKSEKUSI
# ============================================================

mkdir -p docs

# Gunakan printf dan sort -u untuk menghilangkan duplikat
UNIQUE_FILES=$(printf '%s\n' "${files[@]}" | sort -u)

TOTAL_FILES=$(echo "$UNIQUE_FILES" | wc -l)

cat > "$OUTPUT_FILE" << EOF
# 📚 Dokumentasi File Eksternal & Core

> **Tanggal dibuat:** $(date '+%Y-%m-%d %H:%M:%S')
> **Total file unik:** $TOTAL_FILES

---

EOF

# ⭐ PROSES FILE UNIK
echo "$UNIQUE_FILES" | while read -r file_path; do
    # Skip jika baris kosong
    [ -z "$file_path" ] && continue
    
    if [ ! -f "$file_path" ]; then
        echo "⚠️  File tidak ditemukan: $file_path" >&2
        continue
    fi
    
    # Deteksi jenis file
    file_type=$(detect_file_type "$file_path")
    filename=$(basename "$file_path")
    
    case "$file_type" in
        core)
            icon="🔧"
            label="Core Dart"
            ;;
        package)
            icon="📦"
            label="Package"
            ;;
        project)
            icon="📁"
            label="Project"
            ;;
        *)
            icon="📄"
            label="File"
            ;;
    esac
    
    echo "" >> "$OUTPUT_FILE"
    echo "// ============================================================" >> "$OUTPUT_FILE"
    echo "// $icon $label: $filename" >> "$OUTPUT_FILE"
    echo "// 📁 $file_path" >> "$OUTPUT_FILE"
    echo "// ============================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo '```dart' >> "$OUTPUT_FILE"
    cat "$file_path" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    echo "✅ $icon $filename"
done

echo ""
echo "✅ Selesai! File: $OUTPUT_FILE"