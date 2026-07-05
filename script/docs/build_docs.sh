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
    find lib test
    echo -e "// File: pubspec.yaml\n"
    cat pubspec.yaml
    echo -e "\n\n// File: analysis_options.yaml\n"
    cat analysis_options.yaml
    find lib -type f -name "*.dart" -exec sh -c "echo -e \"\n\n// File: {}\"; cat \"{}\"" \;
    find prompt -type f -name "*.md" -exec sh -c "echo -e \"\n\n// File: {}\"; cat \"{}\"" \;
    echo -e "\n\n// ============================================================"
    echo -e "// SNIPPET VS CODE"
    echo -e "// ============================================================\n"
    find .vscode -type f -name "*.code-snippets" -exec sh -c "echo -e \"\n\n// File: {}\"; cat \"{}\"" \;
    if [ "$include_test" = "include_test" ]; then
        find test -type f -name "*.dart" -exec sh -c "echo -e \"\n\n// File: {}\"; cat \"{}\"" \;
    fi
} > "$output_file"

echo "✅ Dokumentasi selesai: $output_file"