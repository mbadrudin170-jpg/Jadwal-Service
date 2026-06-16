// path: test/image_mock_http_client.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mockito/mockito.dart';

import 'admin/halaman/event/detail_event_a_test.mocks.dart';

// Transparent 1x1 pixel PNG image data
final kTransparentImage = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52, // ✅ diperbaiki dari 0x5R
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class MockImageHttpClient extends Mock implements HttpClient {
  MockImageHttpClient._();

  factory MockImageHttpClient() => MockImageHttpClient._();

  factory MockImageHttpClient.failing() {
    final client = MockImageHttpClient._();
    final request = MockHttpClientRequest();
    final response = MockHttpClientResponse();

    when(client.getUrl(any<Uri>())).thenAnswer((_) async => request);
    when(request.close()).thenAnswer((_) async => response);
    when(response.statusCode).thenReturn(HttpStatus.notFound);
    when(response.reasonPhrase).thenReturn('Not Found');
    when(
      response.listen(
        any,
        onDone: anyNamed('onDone'),
        onError: anyNamed('onError'),
        cancelOnError: anyNamed('cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      final onError = invocation.namedArguments[#onError] as Function;
      // Panggil onError dengan exception
      onError(Exception('Image load failed'), StackTrace.current);
      final onDone = invocation.namedArguments[#onDone] as Function?;
      onDone?.call();
      // Kembalikan stream kosong
      return Stream<List<int>>.empty();
    });
    return client;
  }
}

HttpClient createMockImageHttpClient(SecurityContext? _) {
  final client = MockImageHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  when(client.getUrl(any<Uri>())).thenAnswer((_) async => request);
  when(request.headers).thenReturn(headers);
  when(request.close()).thenAnswer((_) async => response);
  when(response.statusCode).thenReturn(HttpStatus.ok);
  when(response.contentLength).thenReturn(kTransparentImage.length);
  when(
    response.listen(
      any,
      onError: anyNamed('onError'),
      onDone: anyNamed('onDone'),
      cancelOnError: anyNamed('cancelOnError'),
    ),
  ).thenAnswer((invocation) {
    final onData =
        invocation.positionalArguments[0] as void Function(List<int>);
    final onDone = invocation.namedArguments[#onDone] as void Function()?;
    // Kirim data ke onData
    onData(kTransparentImage);
    // Panggil onDone jika ada
    onDone?.call();
    // Kembalikan Stream yang berisi data yang sama
    return Stream<List<int>>.value(kTransparentImage);
  });
  return client;
}
