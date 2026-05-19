#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validasi bahwa nama versi dan nomor build diberikan sebagai argumen
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}Error: Nama versi dan nomor build wajib disertakan.${NC}"
    echo -e "${YELLOW}Penggunaan: $0 <nama-versi> <nomor-build>${NC}"
    echo -e "${YELLOW}Contoh: $0 1.0.1 3${NC}"
    exit 1
fi

# Gunakan argumen dari baris perintah
VERSION_NAME=$1
VERSION_CODE=$2

echo -e "${YELLOW}📦 Version: $VERSION_NAME ($VERSION_CODE)${NC}"

# Direktori APK
APK_DIR="build/app/outputs/flutter-apk"

# Cek apakah direktori ada
if [ ! -d "$APK_DIR" ]; then
    echo -e "${YELLOW}⚠️  No APK directory found. Build first!${NC}"
    exit 1
fi

# Rename semua APK
for apk in "$APK_DIR"/app-*.apk; do
    if [ -f "$apk" ]; then
        filename=$(basename "$apk")
        
        # Deteksi ABI
        if [[ $filename == *"armeabi-v7a"* ]]; then
            ABI="armeabi-v7a"
        elif [[ $filename == *"arm64-v8a"* ]]; then
            ABI="arm64-v8a"
        elif [[ $filename == *"x86_64"* ]]; then
            ABI="x86_64"
        else
            ABI="universal"
        fi
        
        # Deteksi flavor
        if [[ $filename == *"adminprod"* ]]; then
            FLAVOR="admin-prod"
        elif [[ $filename == *"userprod"* ]]; then
            FLAVOR="user-prod"
        else
            FLAVOR="app"
        fi
        
        # Nama baru
        new_name="${FLAVOR}-${VERSION_NAME}-${VERSION_CODE}-${ABI}.apk"
        new_path="$APK_DIR/$new_name"
        
        # Rename file
        mv "$apk" "$new_path"
        echo -e "${GREEN}✅ Renamed:${NC} $filename -> $new_name"
    fi
done

echo ""
echo -e "${GREEN}🎉 Done! APK files are in $APK_DIR${NC}"
ls -la "$APK_DIR"/*.apk 2>/dev/null