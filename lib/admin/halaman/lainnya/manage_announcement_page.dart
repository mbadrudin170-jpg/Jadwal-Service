// path: lib/admin/halaman/lainnya/manage_announcement_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_firebase.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

// Gunakan ConsumerWidget agar bisa mengakses provider
class ManageAnnouncementPage extends ConsumerStatefulWidget {
  const ManageAnnouncementPage({super.key});

  @override
  ConsumerState<ManageAnnouncementPage> createState() =>
      _ManageAnnouncementPageState();
}

class _ManageAnnouncementPageState
    extends ConsumerState<ManageAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _scrollController =
      ScrollController(); // Untuk scroll ke error jika ada
  late bool _isSwitched;
  EventModel?
      _selectedAnnouncement; // null jika menambah baru, atau announcement yang diedit
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    // Inisialisasi state awal
    _isSwitched = false; // Defaultnya tidak aktif
    _imageUrlController
        .addListener(() => setState(() {})); // Update UI saat text berubah
    _loadAnnouncements;
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(() => setState(() {}));
    _imageUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Memuat daftar pengumuman dan mengisi form jika ada yang aktif/dipilih.
  Future<void> _loadAnnouncements() async {
    final operator = ref.read(eventOpFirebaseProvider);
    try {
      // Ambil semua pengumuman
      final announcements = await operator.getAll();

      // Cari pengumuman yang aktif
      final activeAnnouncement = announcements.firstWhere(
        (ann) => ann.isActive,
      );

      setState(() {
        _selectedAnnouncement = activeAnnouncement;
        _imageUrlController.text = activeAnnouncement.imageUrl;
        _isSwitched = activeAnnouncement.isActive;
      });
    } catch (e, st) {
      Log.error('Gagal memuat pengumuman', e: e, st: st);
      ToastUtil.error(context, 'Gagal memuat data pengumuman.');
    }
  }

