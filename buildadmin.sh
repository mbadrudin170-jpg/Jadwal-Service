#!/bin/bash

# Pindah ke direktori tempat script ini berada (root project)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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