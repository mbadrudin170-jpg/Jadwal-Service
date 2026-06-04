// path: test/shared/data/sync/initial_download_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

import 'initial_download_test.mocks.dart';

@GenerateMocks([DownloadDataService, SyncManager])
void main() {
  late InitialDataLoader initialDataLoader;
  late MockDownloadDataService mockDownloadDataService;
  late MockSyncManager mockSyncManager;

  setUp(() {
    mockDownloadDataService = MockDownloadDataService();
    mockSyncManager = MockSyncManager();
    initialDataLoader = InitialDataLoader(
      downloadDataService: mockDownloadDataService,
      syncManager: mockSyncManager,
    );
  });

  group('InitialDataLoader', () {
    test('isInitialDownloadRequired returns true when last download is epoch',
        () async {
      when(mockSyncManager.getLastDownload())
          .thenAnswer((_) async => DateTime(1970));

      final result = await initialDataLoader.isInitialDownloadRequired();

      expect(result, isTrue);
    });

    test(
        'isInitialDownloadRequired returns false when last download is not epoch',
        () async {
      when(mockSyncManager.getLastDownload())
          .thenAnswer((_) async => DateTime.now());

      final result = await initialDataLoader.isInitialDownloadRequired();

      expect(result, isFalse);
    });

    test('downloadDataAndSetTimestamp executes download and updates timestamp',
        () async {
      when(mockDownloadDataService.downloadAllData()).thenAnswer((_) async {});
      when(mockSyncManager.updateLastDownload()).thenAnswer((_) async {});

      await initialDataLoader.downloadDataAndSetTimestamp();

      verify(mockDownloadDataService.downloadAllData()).called(1);
      verify(mockSyncManager.updateLastDownload()).called(1);
    });

    test('downloadDataAndSetTimestamp throws exception if download fails',
        () async {
      final testException = Exception('Download failed');
      when(mockDownloadDataService.downloadAllData()).thenThrow(testException);

      expect(() => initialDataLoader.downloadDataAndSetTimestamp(),
          throwsA(isA<Exception>()));
      verifyNever(mockSyncManager.updateLastDownload());
    });
  });
}
