// path: lib/fitur/event/page/event_page_u.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
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

  @override
  Widget build(final BuildContext context) {
    final EventModel data = widget.event;

    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: data.linkGambar,
          fit: BoxFit.cover,
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
