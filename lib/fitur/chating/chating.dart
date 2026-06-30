// file: lib/fitur/chating/chating.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';

class Chating extends ConsumerStatefulWidget {
  final String idPercakapan;
  final String namaLawanbicara;
  final List<Pesan>? pesanAwal;
  final String idPenggunaSaatIni; // ID pengguna yang sedang login

  const Chating({
    super.key,
    required this.idPercakapan,
    required this.namaLawanbicara,
    this.pesanAwal,
    this.idPenggunaSaatIni = 'u1', // sementara hardcode, nanti dari auth
  });

  @override
  ConsumerState<Chating> createState() => _ChatingState();
}

class _ChatingState extends ConsumerState<Chating> {
  late final List<Pesan> _pesan;
  final TextEditingController _pengontrol = TextEditingController();
  final ScrollController _penggulir = ScrollController();
  bool _sedangMengirim = false;

  @override
  void initState() {
    super.initState();
    // gunakan pesan awal jika ada, atau daftar kosong
    _pesan = List<Pesan>.from(widget.pesanAwal ?? []);
  }

  @override
  void dispose() {
    _pengontrol.dispose();
    _penggulir.dispose();
    super.dispose();
  }

  Future<void> _kirimPesan({bool popAfterSend = false}) async {
    final teks = _pengontrol.text.trim();
    if (teks.isEmpty) return;

    final pesanBaru = Pesan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idPercakapan: widget.idPercakapan,
      idPengirim: widget.idPenggunaSaatIni,
      teks: teks,
      dibuatPada: DateTime.now(),
      status: StatusPesan.mengirim,
    );

    setState(() {
      _sedangMengirim = true;
      _pesan.add(pesanBaru);
      _pengontrol.clear();
    });
    _gulirKeBawah();

    // Simulasi pengiriman (ganti dengan backend call)
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Perbarui status menjadi terkirim
    setState(() {
      _pesan[_pesan.length - 1] = pesanBaru.copyWith(
        status: StatusPesan.terkirim,
      );
      _sedangMengirim = false;
    });

    if (popAfterSend) {
      if(mounted)
      Navigator.pop(context, pesanBaru);
    }
  }

  void _tutupDanKembalikanHasil() {
    final hasil = {
      'idPercakapan': widget.idPercakapan,
      'jumlahPesan': _pesan.length,
      'pesanTerakhir': _pesan.isNotEmpty ? _pesan.last : null,
    };
    Navigator.pop(context, hasil);
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_penggulir.hasClients) return;
      _penggulir.animateTo(
        _penggulir.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _tutupDanKembalikanHasil,
        ),
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaLawanbicara,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _penggulir,
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: _pesan.length,
                itemBuilder: (context, index) {
                  final m = _pesan[index];
                  final isMine = m.dariSaya(widget.idPenggunaSaatIni);
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: _bangunBubblePesan(m, isMine),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      // TODO: lampiran
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _pengontrol,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF2F3F5),
                      ),
                      onSubmitted: (_) => _kirimPesan(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sedangMengirim
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: _kirimPesan,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunBubblePesan(Pesan m, bool isMine) {
    final alignment = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMine ? Colors.blue.shade600 : Colors.grey.shade200;
    final textColor = isMine ? Colors.white : Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMine ? 12 : 0),
      bottomRight: Radius.circular(isMine ? 0 : 12),
    );

    // Tampilkan teks dan mungkin lampiran (disederhanakan dulu)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              decoration: BoxDecoration(color: bgColor, borderRadius: radius),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                m.teks ?? '',
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatWaktu(m.dibuatPada),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatWaktu(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inDays == 0) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } else {
      return '${t.day}/${t.month}/${t.year}';
    }
  }
}