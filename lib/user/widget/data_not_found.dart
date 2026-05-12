import 'package:flutter/material.dart';

class DataNotFound extends StatelessWidget {
  final String message;
  const DataNotFound({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning,
            size: 60,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Whoops!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
