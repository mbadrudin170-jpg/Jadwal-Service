// path: lib/admin/halaman/lainnya/detail_event_a.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';

class DetailEventA extends ConsumerWidget {
  const DetailEventA({super.key, required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.edit),
            onPressed: () {
              unawaited(Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (context) => const ManageAnnouncementPage()),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.p12),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                placeholder: (context, url) => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            gapH24,
            _buildInfoRow('ID Pengumuman', event.id),
            const Divider(),
            _buildInfoRow('Status', event.isActive ? 'Aktif' : 'Tidak Aktif',
                color: event.isActive ? Colors.green : Colors.red),
            const Divider(),
            _buildInfoRow('Mulai', event.startDate.toLocal().toString()),
            const Divider(),
            _buildInfoRow('Selesai', event.endDate.toLocal().toString()),
            const Divider(),
            _buildInfoRow('Dibuat pada', event.createdAt.toLocal().toString()),
            const Divider(),
            _buildInfoRow('Terakhir Diperbarui',
                event.updatedAt?.toLocal().toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          gapH4,
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
