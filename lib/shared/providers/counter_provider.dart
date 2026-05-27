// path: lib/shared/providers/counter_provider.dart
import 'package:flutter_riverpod/legacy.dart';

// 1. Sebuah StateNotifier untuk mengelola state (angka) dan logika bisnis
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0); // State awal adalah 0

  // Fungsi untuk menambah angka
  void increment() {
    state++;
  }
}

// 2. Provider yang 'membungkus' CounterNotifier
final counterProvider =
    StateNotifierProvider<CounterNotifier, int>((final ref) {
  return CounterNotifier();
});
