import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';

class RingkasanSaham extends ConsumerWidget {
  const RingkasanSaham({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: investasiAsync.when(
        data: (data) {
        final totalLembar= data.getTotalLembarBeredar();
        final totalAset =data.amb

          return const SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      Row(children: [Text('data'), Text('data')]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: ((e, s) => Text('$e')),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
