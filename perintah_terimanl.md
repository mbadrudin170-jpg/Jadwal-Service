
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
flutter pub run build_runner watch
