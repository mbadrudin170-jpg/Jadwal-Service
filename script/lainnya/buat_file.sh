#!/bin/bash
# // path: script/lainnya/buat_file.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}❌ Error: Parameter tidak lengkap!${NC}"
    echo ""
    echo -e "${YELLOW}Penggunaan:${NC}"
    echo "  $0 <path_file> <tipe>"
    echo ""
    echo -e "${YELLOW}Tipe yang tersedia:${NC}"
    echo "  widget  - Stateless Widget"
    echo "  model   - Freezed Model"
    echo "  provider - Riverpod Provider"
    echo "  page    - ConsumerWidget Page"
    echo ""
    echo -e "${YELLOW}Contoh:${NC}"
    echo "  $0 lib/fitur/kopi/widget/kopi_card.dart widget"
    echo "  $0 lib/fitur/kopi/model/kopi_model.dart model"
    echo ""
    exit 1
fi

FILE_PATH="$1"
TYPE="$2"
FOLDER=$(dirname "$FILE_PATH")
FILENAME=$(basename "$FILE_PATH" .dart)

# Buat folder
mkdir -p "$FOLDER"

# Buat file dengan template
case "$TYPE" in
    widget)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:flutter/material.dart';

class CLASSNAME_PLACEHOLDER extends StatelessWidget {
  const CLASSNAME_PLACEHOLDER({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: Implementasi widget
    );
  }
}
EOF
        ;;
    model)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:freezed_annotation/freezed_annotation.dart';

part 'FILENAME_PLACEHOLDER.freezed.dart';
part 'FILENAME_PLACEHOLDER.g.dart';

@freezed
class CLASSNAME_PLACEHOLDER with _$CLASSNAME_PLACEHOLDER {
  const factory CLASSNAME_PLACEHOLDER({
    required String id,
    // TODO: Tambahkan field
  }) = _CLASSNAME_PLACEHOLDER;

  factory CLASSNAME_PLACEHOLDER.fromJson(Map<String, dynamic> json) =>
      _$CLASSNAME_PLACEHOLDERFromJson(json);
}
EOF
        ;;
    provider)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'FILENAME_PLACEHOLDER.g.dart';

@riverpod
class CLASSNAME_PLACEHOLDER extends _$CLASSNAME_PLACEHOLDER {
  @override
  FutureOr<void> build() {
    // TODO: Implementasi provider
  }
}
EOF
        ;;
    page)
        cat > "$FILE_PATH" << 'EOF'
// path: PATH_PLACEHOLDER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLASSNAME_PLACEHOLDER extends ConsumerWidget {
  const CLASSNAME_PLACEHOLDER({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASSNAME_PLACEHOLDER'),
      ),
      body: const Center(
        child: Text('Halaman CLASSNAME_PLACEHOLDER'),
      ),
    );
  }
}
EOF
        ;;
    *)
        echo -e "${RED}❌ Tipe '$TYPE' tidak dikenal!${NC}"
        exit 1
        ;;
esac

# Ganti placeholder
sed -i "s|PATH_PLACEHOLDER|$FILE_PATH|g" "$FILE_PATH"
sed -i "s|FILENAME_PLACEHOLDER|$FILENAME|g" "$FILE_PATH"
sed -i "s|CLASSNAME_PLACEHOLDER|${FILENAME%_*}|g" "$FILE_PATH"

echo -e "${GREEN}✅ File berhasil dibuat dengan template:${NC}"
echo "  📁 $FILE_PATH"