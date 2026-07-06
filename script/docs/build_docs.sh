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
    find lib test script docs prompt assets

    # File pubspec.yaml
    echo -e "// File: pubspec.yaml\n"
    cat pubspec.yaml

    # File analysis_options.yaml
    echo -e "\n\n// File: analysis_options.yaml\n"
    cat analysis_options.yaml

    find lib -type f -name "*.sh" -exec sh -c '
        echo -e "\n\n// File: $1"
        echo "\`\`\`sh"
        cat "$1"
        echo "\`\`\`"
    ' _ {} \;

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