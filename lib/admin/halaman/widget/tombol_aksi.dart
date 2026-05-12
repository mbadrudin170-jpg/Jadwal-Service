import 'package:flutter/material.dart';

class TombolAksi extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const TombolAksi({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
