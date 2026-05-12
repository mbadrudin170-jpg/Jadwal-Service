// path: lib/admin/halaman/form/form_kategori.dart

import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/data/sync/unggah_data.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:uuid/uuid.dart';

class FormKategoriPage extends StatefulWidget {
  final KategoriModel? kategori;
  final SubKategoriModel? subKategori;
  final String? idKategoriInduk;

  const FormKategoriPage({
    super.key,
    this.kategori,
    this.subKategori,
    this.idKategoriInduk,
  });

  @override
  State<FormKategoriPage> createState() => _FormKategoriPageState();
}

class _FormKategoriPageState extends State<FormKategoriPage> {
  final _formKey = GlobalKey<FormState>();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final LayananUnggahData _layananUnggahData = LayananUnggahData();

  late TipeKategori _tipe;
  late TextEditingController _namaController;
  final _namaFocusNode = FocusNode();

  final List<TextEditingController> _subKategoriControllers = [];

  bool get _isEditMode => widget.kategori != null || widget.subKategori != null;
  bool get _isSubKategoriMode =>
      widget.subKategori != null || widget.idKategoriInduk != null;

  final _cekKoneksi = KoneksiInternetService();

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.kategori != null || widget.subKategori != null;
    final isSubKategoriMode = widget.subKategori != null || widget.idKategoriInduk != null;
    
    Log.info('Membuat state untuk FormKategoriPage. '
        'Mode: ${isEditMode ? "EDIT" : "TAMBAH BARU"}, '
        'Jenis: ${isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}, '
        '${widget.kategori != null ? "Kategori: ${widget.kategori!.nama} (ID: ${widget.kategori!.id})" : ""}'
        '${widget.subKategori != null ? "Sub-Kategori: ${widget.subKategori!.nama} (ID: ${widget.subKategori!.id})" : ""}'
        '${widget.idKategoriInduk != null ? "ID Kategori Induk: ${widget.idKategoriInduk}" : ""}');

    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman FormKategoriPage');
    Log.info('========================================');
    
    Log.info('Membuat TextEditingController untuk input nama.');
    _namaController = TextEditingController();
    Log.info('TextEditingController berhasil dibuat.');

    Log.info('Membuat FocusNode untuk input nama.');
    Log.info('FocusNode berhasil dibuat: ${_namaFocusNode.hashCode}');

    if (widget.kategori != null) {
      Log.info('MODE EDIT KATEGORI UTAMA terdeteksi.');
      Log.info('Data kategori yang akan diedit:');
      Log.info('  - ID: ${widget.kategori!.id}');
      Log.info('  - Nama: ${widget.kategori!.nama}');
      Log.info('  - Tipe: ${widget.kategori!.tipe}');
      Log.info('  - Jumlah Sub-Kategori: ${widget.kategori!.subKategori.length}');
      Log.info('  - Diperbarui: ${widget.kategori!.diperbarui}');
      Log.info('  - isDeleted: ${widget.kategori!.isDeleted}');
      Log.info('  - Diarsipkan: ${widget.kategori!.diarsipkan ?? "NULL"}');
      
      Log.info('Mengisi TextEditingController dengan nama kategori: "${widget.kategori!.nama}"');
      _namaController.text = widget.kategori!.nama;
      _tipe = widget.kategori!.tipe;
      Log.info('Tipe kategori diatur ke: ${widget.kategori!.tipe}');
      
    } else if (widget.subKategori != null) {
      Log.info('MODE EDIT SUB-KATEGORI terdeteksi.');
      Log.info('Data sub-kategori yang akan diedit:');
      Log.info('  - ID: ${widget.subKategori!.id}');
      Log.info('  - Nama: ${widget.subKategori!.nama}');
      Log.info('  - ID Kategori Induk: ${widget.subKategori!.idKategori}');
      Log.info('  - Diperbarui: ${widget.subKategori!.diperbarui}');
      
      Log.info('Mengisi TextEditingController dengan nama sub-kategori: "${widget.subKategori!.nama}"');
      _namaController.text = widget.subKategori!.nama;
      
    } else {
      Log.info('MODE TAMBAH BARU terdeteksi.');
      Log.info('Form akan membuat kategori baru dengan:');
      Log.info('  - ID: Akan digenerate otomatis menggunakan UUID v4');
      Log.info('  - Tipe Default: pemasukan');
      Log.info('  - Nama: Dari input pengguna');
      Log.info('  - Sub-Kategori: Opsional, bisa ditambahkan multiple');
      Log.info('  - Diperbarui: DateTime.now()');
      
      Log.info('Mengatur tipe default ke pemasukan.');
      _tipe = TipeKategori.pemasukan;
      Log.info('Tipe kategori diatur ke: $_tipe');
      
      Log.info('Menambahkan field input sub-kategori pertama secara default.');
      _tambahInputSubKategori();
    }
    
