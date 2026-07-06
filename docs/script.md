

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

// File: script/docs/timpa_readme.sh
#!/bin/bash

output="README.md"
# alias => s
file_list=(

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
find lib test > prompt/struktur_proyek.md

{
    # Struktur direktori (hanya nama file)
    find lib test

    # File pubspec.yaml
    echo -e "// File: pubspec.yaml\n"
    cat pubspec.yaml

    # File analysis_options.yaml
    echo -e "\n\n// File: analysis_options.yaml\n"
    cat analysis_options.yaml

    # Semua file .dart di lib/ dengan blok kode Dart
    find lib -type f -name "*.dart" -exec sh -c '
        echo -e "\n\n// File: $1"
        echo "\`\`\`dart"
        cat "$1"
        echo "\`\`\`"
    ' _ {} \;

    # File .md di prompt/
    find prompt -type f -name "*.md" -exec sh -c '
        echo -e "\n\n// File: $1"
        cat "$1"
    ' _ {} \;

    # Snippet VS Code
    echo -e "\n\n// ============================================================"
    echo -e "// SNIPPET VS CODE"
    echo -e "// ============================================================\n"
    find .vscode -type f -name "*.code-snippets" -exec sh -c '
        echo -e "\n\n// File: $1"
        cat "$1"
    ' _ {} \;

    # Jika include_test, tambahkan file .dart di test/ dengan blok kode
    if [ "$include_test" = "include_test" ]; then
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
alias fullclean='cd_root full_clean'
alias freset='flutter clean && flutter pub get && df -h'


## ----------- Dokumen --------------
alias s='timpa_readme'
alias md='cd_root md_fitur'
alias g='md_readme' 
alias dscript='md_script'
alias r='cd_root build_docs README.md'
alias l='cd_root build_docs README.md include_test'
