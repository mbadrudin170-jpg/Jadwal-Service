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
  final _scrollController = ScrollController();
  late bool _isSwitched;
  EventModel? _selectedAnnouncement;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _isSwitched = false;
    _imageUrlController
        .addListener(() => setState(() {})); // Update UI saat text berubah
    _loadData();
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(() => setState(() {}));
    _imageUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final operator = ref.read(eventOpFirebaseProvider);
    try {
      final announcements = await operator.getAll();
      final EventModel? activeAnnouncement =
          announcements.cast<EventModel?>().firstWhere(
        (ann) => ann?.isActive ?? false,
        orElse: () {
          Log.info('Tidak ada pengumuman aktif ditemukan untuk dimuat.');
          return null;
        },
      );

      if (activeAnnouncement != null) {
        setState(() {
          _selectedAnnouncement = activeAnnouncement;
          _imageUrlController.text = activeAnnouncement.imageUrl;
          _isSwitched = activeAnnouncement.isActive;
          _selectedStartDate = activeAnnouncement.startDate;
          _selectedEndDate = activeAnnouncement.endDate;
        });
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat pengumuman', e: e, st: st);
      ToastUtil.error(context, 'Gagal memuat data pengumuman.');
    }
  }

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
    DateTime? pickedDate;
    try {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
    } catch (e, st) {
      Log.error('Error saat memilih tanggal', e: e, st: st);
      ToastUtil.error(context, 'Gagal membuka pemilih tanggal');
    }

    if (pickedDate != null) {
      setState(() {
        final currentDateTime =
            isStartDate ? _selectedStartDate : _selectedEndDate;
        final newDateTime = DateTime(
          pickedDate!.year,
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
    TimeOfDay? pickedTime;
    try {
      pickedTime =
          await showTimePicker(context: context, initialTime: initialTime);
    } catch (e, st) {
      Log.error('Error saat memilih waktu', e: e, st: st);
      ToastUtil.error(context, 'Gagal membuka pemilih waktu');
    }

    if (pickedTime != null) {
      setState(() {
        final DateTime? dateToUpdate =
            isStartTime ? _selectedStartDate : _selectedEndDate;
        final DateTime datePart = dateToUpdate ?? DateTime.now();

        final newDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          pickedTime!.hour,
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

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0.0, // Scroll ke atas halaman
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    if (_selectedStartDate == null || _selectedEndDate == null) {
      ToastUtil.error(context, 'Harap pilih tanggal mulai dan selesai');
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ToastUtil.error(
          context, 'Tanggal selesai tidak boleh sebelum tanggal mulai');
      return;
    }

    final operator = ref.read(eventOpFirebaseProvider);
    final String imageUrl = _imageUrlController.text.trim();
    final bool isActive = _isSwitched;
    final DateTime now = DateTime.now();
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
      createdAt: _selectedAnnouncement?.createdAt ?? now,
    );

    if (isActive) {
      try {
        final currentActive = await operator.getActive();
        if (currentActive != null &&
            currentActive.id != announcementToSave.id) {
          final oldActive =
              currentActive.copyWith(isActive: false, updatedAt: now);
          await operator.upsert(oldActive);
        }
      } catch (e, st) {
        Log.error('Gagal menonaktifkan pengumuman lama', e: e, st: st);
        ToastUtil.error(
            context, 'Gagal menonaktifkan pengumuman lain yang aktif.');
        return;
      }
    }

    try {
      await operator.upsert(announcementToSave);
      ToastUtil.success(context, 'Pengumuman berhasil disimpan!');
      Navigator.of(context).pop();
    } catch (e, st) {
      Log.error('Gagal menyimpan pengumuman', e: e, st: st);
      ToastUtil.error(context, 'Gagal menyimpan pengumuman.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
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
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL harus dimulai dengan http:// atau https://';
                  }
                  return null;
                },
              ),
              Text(_selectedStartDate == null
                  ? 'Tanggal & Jam Belum Dipilih'
                  : 'Mulai ${FormatDateTime.formatDateAndTimeCompact(_selectedStartDate!)}'),
              gapH8,
              DateTimePickerWidget(
                  selectedDate: _selectedStartDate,
                  selectedTime: _selectedStartDate == null
                      ? null
                      : TimeOfDay(
                          hour: _selectedStartDate!.hour,
                          minute: _selectedStartDate!.minute),
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
                onSelectDate: () => _selectDate(context, false),
                onSelectTime: () => _selectTime(context, false),
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
                contentPadding: EdgeInsets.zero,
              ),
              gapH16,
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
          onPressed: _saveData,
        ),
      ),
    );
  }
}
