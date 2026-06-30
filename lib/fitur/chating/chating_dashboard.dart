// path: lib/fitur/chating/chating_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/chating/chating.dart';
import 'package:wifi/fitur/chating/dummy_chatting.dart';
import 'package:wifi/fitur/chating/model/percakapan.dart';

class ChatingDashboard extends ConsumerWidget {
  const ChatingDashboard({super.key});

  String _formatWaktu(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays == 0) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${t.day}/${t.month}/${t.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan dummy conversations dari dummy_chatting.dart
    const chats = sampleConversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari percakapan',
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ChatSearchDelegate(chats),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Lainnya',
            onPressed: () {
              // buka menu atau pengaturan chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conv = chats[index];
                // Ambil pesan dummy untuk percakapan ini
                final msgs = sampleMessagesForConversation(conv.id);
                final lastMsg = msgs.isNotEmpty ? msgs.last : null;

                // Pratinjau: gunakan pratinjau dari percakapan atau teks pesan terakhir
                final preview =
                    conv.pratinjauPesanTerakhir ?? lastMsg?.teks ?? '-';

                // Waktu: gunakan waktuPesanTerakhir atau dibuatPada dari pesan terakhir
                final waktu = conv.waktuPesanTerakhir ?? lastMsg?.dibuatPada;
                final waktuTampil = waktu != null ? _formatWaktu(waktu) : '';

                // Judul: gunakan tampilkanJudul getter
                final judul = conv.tampilkanJudul;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    child: Text(
                      judul.isNotEmpty ? judul[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        waktuTampil,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (conv.jumlahBelumDibaca > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conv.jumlahBelumDibaca.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Konversi Pesan dari dummy ke data yang bisa dipakai Chating
                    final pesanAwal =
                        msgs; // sampleMessagesForConversation sudah List<Pesan>
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => Chating(
                          idPercakapan: conv.id,
                          namaLawanbicara: judul,
                          pesanAwal: pesanAwal,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Mulai percakapan baru',
        child: const Icon(Icons.chat),
        onPressed: () {
          // buka layar buat chat baru
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Percakapan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              // buka filter percakapan
            },
          ),
        ],
      ),
    );
  }
}

class _ChatSearchDelegate extends SearchDelegate<String> {
  final List<Percakapan> conversations;
  _ChatSearchDelegate(List<Percakapan> chats) : conversations = chats;

  @override
  String get searchFieldLabel => 'Cari nama atau pesan';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = conversations.where((c) {
      final q = query.toLowerCase();
      final judul = c.tampilkanJudul.toLowerCase();
      final msgs = sampleMessagesForConversation(c.id);
      final preview =
          c.pratinjauPesanTerakhir ??
          (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
      return judul.contains(q) || preview.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Tidak ada hasil'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conv = results[index];
        final judul = conv.tampilkanJudul;
        final msgs = sampleMessagesForConversation(conv.id);
        final preview =
            conv.pratinjauPesanTerakhir ??
            (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
        return ListTile(
          leading: CircleAvatar(
            child: Text(judul.isNotEmpty ? judul[0].toUpperCase() : '?'),
          ),
          title: Text(judul),
          subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            close(context, conv.id);
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Chating(
                  idPercakapan: conv.id,
                  namaLawanbicara: judul,
                  pesanAwal: msgs,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? conversations
        : conversations.where((c) {
            final q = query.toLowerCase();
            final judul = c.tampilkanJudul.toLowerCase();
            final msgs = sampleMessagesForConversation(c.id);
            final preview =
                c.pratinjauPesanTerakhir ??
                (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
            return judul.contains(q) || preview.toLowerCase().contains(q);
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final conv = suggestions[index];
        final judul = conv.tampilkanJudul;
        final msgs = sampleMessagesForConversation(conv.id);
        final preview =
            conv.pratinjauPesanTerakhir ??
            (msgs.isNotEmpty ? msgs.last.teks ?? '' : '');
        return ListTile(
          leading: CircleAvatar(
            child: Text(judul.isNotEmpty ? judul[0].toUpperCase() : '?'),
          ),
          title: Text(judul),
          subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            query = judul;
            showResults(context);
          },
        );
      },
    );
  }
}
