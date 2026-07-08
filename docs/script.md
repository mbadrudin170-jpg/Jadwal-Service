

// File: script/lainnya/buat_struktur.sh
#!/bin/bash
set -e
# // path: script/lainnya/buat_struktur.sh

# Warna output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Fungsi bantuan
usage() {
    echo -e "${YELLOW}Penggunaan:${NC}"
    echo "  $0 <nama_fitur> [sub_folder1 sub_folder2 ...]"
    echo ""
    echo -e "${YELLOW}Contoh:${NC}"
    echo "  $0 investasi model operasi provider page"
    echo "  $0 laporan model provider"
    echo "  $0 transaksi"  # default: model, provider, page
    echo ""
    echo -e "${YELLOW}Hasil:${NC}"
    echo "  lib/fitur/<nama_fitur>/"
    echo "    ├── model/"
    echo "    ├── operasi/   (jika disebutkan)"
    echo "    ├── provider/  (jika disebutkan)"
    echo "    └── page/      (jika disebutkan)"
    exit 1
}

# Validasi parameter
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Nama fitur wajib diisi!${NC}"
    usage
fi

FITUR="$1"
shift  # Hapus argumen pertama, sisanya jadi sub folder

# Default sub folder jika tidak ada parameter
if [ $# -eq 0 ]; then
    set -- model provider page
fi

# Pindah ke root proyek
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  MEMBUAT STRUKTUR FOLDER${NC}"
echo -e "${YELLOW}  Fitur: ${GREEN}$FITUR${NC}"
echo -e "${YELLOW}  Sub folder: ${GREEN}$@${NC}"
echo -e "${YELLOW}========================================${NC}"

# 1. Buat folder utama dan sub folder
FITUR_PATH="lib/fitur/$FITUR"

if [ -d "$FITUR_PATH" ]; then
    echo -e "${YELLOW}⚠️  Folder $FITUR_PATH sudah ada!${NC}"
    echo -e "${YELLOW}   Akan melewati pembuatan folder, tapi tetap cek file...${NC}"
else
    echo -e "${GREEN}📁 Membuat folder...${NC}"
    mkdir -p "$FITUR_PATH"
fi

# Buat sub folder
for sub in "$@"; do
    mkdir -p "$FITUR_PATH/$sub"
    echo -e "  ${GREEN}✅ $FITUR_PATH/$sub dibuat${NC}"
done

# 2. Buat file sesuai sub folder (dinamis)
echo -e "\n${GREEN}📄 Membuat file-file kosong...${NC}"

declare -A FILE_TEMPLATES=(
    ["model"]="${FITUR}_model.dart"
    ["provider"]="${FITUR}_provider.dart"
    ["page"]="${FITUR}_page.dart"
    ["operasi"]="${FITUR}_op_sqlite.dart"
)

for sub in "$@"; do
    # Tentukan nama file default
    case "$sub" in
        model)
            FILE_NAME="${FITUR}_model.dart"
            ;;
        provider)
            FILE_NAME="${FITUR}_provider.dart"
            ;;
        page)
            FILE_NAME="${FITUR}_page.dart"
            ;;
        operasi)
            FILE_NAME="${FITUR}_op_sqlite.dart"
            ;;
        *)
            # Jika sub folder tidak dikenal, buat file dengan nama generic
            FILE_NAME="${FITUR}_${sub}.dart"
            ;;
    esac

    FILE_PATH="$FITUR_PATH/$sub/$FILE_NAME"

    if [ -f "$FILE_PATH" ]; then
        echo -e "  ${YELLOW}⚠️  $FILE_PATH sudah ada, dilewati${NC}"
    else
        touch "$FILE_PATH"
        echo -e "  ${GREEN}✅ $FILE_PATH dibuat${NC}"
    fi
done

# 3. Tampilkan hasil
echo -e "\n${GREEN}📂 Struktur folder yang dibuat:${NC}"
if command -v tree &> /dev/null; then
    tree "$FITUR_PATH" 2>/dev/null || echo "  (Folder kosong)"
else
    find "$FITUR_PATH" -type f 2>/dev/null | sort || echo "  (Folder kosong)"
fi

