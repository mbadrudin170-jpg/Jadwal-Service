import 'package:flutter/material.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';

class PackageNameWidget extends StatelessWidget {
  final Future<PaketModel?> paketFuture;
  final TextStyle? style;

  const PackageNameWidget({super.key, required this.paketFuture, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaketModel?>(
      future: paketFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        }
        if (snapshot.hasError) {
          Log.error(
            'Error di PackageNameWidget saat memuat paket',
            e: snapshot.error,
            s: snapshot.stackTrace,
          );
          return Text(
            'Error',
            style: style?.copyWith(
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          );
        }
        return Text(
          snapshot.data?.nama ?? 'Paket tidak tersedia',
          style: style,
        );
      },
    );
  }
}
