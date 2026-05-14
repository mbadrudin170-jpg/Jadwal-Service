// lib/shared/widget/radio_group_widget.dart
// diubah: Memperbaiki penggunaan RadioGroup dan menghilangkan deprecated member.
import 'package:flutter/material.dart';

// =============================================
// Enum
// =============================================

/// Karakter yang digunakan dalam contoh RadioGroup pertama.
enum SingingCharacter {
  /// Lafayette
  lafayette,

  /// Thomas Jefferson
  jefferson,
}

/// Genre musik yang digunakan dalam contoh RadioGroup kedua.
enum Genre {
  /// Genre Metal
  metal,

  /// Genre Jazz
  jazz,

  /// Genre Blues
  blues,
}

// =============================================
// Radio Group 1: SingingCharacterRadioGroup
// =============================================

/// Widget RadioGroup untuk memilih karakter bernyanyi.
///
/// Menampilkan dua opsi: Lafayette dan Thomas Jefferson.
/// Nilai default adalah [SingingCharacter.lafayette].
class SingingCharacterRadioGroup extends StatefulWidget {
  /// Nilai awal yang dipilih.
  final SingingCharacter? initialValue;

  /// Callback ketika nilai berubah.
  final ValueChanged<SingingCharacter?>? onChanged;

  /// Membuat instance [SingingCharacterRadioGroup].
  const SingingCharacterRadioGroup({
    super.key,
    this.initialValue = SingingCharacter.lafayette,
    this.onChanged,
  });

  @override
  State<SingingCharacterRadioGroup> createState() =>
      _SingingCharacterRadioGroupState();
}

class _SingingCharacterRadioGroupState
    extends State<SingingCharacterRadioGroup> {
  late SingingCharacter? _character;

  @override
  void initState() {
    super.initState();
    _character = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<SingingCharacter>(
      groupValue: _character,
      onChanged: (SingingCharacter? value) {
        setState(() {
          _character = value;
        });
        widget.onChanged?.call(value);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Selected: $_character'),
          const ListTile(
            title: Text('Lafayette'),
            leading: Radio<SingingCharacter>(value: SingingCharacter.lafayette),
          ),
          const ListTile(
            title: Text('Thomas Jefferson'),
            leading: Radio<SingingCharacter>(value: SingingCharacter.jefferson),
          ),
        ],
      ),
    );
  }
}

// =============================================
// Radio Group 2: GenreRadioGroup
// =============================================

/// Widget RadioGroup untuk memilih genre musik.
///
/// Menampilkan tiga opsi: Metal, Jazz, dan Blues.
/// Opsi Metal dapat di-toggle (toggleable = true).
/// Tidak ada nilai default (null).
class GenreRadioGroup extends StatefulWidget {
  /// Nilai awal yang dipilih.
  final Genre? initialValue;

  /// Callback ketika nilai berubah.
  final ValueChanged<Genre?>? onChanged;

  /// Membuat instance [GenreRadioGroup].
  const GenreRadioGroup({
    super.key,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<GenreRadioGroup> createState() => _GenreRadioGroupState();
}

class _GenreRadioGroupState extends State<GenreRadioGroup> {
  late Genre? _genre;

  @override
  void initState() {
    super.initState();
    _genre = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<Genre>(
      groupValue: _genre,
      onChanged: (Genre? value) {
        setState(() {
          _genre = value;
        });
        widget.onChanged?.call(value);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Selected: $_genre'),
          const ListTile(
            title: Text('Metal'),
            leading: Radio<Genre>(toggleable: true, value: Genre.metal),
          ),
          const ListTile(
            title: Text('Jazz'),
            leading: Radio<Genre>(value: Genre.jazz),
          ),
          const ListTile(
            title: Text('Blues'),
            leading: Radio<Genre>(value: Genre.blues),
          ),
        ],
      ),
    );
  }
}
