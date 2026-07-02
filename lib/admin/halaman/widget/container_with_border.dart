// path: lib/admin/halaman/widget/container_with_border.dart
import 'package:flutter/material.dart';

/// Sebuah widget container dengan border.
class ContainerWithBorder extends StatelessWidget {

  /// Membuat sebuah widget [ContainerWithBorder].
  const ContainerWithBorder({super.key, required this.child});
  /// Widget yang akan ditampilkan di dalam container.
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
