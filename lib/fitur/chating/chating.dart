import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Chating extends ConsumerStatefulWidget {
  const Chating({super.key});

  @override
  ConsumerState<Chating> createState() => _ChatingState();
}

class _ChatingState extends ConsumerState<Chating> {
  final List<_Message> _pesan = [
    _Message(
      id: '1',
      teks: 'Halo, ada yang bisa dibantu?',
      dariSaya: false,
      waktu: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    _Message(
      id: '2',
      teks: 'Saya mau tanya soal paket internet.',
      dariSaya: true,
      waktu: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    _Message(
      id: '3',
      teks: 'Silakan, sebutkan kendalanya.',
      dariSaya: false,
      waktu: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  final TextEditingController _pengontrol = TextEditingController();
  final ScrollController _penggulir = ScrollController();
  bool _sedangMengirim = false;

  @override
  void dispose() {
    _pengontrol.dispose();
    _penggulir.dispose();
    super.dispose();
  }

  Future<void> _kirimPesan() async {
    final teks = _pengontrol.text.trim();
    if (teks.isEmpty) return;
    setState(() {
      _sedangMengirim = true;
      _pesan.add(
        _Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          teks: teks,
          dariSaya: true,
          waktu: DateTime.now(),
        ),
      );
      _pengontrol.clear();
    });
    _gulirKeBawah();

    // Simulasi pengiriman ke server / balasan otomatis
    await Future<void>.delayed(const Duration(milliseconds: 400));
    setState(() {
      _sedangMengirim = false;
    });

    // Contoh balasan otomatis (hapus atau ganti dengan logika nyata)
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _pesan.add(
          _Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            teks: 'Terima kasih, kami akan cek dan segera merespon.',
            dariSaya: false,
            waktu: DateTime.now(),
          ),
        );
      });
      _gulirKeBawah();
    });
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

  Widget _bangunBubblePesan(_Message m) {
    final alignment = m.dariSaya
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bgColor = m.dariSaya ? Colors.blue.shade600 : Colors.grey.shade200;
    final textColor = m.dariSaya ? Colors.white : Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(m.dariSaya ? 12 : 0),
      bottomRight: Radius.circular(m.dariSaya ? 0 : 12),
    );

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
                m.teks,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatWaktu(m.waktu),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Support',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
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
            // Daftar pesan
            Expanded(
              child: ListView.builder(
                controller: _penggulir,
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: _pesan.length,
                itemBuilder: (context, index) {
                  final m = _pesan[index];
                  return Align(
                    alignment: m.dariSaya
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _bangunBubblePesan(m),
                  );
                },
              ),
            ),

            // Area input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      // lampirkan file / foto
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
}

class _Message {
  final String id;
  final String teks;
  final bool dariSaya;
  final DateTime waktu;

  _Message({
    required this.id,
    required this.teks,
    required this.dariSaya,
    required this.waktu,
  });
}
