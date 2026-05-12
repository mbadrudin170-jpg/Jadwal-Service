import 'package:flutter/material.dart';

class ContainerWithBorder extends StatelessWidget {
  final Widget child;

  const ContainerWithBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