// Tambahkan fungsi ini di dalam State class Anda:
  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Atur rentang tanggal sesuai kebutuhan
      lastDate: DateTime(2101), // Atur rentang tanggal sesuai kebutuhan
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          final DateTime combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartTime) {
            _selectedStartDate = combinedDateTime;
          } else {
            _selectedEndDate = combinedDateTime;
          }
        });
      }
    }
  }

  /// Menyimpan pengumuman (baru atau update).
  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0.0, // Scroll ke atas halaman
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    final operator = ref.read(eventOpFirebaseProvider);
    final String imageUrl = _imageUrlController.text.trim();
    final bool isActive = _isSwitched;
    final DateTime now = DateTime.now().toUtc();
    final EventModel announcementToSave = (_selectedAnnouncement ??
            EventModel(
              id: const Uuid().v4(),
              createdAt: now,
              imageUrl: imageUrl,
              isActive: isActive,
              startDate: _selectedStartDate!,
              endDate: _selectedEndDate!,
            ))
        .copyWith(
      imageUrl: imageUrl,
      isActive: isActive,
      updatedAt: now,
      // createdAt tidak diubah jika update
      createdAt: _selectedAnnouncement?.createdAt ?? now,
    );

    // Pastikan hanya satu pengumuman yang aktif
    if (isActive) {
      try {
        // Cek apakah ada pengumuman lain yang aktif
        final currentActive = await operator.getActive();
        if (currentActive != null &&
            currentActive.id != announcementToSave.id) {
          // Nonaktifkan pengumuman yang aktif sebelumnya
          final oldActive =
              currentActive.copyWith(isActive: false, updatedAt: now);
          await operator.upsert(oldActive);
        }
      } catch (e, st) {
        Log.error('Gagal menonaktifkan pengumuman aktif sebelumnya',
            e: e, st: st);
        ToastUtil.error(context, 'Gagal menonaktifkan pengumuman lain.');
        return; // Hentikan proses jika gagal menonaktifkan yang lama
      }
    }

    try {
      await operator.upsert(announcementToSave);
      ToastUtil.success(context, 'Pengumuman berhasil disimpan!');
      // Kembali ke halaman sebelumnya atau refresh daftar
      Navigator.of(context).pop();
    } catch (e, st) {
      Log.error('Gagal menyimpan pengumuman', e: e, st: st);
      ToastUtil.error(context, 'Gagal menyimpan pengumuman.');
    }
  }

  /// Menghapus pengumuman yang sedang dipilih/diedit.
  Future<void> _deleteAnnouncement() async {
    if (_selectedAnnouncement == null) {
      ToastUtil.info(context, 'Pilih pengumuman yang akan dihapus.');
      return;
    }

    final operator = ref.read(eventOpFirebaseProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus pengumuman ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await operator.deleteEvent(_selectedAnnouncement!.id);
        ToastUtil.success(context, 'Pengumuman berhasil dihapus!');
        Navigator.of(context).pop(); // Kembali setelah berhasil dihapus
      } catch (e, st) {
        Log.error('Gagal menghapus pengumuman', e: e, st: st);
        ToastUtil.error(context, 'Gagal menghapus pengumuman.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      // Gunakan AppBarWidget kustom jika ada
      appBar: AppBar(
        title: Text('Kelola Pengumuman'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.save),
            tooltip: 'Simpan Pengumuman',
            onPressed: _saveAnnouncement,
          ),
          if (_selectedAnnouncement != null)
            IconButton(
              icon: const Icon(TIcons.delete),
              tooltip: 'Hapus Pengumuman',
              onPressed: _deleteAnnouncement,
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detail Pengumuman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              gapH16,
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (Direct Link)',
                  hintText: 'https://contoh.com/gambar.jpg',
                  prefixIcon: Icon(TIcons.link),
                  border: OutlineInputBorder(),
                ),
                validator: (final value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'URL gambar wajib diisi';
                  }
                  // Tambahkan validasi format URL jika perlu
                  // Contoh sederhana:
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL harus dimulai dengan http:// atau https://';
                  }
                  return null;
                },
                // Tidak perlu setState di onChanged karena decoration tidak bergantung pada input
                // onChanged: (final _) => setState(() {}),
              ),
              Text(_selectedStartDate == null
                  ? 'Tanggal & Jam Belum Dipilih'
                  : 'Mulai ${FormatDateTime.formatDateAndTimeCompact(_selectedStartDate!)}'),
              gapH8,
              ElevatedButton(
                onPressed: () => _selectDateTime(true),
                child: const Text('Pilih Tanggal & Jam Mulai'),
              ),
              gapH16,
              const SizedBox(height: 16), // Spasi antar elemen
              Text(_selectedEndDate == null
                  ? 'Tanggal & Jam Selesai Belum Dipilih'
                  : 'Selesai: ${_selectedEndDate!.toLocal().toString().split(' ')[0]} ${_selectedEndDate!.toLocal().toString().split(' ')[1].split('.')[0]}'), // Format: YYYY-MM-DD HH:MM
              const SizedBox(height: 8), // Spasi antar elemen
              ElevatedButton(
                onPressed: () => _selectDateTime(false),
                child: const Text('Pilih Tanggal & Jam Selesai'),
              ),
              gapH16,
              SwitchListTile(
                title: const Text('Aktifkan Pengumuman'),
                subtitle: const Text(
                  'Jika diaktifkan, pengumuman ini akan tampil di aplikasi.',
                ),
                value: _isSwitched,
                secondary: const Icon(TIcons.toggle_on),
                onChanged: (final bool value) {
                  setState(() {
                    _isSwitched = value;
                  });
                },
                contentPadding: EdgeInsets.zero, // Sesuaikan padding jika perlu
              ),
              gapH16,
              if (_selectedAnnouncement == null)
                ElevatedButton.icon(
                  icon: const Icon(TIcons.add),
                  label: const Text('Buat Pengumuman Baru'),
                  onPressed: () {
                    setState(() {
                      _selectedAnnouncement = null; // Reset ke mode tambah baru
                      _imageUrlController.clear();
                      _isSwitched = false; // Reset switch
                      _formKey.currentState?.reset(); // Reset validasi form
                      _scrollController.animateTo(0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    });
                  },
                ),

              // Tombol Simpan (selalu tampil atau hanya saat ada perubahan)
              gapH16,
              ElevatedButton.icon(
                icon: const Icon(TIcons.save),
                label: Text(_selectedAnnouncement == null
                    ? 'Simpan Pengumuman'
                    : 'Perbarui Pengumuman'),
                onPressed: _saveAnnouncement,
              ),

              if (_selectedAnnouncement != null)
                Padding(
                  padding: EdgeInsets.only(top: TSizes.p8),
                  child: OutlinedButton.icon(
                    icon: const Icon(TIcons.delete),
                    label: const Text('Hapus Pengumuman Ini'),
                    onPressed: _deleteAnnouncement,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, // Warna teks tombol
                      side: const BorderSide(color: Colors.red), // Warna border
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
