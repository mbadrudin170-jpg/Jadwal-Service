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