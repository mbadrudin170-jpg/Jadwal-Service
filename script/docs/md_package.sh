#!/bin/bash
# path: script/docs/md_packages.sh

OUTPUT_FILE="docs/packages.md"
PACKAGE_CACHE="/home/user/.pub-cache/hosted/pub.dev"
FLUTTER_CORE="/home/user/flutter/bin/cache/pkg/sky_engine"

# ============================================================
# DAFTAR FILE (TULIS PATH LENGKAP SAJA)
# ============================================================

files=(
    "/home/user/.pub-cache/hosted/pub.dev/collection-1.19.1/lib/src/iterable_extensions.dart"
    "/home/user/flutter/bin/cache/pkg/sky_engine/lib/core/iterable.dart"
    "/home/user/.pub-cache/hosted/pub.dev/collection-1.19.1/lib/src/iterable_extensions.dart"  # DUPLIKAT!
    # Tambahkan file lain di sini
    # "/home/user/.pub-cache/hosted/pub.dev/dio-5.9.2/lib/dio.dart"
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

cat > "$OUTPUT_FILE" << EOF
# 📚 Dokumentasi File Eksternal & Core

> **Tanggal dibuat:** $(date '+%Y-%m-%d %H:%M:%S')
> **Total file unik:** $(printf '%s\n' "${files[@]}" | sort -u | wc -l)

---

EOF

# ⭐ PROSES FILE UNIK (HAPUS DUPLIKAT)
printf '%s\n' "${files[@]}" | sort -u | while read -r file_path; do
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
echo "✅ Selesai! File: $OUTPUT_FILE"#!/bin/bash
# path: script/docs/md_packages.sh

OUTPUT_FILE="docs/packages.md"
PACKAGE_CACHE="/home/user/.pub-cache/hosted/pub.dev"
FLUTTER_CORE="/home/user/flutter/bin/cache/pkg/sky_engine"

# ============================================================
# DAFTAR FILE (TULIS PATH LENGKAP SAJA)
# ============================================================

files=(
    "/home/user/flutter/bin/cache/pkg/sky_engine/lib/core/iterable.dart"
    "/home/user/.pub-cache/hosted/pub.dev/collection-1.19.1/lib/src/iterable_extensions.dart"
    '/home/user/flutter/bin/cache/pkg/sky_engine/lib/async/future.dart'
'/home/user/flutter/bin/cache/pkg/sky_engine/lib/core/list.dart'
'/home/user/flutter/packages/flutter_test/lib/src/deprecated.dart'





    # Tambahkan file lain di sini
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

cat > "$OUTPUT_FILE" << EOF
# 📚 Dokumentasi File Eksternal & Core

> **Tanggal dibuat:** $(date '+%Y-%m-%d %H:%M:%S')
> **Total file unik:** $(printf '%s\n' "${files[@]}" | sort -u | wc -l)

---

EOF

# ⭐ PROSES FILE UNIK (HAPUS DUPLIKAT)
printf '%s\n' "${files[@]}" | sort -u | while read -r file_path; do
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