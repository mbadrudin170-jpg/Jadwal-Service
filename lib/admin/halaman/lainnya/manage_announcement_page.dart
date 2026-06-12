// path: lib/admin/halaman/lainnya/manage_announcement_page.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';
import 'package:wifi/shared/services/image_storage_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/date_time_picker_widget.dart';

class ManageAnnouncementPage extends ConsumerStatefulWidget {
  const ManageAnnouncementPage({super.key, this.event});
  final EventModel? event;

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

  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _selectedAnnouncement = widget.event;
      _imageUrlController.text = widget.event!.imageUrl;
      _isSwitched = widget.event!.isActive;
      _selectedStartDate = widget.event!.startDate;
      _selectedEndDate = widget.event!.endDate;
    } else {
      _isSwitched = false;
    }
    unawaited(_loadData());
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.event != null) return;

    final operator = ref.read(eventOpSupabaseProvider);
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
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memuat data pengumuman.');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e, st) {
      Log.error('Gagal memilih gambar', e: e, st: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal memilih gambar dari galeri.');
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
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
      if (!mounted) return;
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

  Future<void> _selectTime(bool isStartTime) async {
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
      pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
    } catch (e, st) {
      Log.error('Error saat memilih waktu', e: e, st: st);
      if (!mounted) return;
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
    // 1. Validasi manual tanggal dan gambar karena tidak memakai TextFormField bawaan
    if (_selectedStartDate == null || _selectedEndDate == null) {
      ToastUtil.error(context, 'Harap pilih tanggal mulai dan selesai');
      return;
    }

    if (_selectedImage == null && _imageUrlController.text.trim().isEmpty) {
      ToastUtil.error(
          context, 'Harap pilih atau sediakan gambar untuk pengumuman.');
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ToastUtil.error(
          context, 'Tanggal selesai tidak boleh sebelum tanggal mulai');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String imageUrl = _imageUrlController.text.trim();

    // 2. Proses upload gambar ke storage jika admin memilih file gambar baru
    if (_selectedImage != null) {
      final storageService = ref.read(imageStorageServiceProvider);
      try {
        final String uploadUrl = await storageService.uploadImage(
            _selectedImage!, TableNameValue.get(TableName.events));
        imageUrl = uploadUrl;
        if (imageUrl.isEmpty) {
          throw Exception('URL gambar kosong dari storage service.');
        }
      } catch (e, st) {
        Log.error('Gagal mengunggah gambar', e: e, st: st);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal mengunggah gambar. Silakan coba lagi.');
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    final operator = ref.read(eventOpSupabaseProvider);
    final bool isActive = _isSwitched;
    final DateTime now = DateTime.now();

    // 3. REFAKTORISASI STRUKTUR OBJEK: Dipisahkan tegas antara Edit data vs Buat baru
    // Menjamin kolom 'not null' di Supabase selalu terisi dengan data terbaru dari UI
    final EventModel announcementToSave = _selectedAnnouncement != null
        ? _selectedAnnouncement!.copyWith(
            imageUrl: imageUrl,
            isActive: isActive,
            startDate: _selectedStartDate,
            endDate: _selectedEndDate,
            updatedAt: now,
          )
        : EventModel(
            id: const Uuid().v4(),
            createdAt: now,
            updatedAt: now,
            imageUrl: imageUrl,
            isActive: isActive,
            startDate: _selectedStartDate!,
            endDate: _selectedEndDate!,
          );

    // 4. Manajemen status aktif (Hanya izinkan satu pengumuman yang aktif secara simultan)
    if (isActive) {
      try {
        final currentActive = await operator.getActive();
        if (currentActive != null &&
            currentActive.id != announcementToSave.id) {
          final oldActive =
              currentActive.copyWith(isActive: false, updatedAt: now);
          await operator.update(oldActive);
        }
      } catch (e, st) {
        Log.error('Gagal menonaktifkan pengumuman lama', e: e, st: st);
        if (!mounted) return;
        ToastUtil.error(
            context, 'Gagal menonaktifkan pengumuman lain yang aktif.');
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    // 5. Eksekusi penyimpanan ke Supabase via Provider
    try {
      if (_selectedAnnouncement != null) {
        await operator.update(announcementToSave);
      } else {
        await operator.addEvent(announcementToSave);
      }
      final _ = ref.refresh(eventOpSupabaseProvider);
      if (!mounted) return;
      ToastUtil.success(context, 'Pengumuman berhasil disimpan!');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      Log.error('Gagal menyimpan pengumuman', e: e, st: st);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal menyimpan pengumuman.');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
// Image Preview and Picker
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                clipBehavior:
                    Clip.antiAlias, // Mencegah gambar keluar dari border radius
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. TAMPILAN JIKA ADA GAMBAR (LOKAL / URL)
                    if (_selectedImage != null)
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else if (_imageUrlController.text.isNotEmpty)
                      Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Text('Gagal memuat gambar dari URL'),
                        ),
                      )
                    else
                      // Tampilan placeholder jika sama sekali belum ada gambar
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image,
                              size: 50, color: Colors.grey.shade400),
                          gapH8,
                          Text('Belum ada gambar terpilih',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),

                    // 2. TOMBOL AKSI (Ditempatkan secara dinamis menggunakan Positioned)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.7),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        icon: Icon(
                            _selectedImage != null ||
                                    _imageUrlController.text.isNotEmpty
                                ? TIcons.edit
                                : TIcons.upload,
                            size: 18),
                        label: Text(_selectedImage != null ||
                                _imageUrlController.text.isNotEmpty
                            ? 'Ubah Gambar'
                            : 'Pilih Gambar'),
                      ),
                    ),
                  ],
                ),
              ),
              gapH16,

              DateTimePickerWidget(
                  labelText: 'Mulai:',
                  selectedDate: _selectedStartDate,
                  selectedTime: _selectedStartDate == null
                      ? null
                      : TimeOfDay(
                          hour: _selectedStartDate!.hour,
                          minute: _selectedStartDate!.minute),
                  onSelectDate: () => _selectDate(true),
                  onSelectTime: () => _selectTime(true)),
              DateTimePickerWidget(
                labelText: 'Selesai:',
                selectedDate: _selectedEndDate,
                selectedTime: _selectedEndDate == null
                    ? null
                    : TimeOfDay(
                        hour: _selectedEndDate!.hour,
                        minute: _selectedEndDate!.minute),
                onSelectDate: () => _selectDate(false),
                onSelectTime: () => _selectTime(false),
              ),
              gapH16,
              SwitchListTile(
                title: const Text('Aktifkan Pengumuman'),
                subtitle: const Text(
                  'Jika diaktifkan, pengumuman ini akan tampil di aplikasi.',
                ),
                value: _isSwitched,
                secondary: const Icon(TIcons.toggleOn),
                onChanged: (bool value) {
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  icon: const Icon(TIcons.save),
                  label: Text(_selectedAnnouncement == null
                      ? 'Simpan Pengumuman'
                      : 'Perbarui Pengumuman'),
                  onPressed: _isUploading ? null : _saveData,
                ),
        ),
      ),
    );
  }
}
