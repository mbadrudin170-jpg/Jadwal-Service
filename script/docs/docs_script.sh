#!/bin/bash

output_file="docs/script.md"

{
find script -type f \( -name "*.sh" -o -name "*.md" \) -exec sh -c 'echo -e "\n\n// File: $1"; cat "$1"' _ {} \;
} > "$output_file"

echo "✅ Dokumentasi selesai: $output_file"