    Log.info('Inisialisasi FormKategoriPage selesai. Siap menerima input dari pengguna.');
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman FormKategoriPage');
    Log.info('Membersihkan resource:');
    Log.info('  - Mendispose TextEditingController utama (_namaController)');
    Log.info('  - Mendispose FocusNode (_namaFocusNode)');
    Log.info('  - Mendispose ${_subKategoriControllers.length} TextEditingController sub-kategori');
    Log.info('========================================');
    
    _namaController.dispose();
    _namaFocusNode.dispose();
    
    for (int i = 0; i < _subKategoriControllers.length; i++) {
      Log.info('  Mendispose sub-kategori controller ke-${i + 1}');
      _subKategoriControllers[i].dispose();
    }
    
    Log.info('Semua resource berhasil dibersihkan.');
    super.dispose();
  }

  void _tambahInputSubKategori() {
    Log.info('========================================');
    Log.info('AKSI: Menambahkan field input sub-kategori baru');
    Log.info('Jumlah field sub-kategori sebelum ditambah: ${_subKategoriControllers.length}');
    Log.info('========================================');
    
    setState(() {
      _subKategoriControllers.add(TextEditingController());
    });
    
    Log.info('Field sub-kategori baru berhasil ditambahkan.');
    Log.info('Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}');
    Log.info('Index field baru: ${_subKategoriControllers.length - 1}');
  }

  void _hapusInputSubKategori(int index) {
    Log.info('========================================');
    Log.info('AKSI: Menghapus field input sub-kategori');
    Log.info('Index yang akan dihapus: $index');
    Log.info('Jumlah field sub-kategori sebelum dihapus: ${_subKategoriControllers.length}');
    
    if (index >= 0 && index < _subKategoriControllers.length) {
      Log.info('Nilai field sebelum dihapus: "${_subKategoriControllers[index].text}"');
    } else {
      Log.warning('Index $index tidak valid. Jumlah field: ${_subKategoriControllers.length}');
    }
    Log.info('========================================');
    
    setState(() {
      Log.info('Mendispose controller pada index $index.');
      _subKategoriControllers[index].dispose();
      Log.info('Menghapus controller dari list.');
      _subKategoriControllers.removeAt(index);
    });
    
    Log.info('Field sub-kategori berhasil dihapus.');
    Log.info('Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}');
  }

  void _simpanForm() async {
    Log.info('========================================');
    Log.info('AKSI: Tombol Simpan Ditekan');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Jenis: ${_isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}');
    Log.info('Nama yang akan disimpan: "${_namaController.text}"');
    Log.info('Tipe kategori: $_tipe');
    Log.info('========================================');
    
    Log.info('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      Log.info('Validasi form BERHASIL. Semua input valid.');
      
      try {
        if (_isEditMode && widget.subKategori != null) {
          Log.info('========================================');
          Log.info('PROSES UPDATE SUB-KATEGORI (MODE EDIT SUB-KATEGORI)');
          Log.info('========================================');
          
          Log.info('Data sub-kategori sebelum update:');
          Log.info('  - ID: ${widget.subKategori!.id}');
          Log.info('  - Nama Lama: ${widget.subKategori!.nama}');
          Log.info('  - Nama Baru: ${_namaController.text}');
          Log.info('  - ID Kategori Induk: ${widget.idKategoriInduk}');
          
          if (widget.idKategoriInduk == null) {
            Log.error('ID kategori induk tidak ditemukan saat mengedit sub-kategori. '
                'Ini adalah kesalahan logika karena sub-kategori harus selalu memiliki kategori induk.');
            throw Exception('ID kategori induk tidak ditemukan saat mengedit sub-kategori.');
          }
          
          Log.info('Mengambil data kategori induk dengan ID: ${widget.idKategoriInduk}');
          final kategoriInduk = await _kategoriOperasi.getKategoriById(widget.idKategoriInduk!);
          
          Log.info('Kategori induk ditemukan: ${kategoriInduk.nama} (memiliki ${kategoriInduk.subKategori.length} sub-kategori).');
          Log.info('Mencari index sub-kategori dengan ID: ${widget.subKategori!.id} dalam daftar sub-kategori.');
          
          final subKategoriIndex = kategoriInduk.subKategori.indexWhere((s) => s.id == widget.subKategori!.id);

          if (subKategoriIndex != -1) {
            Log.info('Sub-kategori ditemukan pada index: $subKategoriIndex');
            Log.info('Nama sub-kategori sebelum update: "${kategoriInduk.subKategori[subKategoriIndex].nama}"');
            
            Log.info('Membuat salinan sub-kategori dengan nama baru dan timestamp diperbarui.');
            final subKategoriDiperbarui = kategoriInduk.subKategori[subKategoriIndex].copyWith(
              nama: _namaController.text,
              diperbarui: DateTime.now(),
            );
            
            Log.info('Mengganti sub-kategori pada index $subKategoriIndex dengan data baru.');
            kategoriInduk.subKategori[subKategoriIndex] = subKategoriDiperbarui;
            
            Log.info('Memanggil _kategoriOperasi.update() untuk menyimpan perubahan kategori induk.');
            await _kategoriOperasi.update(kategoriInduk);
            
            Log.info('Update sub-kategori BERHASIL.');
            Log.info('Nama sub-kategori berubah dari "${widget.subKategori!.nama}" menjadi "${_namaController.text}"');
          } else {
            Log.error('Sub-kategori dengan ID ${widget.subKategori!.id} tidak ditemukan dalam daftar sub-kategori kategori induk.');
            throw Exception('Sub-kategori tidak ditemukan untuk diedit.');
          }
          
        } else if (_isEditMode && widget.kategori != null) {
          Log.info('========================================');
          Log.info('PROSES UPDATE KATEGORI UTAMA (MODE EDIT KATEGORI)');
          Log.info('========================================');
          
          Log.info('Data kategori sebelum update:');
          Log.info('  - ID: ${widget.kategori!.id}');
          Log.info('  - Nama Lama: ${widget.kategori!.nama}');
          Log.info('  - Nama Baru: ${_namaController.text}');
          Log.info('  - Tipe Lama: ${widget.kategori!.tipe}');
          Log.info('  - Tipe Baru: $_tipe');
          
          Log.info('Membuat salinan kategori dengan data baru dan timestamp diperbarui.');
          final kategoriDiperbarui = widget.kategori!.copyWith(
            nama: _namaController.text,
            tipe: _tipe,
            diperbarui: DateTime.now(),
          );
          
          Log.info('Objek KategoriModel baru:');
          Log.info('  - ID: ${kategoriDiperbarui.id}');
          Log.info('  - Nama: ${kategoriDiperbarui.nama}');
          Log.info('  - Tipe: ${kategoriDiperbarui.tipe}');
          Log.info('  - Diperbarui: ${kategoriDiperbarui.diperbarui}');
          
          Log.info('Memanggil _kategoriOperasi.update() untuk menyimpan perubahan.');
          await _kategoriOperasi.update(kategoriDiperbarui);
          
          Log.info('Update kategori utama BERHASIL.');
          Log.info('Nama kategori berubah dari "${widget.kategori!.nama}" menjadi "${_namaController.text}"');
          Log.info('Tipe kategori berubah dari "${widget.kategori!.tipe}" menjadi "$_tipe"');
          
        } else {
          Log.info('========================================');
          Log.info('PROSES TAMBAH KATEGORI BARU (MODE TAMBAH)');
          Log.info('========================================');
          
          Log.info('Menggenerate UUID v4 untuk ID kategori baru.');
          final String kategoriId = const Uuid().v4();
          Log.info('UUID berhasil digenerate: $kategoriId');
          
          Log.info('Memproses ${_subKategoriControllers.length} field input sub-kategori.');
          
          int subKategoriKosong = 0;
          int subKategoriTerisi = 0;
          
          final List<SubKategoriModel> subKategoriList = _subKategoriControllers
              .where((controller) {
                final isEmpty = controller.text.isEmpty;
                if (isEmpty) {
                  subKategoriKosong++;
                  Log.info('  Sub-kategori dengan nilai "${controller.text}" akan DIABAIKAN karena kosong.');
                } else {
                  subKategoriTerisi++;
                  Log.info('  Sub-kategori dengan nilai "${controller.text}" akan DISIMPAN.');
                }
                return !isEmpty;
              })
              .map((controller) => SubKategoriModel(
                    nama: controller.text,
                    idKategori: kategoriId,
                    diperbarui: DateTime.now(),
                  ))
              .toList();
          
          Log.info('Ringkasan sub-kategori: $subKategoriTerisi akan disimpan, $subKategoriKosong diabaikan.');
          
          Log.info('Membuat objek KategoriModel baru.');
          final kategoriBaru = KategoriModel(
            id: kategoriId,
            nama: _namaController.text,
            tipe: _tipe,
            subKategori: subKategoriList,
            diperbarui: DateTime.now(),
          );
          
          Log.info('Objek KategoriModel berhasil dibuat:');
          Log.info('  - ID: ${kategoriBaru.id}');
          Log.info('  - Nama: ${kategoriBaru.nama}');
          Log.info('  - Tipe: ${kategoriBaru.tipe}');
          Log.info('  - Jumlah Sub-Kategori: ${kategoriBaru.subKategori.length}');
          Log.info('  - Diperbarui: ${kategoriBaru.diperbarui}');
          
          Log.info('Memanggil _kategoriOperasi.createKategori() untuk menyimpan kategori baru.');
          await _kategoriOperasi.createKategori(kategoriBaru);
          
          Log.info('Kategori baru BERHASIL disimpan ke database lokal.');
        }

        Log.info('========================================');
        Log.info('MEMERIKSA KONEKSI INTERNET UNTUK SINKRONISASI');
        Log.info('========================================');
        
        Log.info('Memeriksa koneksi internet...');
        final isOnline = await _cekKoneksi.cekKoneksi();
        Log.info('Status koneksi: ${isOnline ? "ONLINE" : "OFFLINE"}');
        
        if (isOnline) {
          Log.info('Koneksi internet tersedia. Melakukan sinkronisasi data kategori ke Firestore.');
          await _layananUnggahData.unggahDataKategori();
          Log.info('Sinkronisasi data kategori ke cloud BERHASIL.');
        } else {
          Log.info('Tidak ada koneksi internet. Data hanya disimpan secara lokal.');
          Log.info('Sinkronisasi akan dilakukan saat koneksi tersedia nanti.');
        }

        Log.info('========================================');
        Log.info('PENYIMPANAN DATA BERHASIL');
        Log.info('========================================');

        if (!mounted) {
          Log.warning('Widget sudah tidak mounted setelah penyimpanan berhasil. '
              'Tidak dapat menampilkan SnackBar atau melakukan Navigator.pop.');
          return;
        }

        Log.info('Widget masih mounted. Menampilkan SnackBar sukses.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isSubKategoriMode ? 'Sub-Kategori' : 'Kategori'} berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Log.info('SnackBar sukses telah ditampilkan.');
        
        Log.info('Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.');
        Log.info('Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.');
        Navigator.pop(context, true);
        Log.info('Navigator.pop berhasil dijalankan.');
        
      } catch (e, s) {
        Log.error(
          'Gagal menyimpan ${_isSubKategoriMode ? 'sub-kategori' : 'kategori'}. '
          'Proses ${_isEditMode ? 'update' : 'create'} mengalami kegagalan. '
          'Kemungkinan penyebab: koneksi database gagal, constraint violation, '
          'data tidak valid, atau terjadi error saat operasi database.',
          e: e,
          st: s,
        );
        
        if (!mounted) {
          Log.warning('Widget sudah tidak mounted setelah error. Tidak dapat menampilkan SnackBar error.');
          return;
        }
        
        Log.info('Widget masih mounted. Menampilkan SnackBar error ke pengguna.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Log.info('SnackBar error telah ditampilkan.');
      }
    } else {
      Log.warning('Validasi form GAGAL. Terdapat input yang tidak valid.');
      Log.warning('Kemungkinan penyebab: Nama kategori/sub-kategori kosong atau tidak memenuhi kriteria validasi.');
      Log.info('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String judul = 'Form Kategori';
    if (_isEditMode && widget.kategori != null) judul = 'Edit Kategori';
    if (_isEditMode && widget.subKategori != null) judul = 'Edit Sub-Kategori';
    if (!_isEditMode && widget.idKategoriInduk != null) judul = 'Tambah Sub-Kategori';
    if (!_isEditMode && widget.kategori == null && widget.subKategori == null) judul = 'Tambah Kategori Baru';

    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI FormKategoriPage');
    Log.info('Judul halaman: "$judul"');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Jenis: ${_isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}');
    Log.info('Nama di controller: "${_namaController.text}"');
    Log.info('Tipe terpilih: $_tipe');
    Log.info('Jumlah field sub-kategori: ${_subKategoriControllers.length}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
        leading: BackButton(
          onPressed: () {
            Log.info('NAVIGASI: Tombol Kembali ditekan. '
                'Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  decoration: InputDecoration(
                    labelText: _isSubKategoriMode ? 'Nama Sub-Kategori' : 'Nama Kategori',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    Log.info('INPUT: Field nama disubmit melalui keyboard (TextInputAction.done).');
                    Log.info('Nilai yang disubmit: "${_namaController.text}"');
                    Log.info('Menghilangkan fokus dari input.');
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (value) {
                    Log.info('INPUT: Nama ${_isSubKategoriMode ? "sub-kategori" : "kategori"} berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                  },
                  validator: (value) {
                    Log.info('VALIDASI: Memvalidasi input nama. Nilai: "${value ?? "NULL"}"');
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Nama kosong.');
                      return 'Nama tidak boleh kosong';
                    }
                    Log.info('VALIDASI BERHASIL: Nama valid.');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (!_isEditMode && !_isSubKategoriMode) ...[
                  DropdownButtonFormField<TipeKategori>(
                    initialValue: _tipe,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: TipeKategori.values
                        .where((tipe) => tipe != TipeKategori.transfer)
                        .map((TipeKategori tipe) {
                      return DropdownMenuItem<TipeKategori>(
                        value: tipe,
                        child: Text(
                          tipe.name.substring(0, 1).toUpperCase() + tipe.name.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (TipeKategori? newValue) {
                      if (newValue != null) {
                        Log.info('DROPDOWN: Tipe kategori diubah.');
                        Log.info('  - Tipe Lama: $_tipe');
                        Log.info('  - Tipe Baru: $newValue');
                        setState(() {
                          _tipe = newValue;
                        });
                        Log.info('State _tipe berhasil diperbarui ke: $_tipe');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tambah Sub-Kategori (Opsional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subKategoriControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subKategoriControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Nama Sub-Kategori ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  Log.info('INPUT: Sub-kategori ke-${index + 1} berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                Log.info('AKSI: Tombol hapus sub-kategori ke-${index + 1} ditekan.');
                                _hapusInputSubKategori(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Log.info('AKSI: Tombol "Tambah Input" sub-kategori ditekan.');
                        _tambahInputSubKategori();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Input'),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Log.info('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    _simpanForm();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