# 4. Hitung total file
TOTAL_FILES=$(find "$FITUR_PATH" -type f -name "*.dart" 2>/dev/null | wc -l)
echo -e "\n${GREEN}📊 Total file .dart: $TOTAL_FILES${NC}"

echo -e "\n${GREEN}✅ Selesai!${NC}"
echo -e "${YELLOW}📝 Langkah selanjutnya:${NC}"
echo "  1. Isi file-file dengan kode yang sudah disiapkan"
echo "  2. Jalankan: fbuild (untuk generate freezed)"
echo "  3. Jalankan: flutter analyze (untuk cek error)"

// File: script/lainnya/buat_file.sh
#!/bin/bash
# // path: script/lainnya/buat_file.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}❌ Error: Parameter tidak lengkap!${NC}"
    echo ""
    echo -e "${YELLOW}Penggunaan:${NC}"
    echo "  $0 <path_file> <tipe>"
    echo ""
    echo -e "${YELLOW}Tipe yang tersedia:${NC}"
    echo "  widget  - Stateless Widget"
    echo "  model   - Freezed Model"
    echo "  provider - Riverpod Provider"
    echo "  page    - ConsumerWidget Page"
    echo ""
    echo -e "${YELLOW}Contoh:${NC}"
    echo "  $0 lib/fitur/kopi/widget/kopi_card.dart widget"
    echo "  $0 lib/fitur/kopi/model/kopi_model.dart model"
    echo ""
    exit 1
fi

FILE_PATH="$1"
TYPE="$2"
FOLDER=$(dirname "$FILE_PATH")
FILENAME=$(basename "$FILE_PATH" .dart)

# Buat folder
mkdir -p "$FOLDER"

# Buat file dengan template
case "$TYPE" in
    widget)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:flutter/material.dart';

class CLASSNAME_PLACEHOLDER extends StatelessWidget {
  const CLASSNAME_PLACEHOLDER({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: Implementasi widget
    );
  }
}
EOF
        ;;
    model)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:freezed_annotation/freezed_annotation.dart';

part 'FILENAME_PLACEHOLDER.freezed.dart';
part 'FILENAME_PLACEHOLDER.g.dart';

@freezed
class CLASSNAME_PLACEHOLDER with _$CLASSNAME_PLACEHOLDER {
  const factory CLASSNAME_PLACEHOLDER({
    required String id,
    // TODO: Tambahkan field
  }) = _CLASSNAME_PLACEHOLDER;

  factory CLASSNAME_PLACEHOLDER.fromJson(Map<String, dynamic> json) =>
      _$CLASSNAME_PLACEHOLDERFromJson(json);
}
EOF
        ;;
    provider)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'FILENAME_PLACEHOLDER.g.dart';

@riverpod
class CLASSNAME_PLACEHOLDER extends _$CLASSNAME_PLACEHOLDER {
  @override
  FutureOr<void> build() {
    // TODO: Implementasi provider
  }
}
EOF
        ;;
    page)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLASSNAME_PLACEHOLDER extends ConsumerWidget {
  const CLASSNAME_PLACEHOLDER({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASSNAME_PLACEHOLDER'),
      ),
      body: const Center(
        child: Text('Halaman CLASSNAME_PLACEHOLDER'),
      ),
    );
  }
}
EOF
        ;;
    *)
        echo -e "${RED}❌ Tipe '$TYPE' tidak dikenal!${NC}"
        exit 1
        ;;
esac

# Ganti placeholder
sed -i "s|PATH_PLACEHOLDER|$FILE_PATH|g" "$FILE_PATH"
sed -i "s|FILENAME_PLACEHOLDER|$FILENAME|g" "$FILE_PATH"
sed -i "s|CLASSNAME_PLACEHOLDER|${FILENAME%_*}|g" "$FILE_PATH"

echo -e "${GREEN}✅ File berhasil dibuat dengan template:${NC}"
echo "  📁 $FILE_PATH"

// File: script/docs/md_script.sh
#!/bin/bash

# alias => dscript
output_file="docs/script.md"

{
    # Mengumpulkan semua file .sh dan .md di folder script/
    find script -type f \( -name "*.sh" -o -name "*.md" \) -exec sh -c 'echo -e "\n\n// File: $1"; cat "$1"' _ {} \;
    
    # ✨ Tambahkan ini: menyertakan bash_aliases jika ada
    if [ -f ~/.bash_aliases ]; then
        echo -e "\n\n// File: ~/.bash_aliases"
        cat ~/.bash_aliases
    fi
} > "$output_file"

