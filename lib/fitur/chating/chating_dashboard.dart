import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/chating/chating.dart';

class ChatingDashboard extends ConsumerWidget {
  const ChatingDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Contoh data sementara; ganti dengan provider atau sumber data nyata
    final chats = <_ChatItem>[
      _ChatItem(
        id: '1',
        name: 'Budi',
        lastMessage: 'Halo, ada promo?',
        time: '09:12',
        unread: 2,
      ),
      _ChatItem(
        id: '2',
        name: 'Siti',
        lastMessage: 'Terima kasih',
        time: '08:45',
        unread: 0,
      ),
      _ChatItem(
        id: '3',
        name: 'Admin',
        lastMessage: 'Pembayaran diterima',
        time: 'Kemarin',
        unread: 1,
      ),
    ];

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
                final item = chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    child: Text(
                      item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    item.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (item.unread > 0)
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
                            item.unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (context) => Chating()),
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

class _ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;

  const _ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}

class _ChatSearchDelegate extends SearchDelegate<String> {
  final List<_ChatItem> chats;
  _ChatSearchDelegate(this.chats);

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
    final results = chats.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Tidak ada hasil'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: CircleAvatar(child: Text(item.name[0].toUpperCase())),
          title: Text(item.name),
          subtitle: Text(
            item.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            // buka chat detail
            close(context, item.id);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? chats
        : chats.where((c) {
            final q = query.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.lastMessage.toLowerCase().contains(q);
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: CircleAvatar(child: Text(item.name[0].toUpperCase())),
          title: Text(item.name),
          subtitle: Text(
            item.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            query = item.name;
            showResults(context);
          },
        );
      },
    );
  }
}
