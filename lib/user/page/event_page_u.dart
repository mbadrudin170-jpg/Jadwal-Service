// path: lib/user/page/event_page_u.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/theme/app_colors.dart';

class EventPageU extends ConsumerStatefulWidget {
  const EventPageU({super.key, required this.event});
  final EventModel event;

  @override
  ConsumerState<EventPageU> createState() => _EventPageUState();
}

class _EventPageUState extends ConsumerState<EventPageU> {
  Timer? _timer;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Hentikan timer sebelumnya jika ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<void> _handleTap(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final EventModel data = widget.event;

    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => _handleTap(data.imageUrl),
          child: CachedNetworkImage(
            imageUrl: data.imageUrl,
            fit: BoxFit.cover,
            // placeholder: (context, url) =>
            //     const Center(child: CircularProgressIndicator()),
            // errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        Positioned(
          top: 30,
          right: 10,
          child: ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              backgroundColor: TColors.darkBackground.withValues(alpha: 0.7),
            ),
            child: Text(
              _countdown > 0 ? '$_countdown' : 'X',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
