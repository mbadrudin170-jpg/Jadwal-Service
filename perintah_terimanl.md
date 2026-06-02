
# menyalin semua isi file 
```
cat (nama file)
```

# hapus cache gradle
```
rm -rf ~/.gradle/caches
```
# melihat apk berjalan
lsof +L1

# menempelkan semua isi file di folder prompt ke GEMINI.md
find prompt -name "*.md" -exec cat {} + > GEMINI.md

# build runner
flutter pub run build_runner build --delete-conflicting-outputs
# build runner otomatis 
flutter pub run build_runner watch --delete-conflicting-outputs

# BUILD APK DENGAN VERSI
alias fbapkver_admin='flutter clean && flutter build apk --split-per-abi --flavor adminProd -t lib/main/main_admin/admin_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh adminProd "$1" "$2"'
alias fbapkver_user='flutter clean && flutter build apk --split-per-abi --flavor userProd -t lib/main/main_user/user_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh userProd "$1" "$2"'
