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
import 'package:wifi/shared/widget/date_time_picker_widget.dart';

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
    _loadAnnouncements();
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
      final announcements = await operator.getAll();
      final activeAnnouncement = announcements.firstWhere(
        (ann) => ann.isActive,
      );

      setState(() {
        _selectedAnnouncement = activeAnnouncement;
        _imageUrlController.text = activeAnnouncement.imageUrl;
        _isSwitched = activeAnnouncement.isActive;
        _selectedStartDate = activeAnnouncement.startDate;
        _selectedEndDate = activeAnnouncement.endDate;
      });
    }on Exception catch (e, st) {
      Log.error('Gagal memuat pengumuman', e: e, st: st);
      ToastUtil.error(context, 'Gagal memuat data pengumuman.');
    }
  }

  // Helper untuk memilih tanggal
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    if (isStartDate) {
      if (_selectedStartDate != null) {
        initialDate = _selectedStartDate!;
      }
    } else {
      if (_selectedEndDate != null) {
        initialDate = _selectedEndDate!;
      }
    }
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        final currentDateTime =
            isStartDate ? _selectedStartDate : _selectedEndDate;
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          currentDateTime?.hour ?? DateTime.now().hour,
          currentDateTime?.minute ?? DateTime.now().minute,
        );
        if (isStartDate) {
          _selectedStartDate = newDateTime;
        } else {
          _selectedEndDate = newDateTime;
        }
      });
    }
  }

  // Helper untuk memilih waktu
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime = TimeOfDay.now();
    final DateTime? currentDateTime =
        isStartTime ? _selectedStartDate : _selectedEndDate;
    if (currentDateTime != null) {
      initialTime =
          TimeOfDay(hour: currentDateTime.hour, minute: currentDateTime.minute);
    } else {
      initialTime = TimeOfDay.now();
    }
    final pickedTime =
        await showTimePicker(context: context, initialTime: initialTime);

    if (pickedTime != null) {
      setState(() {
        final DateTime? dateToUpdate =
            isStartTime ? _selectedStartDate : _selectedEndDate;
        final DateTime datePart = dateToUpdate ?? DateTime.now();

        final newDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isStartTime) {
          _selectedStartDate = newDateTime;
        } else {
          _selectedEndDate = newDateTime;
        }
      });
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

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      // Gunakan AppBarWidget kustom jika ada
      appBar: AppBar(
        title: const Text('Kelola Pengumuman'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(TSizes.p16),
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
              DateTimePickerWidget(
                  selectedDate: _selectedStartDate,
                  selectedTime: _selectedEndDate == null
                      ? null
                      : TimeOfDay(
                          hour: _selectedEndDate!.hour,
                          minute: _selectedEndDate!.minute),
                  onSelectDate: () => _selectDate(context, true),
                  onSelectTime: () => _selectTime(context, true)),
              DateTimePickerWidget(
                labelText: 'Selesai:', // Label spesifik untuk tanggal selesai
                selectedDate: _selectedEndDate,
                selectedTime: _selectedEndDate == null
                    ? null
                    : TimeOfDay(
                        hour: _selectedEndDate!.hour,
                        minute: _selectedEndDate!.minute),
                onSelectDate: () =>
                    _selectDate(context, false), // Panggil helper baru
                onSelectTime: () =>
                    _selectTime(context, false), // Panggil helper baru
              ),
              gapH16,

              SwitchListTile(
                title: const Text('Aktifkan Pengumuman'),
                subtitle: const Text(
                  'Jika diaktifkan, pengumuman ini akan tampil di aplikasi.',
                ),
                value: _isSwitched,
                secondary: const Icon(TIcons.toggleOn),
                onChanged: (final bool value) {
                  setState(() {
                    _isSwitched = value;
                  });
                },
                contentPadding: EdgeInsets.zero, // Sesuaikan padding jika perlu
              ),
              // gapH16,
              // if (_selectedAnnouncement == null)
              //   ElevatedButton.icon(
              //     icon: const Icon(TIcons.add),
              //     label: const Text('Buat Pengumuman Baru'),
              //     onPressed: () {
              //       setState(() {
              //         _selectedAnnouncement = null; // Reset ke mode tambah baru
              //         _imageUrlController.clear();
              //         _isSwitched = false; // Reset switch
              //         _formKey.currentState?.reset(); // Reset validasi form
              //         _scrollController.animateTo(0.0,
              //             duration: const Duration(milliseconds: 300),
              //             curve: Curves.easeOut);
              //       });
              //     },
              //   ),

              // Tombol Simpan (selalu tampil atau hanya saat ada perubahan)
              gapH16,

              // if (_selectedAnnouncement != null)
              //   Padding(
              //     padding: EdgeInsets.only(top: TSizes.p8),
              //     child: OutlinedButton.icon(
              //       icon: const Icon(TIcons.delete),
              //       label: const Text('Hapus Pengumuman Ini'),
              //       onPressed: _deleteAnnouncement,
              //       style: OutlinedButton.styleFrom(
              //         foregroundColor: Colors.red, // Warna teks tombol
              //         side: const BorderSide(color: Colors.red), // Warna border
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ElevatedButton.icon(
          icon: const Icon(TIcons.save),
          label: Text(_selectedAnnouncement == null
              ? 'Simpan Pengumuman'
              : 'Perbarui Pengumuman'),
          onPressed: _saveAnnouncement,
        ),
      ),
    );
  }
}
