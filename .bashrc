# ==============================================================================
# 1. FUNGSI PEMBERSIHAN MENDALAM (DEEP CLEAN STORAGE)
# ==============================================================================
# Fungsi untuk mengosongkan ruang penyimpanan dari cache yang menumpuk
bersihkan_idx() {
    echo "=== Memulai pembersihan mendalam ==="
    
    echo "1. Membersihkan proyek Flutter lokal..."
    cd android && ./gradlew --stop && cd .. && flutter clean   
     
    echo "2. Menghapus cache global Gradle (Aman)..."
    rm -rf ~/.gradle/caches
    
    echo "3. Menghapus wrapper Gradle yang tidak digunakan..."
    rm -rf ~/.gradle/wrapper/dists/*
    
    echo "4. Membersihkan pub cache Flutter..."
    flutter pub cache clean -f
    
    echo "=== Pembersihan Selesai! Periksa ruang disk saat ini: ==="
    df -h 
}

# ==============================================================================
# 2. PERINTAH DASAR & MANIPULASI FILE
# ==============================================================================
# Menyalin/melihat semua isi file
# Contoh: cat lib/main.dart
cat (nama file)

# Melihat proses APK/emulator yang sedang berjalan di background
lsof +L1

# Menempelkan semua isi file .md di dalam folder 'prompt' ke GEMINI.md
find prompt -name "*.md" -exec cat {} + > GEMINI.md

# ==============================================================================
# 3. BUILD RUNNER (Sintaks Modern Menggunakan 'dart run')
# ==============================================================================
# Catatan: 'flutter pub run' sudah deprecated, sekarang disarankan pakai 'dart run'
alias fbuild='dart run build_runner build --delete-conflicting-outputs'
alias fwatch='dart run build_runner watch --delete-conflicting-outputs'

# ==============================================================================
# 4. BUILD APK DENGAN VERSI (FLAVOR ADMIN & USER)
# ==============================================================================
# Cara pakai: fbapkver_admin 1.0.0 1
alias fbapkver_admin='flutter clean && flutter build apk --split-per-abi --flavor adminProd -t lib/main/main_admin/admin_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh adminProd "$1" "$2"'

# Cara pakai: fbapkver_user 1.0.0 1
alias fbapkver_user='flutter clean && flutter build apk --split-per-abi --flavor userProd -t lib/main/main_user/user_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh userProd "$1" "$2"'