// path: test/image_mock_http_client.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mockito/mockito.dart' as mockito;

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

class MockImageHttpClient extends mockito.Mock implements HttpClient {
  MockImageHttpClient._();

  factory MockImageHttpClient() => MockImageHttpClient._();

  factory MockImageHttpClient.failing() {
    final client = MockImageHttpClient._();
    final request = MockHttpClientRequest();
    final response = MockHttpClientResponse();

    mockito
        .when(client.getUrl(mockito.any<Uri>()))
        .thenAnswer((_) async => request);
    mockito.when(request.close()).thenAnswer((_) async => response);
    mockito.when(response.statusCode).thenReturn(HttpStatus.notFound);
    mockito.when(response.reasonPhrase).thenReturn('Not Found');

    mockito
        .when(
          response.listen(
            mockito.any,
            onDone: mockito.anyNamed('onDone'),
            onError: mockito.anyNamed('onError'),
            cancelOnError: mockito.anyNamed('cancelOnError'),
          ),
        )
        .thenAnswer((invocation) {
          final onError = invocation.namedArguments[#onError] as Function;
          final onDone = invocation.namedArguments[#onDone] as void Function()?;

          final stream = Stream<List<int>>.error(
            Exception('Image load failed'),
            StackTrace.current,
          );
          final subscription = stream.listen(
            (_) {}, // onData tidak dipanggil karena error
            onError: onError,
            onDone: onDone,
          );
          return subscription;
        });
    return client;
  }
}

HttpClient createMockImageHttpClient(SecurityContext? _) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  mockito
      .when(client.getUrl(mockito.any<Uri>()))
      .thenAnswer((_) async => request);
  mockito.when(request.headers).thenReturn(headers);
  mockito.when(request.close()).thenAnswer((_) async => response);
  mockito.when(response.statusCode).thenReturn(HttpStatus.ok);
  mockito.when(response.contentLength).thenReturn(kTransparentImage.length);

  mockito
      .when(
        response.listen(
          mockito.any,
          onError: mockito.anyNamed('onError'),
          onDone: mockito.anyNamed('onDone'),
          cancelOnError: mockito.anyNamed('cancelOnError'),
        ),
      )
      .thenAnswer((invocation) {
        final onData =
            invocation.positionalArguments[0] as void Function(List<int>);
        final onDone = invocation.namedArguments[#onDone] as void Function()?;

        final stream = Stream<List<int>>.value(kTransparentImage);
        final subscription = stream.listen(
          onData,
          onError: invocation.namedArguments[#onError] as Function?,
          onDone: onDone,
        );
        return subscription;
      });
  return client;
}
