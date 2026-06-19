// path: lib/fitur/speedtest/provider/ping_provider.dart
import 'package:dart_ping/dart_ping.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ping_provider.g.dart';

@riverpod
Future<PingData> ping(Ref ref) async {
  final ping = Ping('google.com', count: 1);

  // Pastikan proses dihentikan jika provider di-dispose sebelum selesai
  ref.onDispose(() {
    // tidak perlu await di sini; stop() dipanggil untuk membersihkan proses
    ping.stop();
  });

  try {
    // Tunggu event terakhir (ringkasan) setelah proses selesai
    final PingData terakhir = await ping.stream.first;
    return terakhir;
  } finally {
    await ping.stop();
  }
}

@riverpod
Future<int> httpPing(Ref ref) async {
  final stopwatch = Stopwatch()..start();
  try {
    final response = await http
        .head(Uri.parse('https://www.google.com'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return stopwatch.elapsedMilliseconds;
    } else {
      throw Exception('HTTP status ${response.statusCode}');
    }
  } catch (e) {
    // Fallback ke host lain jika google.com gagal
    try {
      final response = await http
          .head(Uri.parse('https://www.cloudflare.com'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return stopwatch.elapsedMilliseconds;
      }
    } catch (_) {}
    rethrow; // Gagal semua host
  } finally {
    stopwatch.stop();
  }
}