echo "✅ Dokumentasi selesai: $output_file"

// File: script/docs/md_package.sh
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
> **Total file:** ${#files[@]}

---

EOF

for file_path in "${files[@]}"; do
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

// File: script/docs/timpa_readme.sh
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

// File: script/docs/build_docs.sh
#!/bin/bash
# // path: script/docs/build_docs.sh

# Validasi argumen
if [ $# -lt 1 ]; then
    echo "Penggunaan: $0 <output_file> [include_test]"
    echo "Contoh: $0 README.md"
    echo "Contoh: $0 dokumen_lengkap.md include_test"
    exit 1
fi

output_file="$1"
include_test="${2:-}"

# Pastikan folder prompt ada, lalu buat daftar struktur
mkdir -p prompt
# Hanya satu kali find untuk struktur
find lib test script docs prompt assets > prompt/struktur_proyek.md

{
    cat docs/packages.md
    # Struktur direktori
    echo "// ============================================================"
    echo "// STRUKTUR PROYEK"
    echo "// ============================================================"
    cat prompt/struktur_proyek.md

    # File pubspec.yaml
    echo -e "\n\n// File: pubspec.yaml\n"
    cat pubspec.yaml

    # File analysis_options.yaml
    echo -e "\n\n// File: analysis_options.yaml\n"
    cat analysis_options.yaml

    # === FILE SCRIPT SHELL (.sh) ===
    echo -e "\n\n// ============================================================"
    echo -e "// FILE SCRIPT SHELL"
    echo -e "// ============================================================"
    find docs/script.md -type f -name "*.sh" -exec sh -c '
        echo -e "\n\n// File: $1"
        echo "\`\`\`bash"
        cat "$1"
        echo "\`\`\`"
    ' _ {} \;

    # === FILE DART DI LIB ===
    echo -e "\n\n// ============================================================"
    echo -e "// FILE DART DI LIB"
    echo -e "// ============================================================"
    find lib -type f -name "*.dart" -exec sh -c '
        echo -e "\n\n// File: $1"
        echo "\`\`\`dart"
        cat "$1"
        echo "\`\`\`"
    ' _ {} \;

    # === FILE MD DI PROMPT ===
    echo -e "\n\n// ============================================================"
    echo -e "// FILE PROMPT (.md)"
    echo -e "// ============================================================"
    find prompt -type f -name "*.md" -exec sh -c '
        echo -e "\n\n// File: $1"
        cat "$1"
    ' _ {} \;

    # === SNIPPET VS CODE ===
    echo -e "\n\n// ============================================================"
    echo -e "// SNIPPET VS CODE"
    echo -e "// ============================================================"
    find .vscode -type f -name "*.code-snippets" -exec sh -c '
        echo -e "\n\n// File: $1"
        cat "$1"
    ' _ {} \;

    # === FILE DART DI TEST (opsional) ===
    if [ "$include_test" = "include_test" ]; then
        echo -e "\n\n// ============================================================"
        echo -e "// FILE DART DI TEST"
        echo -e "// ============================================================"
        find test -type f -name "*.dart" -exec sh -c '
            echo -e "\n\n// File: $1"
            echo "\`\`\`dart"
            cat "$1"
            echo "\`\`\`"
        ' _ {} \;
    fi
} > "$output_file"

echo "✅ Dokumentasi selesai: $output_file"

// File: script/docs/md_fitur.sh
#!/bin/bash
# // path: script/docs/md_fitur.sh

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

// File: script/docs/md_readme.sh
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

// File: script/clean/full_clean.sh
#!/bin/bash

echo "🛑 Stopping Gradle daemons..."
(cd android && chmod +x gradlew && ./gradlew --stop)

echo "🧹 Running flutter clean..."
flutter clean

echo "🗑️ Removing local build artifacts..."
rm -rf build/ .dart_tool/ android/.gradle/ android/app/build/
rm -f .flutter-plugins .flutter-plugins-dependencies

echo "⚙️ Cleaning Gradle caches..."
rm -rf ~/.gradle/caches/ ~/.gradle/wrapper/dists/*

echo "📦 Cleaning pub cache..."
rm -rf ~/.pub-cache/

echo "🌐 Cleaning global caches (.cache)..."
rm -rf ~/.cache/*

echo "🗑️ Cleaning Dart server cache..."
rm -rf ~/.dartServer

echo "❄️ Running Nix Garbage Collector (IDX System Optimization)..."
command -v nix-store &>/dev/null && nix-store --gc && nix-store --optimise

echo "⚡ Fetching fresh dependencies for this project..."
flutter pub upgrade

echo "🔨 Re-running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "📊 Remaining disk space:"
df -h

// File: script/build/build_user.sh
#!/bin/bash


# Validasi parameter
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Parameter tidak lengkap."
    echo "Cara pakai: $0 <build-name> <build-number> (Contoh: $0 1.0.0 10)"
    exit 1
fi

flutter clean && \
flutter build apk --split-per-abi \
  --flavor userProd \
  -t lib/main/main_user/user_prod.dart \
  --build-name="$1" \
  --build-number="$2" \
  --target-platform=android-arm,android-arm64 && \
bash rename_apk.sh "$1" "$2" && \
echo -e "# $(date +'%d %b %y, %H:%M')\nversion: $1+$2\nbuilduser $1 $2\n\n$(cat docs/build/build_apk_user.md)" > docs/build/build_apk_user.md && \
echo "✅ Build User $1+$2 Selesai!"

// File: script/build/build_admin.sh
#!/bin/bash

# Validasi parameter
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Parameter tidak lengkap."
    echo "Cara pakai: $0 <build-name> <build-number> (Contoh: $0 1.0.0 10)"
    exit 1
fi

flutter clean && \
flutter build apk --split-per-abi \
  --flavor adminProd \
  -t lib/main/main_admin/admin_prod.dart \
  --build-name="$1" \
  --build-number="$2" \
  --target-platform=android-arm64 && \
bash rename_apk.sh "$1" "$2" && \
echo -e "# $(date +'%d %b %y, %H:%M')\nversion: $1+$2\nbuildadmin $1 $2\n\n$(cat docs/build/build_apk_admin.md)" > docs/build/build_apk_admin.md && \
echo "✅ Build Admin $1+$2 Selesai!"

// File: ~/.bash_aliases
alias cd_root='cd /home/user/myapp &&'

# tempat file berada
alias build_docs='/home/user/myapp/script/docs/build_docs.sh'
alias buildadmin='/home/user/myapp/script/buildadmin.sh'
alias builduser='/home/user/myapp/script/build/build_user.sh'
alias full_clean='/home/user/myapp/script/clean/full_clean.sh'
alias md_fitur='/home/user/myapp/script/docs/md_fitur.sh'
alias md_readme='/home/user/myapp/script/docs/md_readme.sh'
alias timpa_readme='/home/user/myapp/script/docs/timpa_readme.sh'
alias md_script='/home/user/myapp/script/docs/md_script.sh'
alias md_packages='/home/user/myapp/script/docs/md_package.sh'

# -----------build_runner-----------
alias fbuild='flutter pub run build_runner build --delete-conflicting-outputs'
alias fwatch='dart run build_runner watch --delete-conflicting-outputs'
alias emulator='lsof +L1'

#-------------- bash ------------
alias simpan='source ~/.bashrc'
alias bukabash='code ~/.bash_aliases'

alias cekfileterbesar='du -sh ~/* ~/.* 2>/dev/null | sort -rh | head -n 10'
alias stopdaemon='cd android && chmod +x gradlew && ./gradlew --stop'

alias f='dart format lib/'

# Alias gabungan (untuk reset total dependency)
alias cekpakettidakterpakai='dart pub global activate dart_depcheck && dart_depcheck'
alias hapuspaket='flutter pub remove'

#----------- clean -----------
alias fullclean='full_clean'
alias freset='flutter clean && flutter pub get && df -h'


## ----------- Dokumen --------------
alias s='timpa_readme'
alias md='cd_root md_fitur'
alias g='md_readme' 
alias dscript='md_script'
alias r='md_packages build_docs README.md'
alias l='build_docs README.md include_test'

alias buat_struktur='/home/user/myapp/script/lainnya/buat_struktur.sh'