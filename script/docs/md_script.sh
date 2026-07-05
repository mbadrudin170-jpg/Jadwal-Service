#!/bin/bash

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