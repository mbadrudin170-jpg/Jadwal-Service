// path: lib/fitur/speedtest/provider/ping_provider.dart
import 'package:dart_ping/dart_ping.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ping_provider.g.dart';

@riverpod
Future<PingData> ping(Ref ref) async {
  final ping = Ping('google.com', count: 5);
  return await ping.stream.first;
}
