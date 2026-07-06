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