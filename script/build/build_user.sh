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