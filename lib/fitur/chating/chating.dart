import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Chating extends ConsumerStatefulWidget {
  const Chating({super.key});

  @override
  ConsumerState<Chating> createState() => _ChatingState();
}

class _ChatingState extends ConsumerState<Chating> {
  final List<_Message> _messages = [
    _Message(
      id: '1',
      text: 'Halo, ada yang bisa dibantu?',
      isMine: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    _Message(
      id: '2',
      text: 'Saya mau tanya soal paket internet.',
      isMine: true,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    _Message(
      id: '3',
      text: 'Silakan, sebutkan kendalanya.',
      isMine: false,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isSending = true;
      _messages.add(
        _Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isMine: true,
          time: DateTime.now(),
        ),
      );
      _controller.clear();
    });
    _scrollToBottom();

    // Simulasi pengiriman ke server / balasan otomatis
    await Future<void>.delayed(const Duration(milliseconds: 400));
    setState(() {
      _isSending = false;
    });

    // Contoh balasan otomatis (hapus atau ganti dengan logika nyata)
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(
          _Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Terima kasih, kami akan cek dan segera merespon.',
            isMine: false,
            time: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessageBubble(_Message m) {
    final alignment = m.isMine
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bgColor = m.isMine ? Colors.blue.shade600 : Colors.grey.shade200;
    final textColor = m.isMine ? Colors.white : Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(m.isMine ? 12 : 0),
      bottomRight: Radius.circular(m.isMine ? 0 : 12),
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
                m.text,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(m.time),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
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
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return Align(
                    alignment: m.isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _buildMessageBubble(m),
                  );
                },
              ),
            ),

            // Input area
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
                      controller: _controller,
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
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
                          onPressed: _sendMessage,
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
  final String text;
  final bool isMine;
  final DateTime time;

  _Message({
    required this.id,
    required this.text,
    required this.isMine,
    required this.time,
  });
}
