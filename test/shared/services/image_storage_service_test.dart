// path: test/shared/services/image_storage_service_test.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/shared/services/image_storage_service.dart';

import 'image_storage_service_test.mocks.dart';

@GenerateMocks([SupabaseClient, SupabaseStorageClient, StorageFileApi, File])
void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockStorageFileApi;
  late ImageStorageService imageStorageService;
  late MockFile mockFile;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockStorageClient = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();
    mockFile = MockFile();

    // 1. Definisikan perilaku stubbing TERLEBIH DAHULU
    when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
    when(mockStorageClient.from(any)).thenReturn(mockStorageFileApi);
    when(mockFile.path).thenReturn('test/image.png');

    // 2. Suntikkan mockSupabaseClient ke dalam konstruktor named parameter
    imageStorageService =
        ImageStorageService(supabaseClient: mockSupabaseClient);
  });

  group('ImageStorageService', () {
    const bucket = 'announcements';

    group('uploadImage', () {
      test('should upload file and return public URL on success', () async {
        // Arrange
        const uploadUrl =
            'https://example.com/storage/v1/object/public/announcements/test_image.png';
        when(mockStorageFileApi.upload(any, any,
                fileOptions: anyNamed('fileOptions')))
            .thenAnswer((_) async => uploadUrl);
        when(mockStorageFileApi.getPublicUrl(any)).thenReturn(uploadUrl);

        // Act
        final result = await imageStorageService.uploadImage(mockFile, bucket);

        // Assert
        expect(result, uploadUrl);
        verify(mockStorageFileApi.upload(any, mockFile)).called(1);
        verify(mockStorageFileApi.getPublicUrl(any)).called(1);
      });

      test('should throw an exception when upload fails', () {
        // Arrange
        when(mockStorageFileApi.upload(any, any,
                fileOptions: anyNamed('fileOptions')))
            .thenThrow(const StorageException('Upload failed'));

        // Act & Assert
        expect(() => imageStorageService.uploadImage(mockFile, bucket),
            throwsA(isA<StorageException>()));
      });
    });

    group('getImageUrl', () {
      test('should return the public URL for a given path', () {
        // Arrange
        const path = 'folder/image.png';
        const expectedUrl =
            'https://example.com/storage/v1/object/public/$bucket/$path';
        when(mockStorageFileApi.getPublicUrl(path)).thenReturn(expectedUrl);

        // Act
        final result = imageStorageService.getImageUrl(bucket, path);

        // Assert
        expect(result, expectedUrl);
        verify(mockStorageFileApi.getPublicUrl(path)).called(1);
      });
    });

    group('deleteFiles', () {
      test('should return true when files deletion is successful', () async {
        // Arrange
        final paths = ['path1.png', 'path2.png'];
        when(mockStorageFileApi.remove(any))
            .thenAnswer((_) async => <FileObject>[]);

        // Act
        final result = await imageStorageService.deleteFiles(bucket, paths);

        // Assert
        expect(result, isTrue);
        verify(mockStorageFileApi.remove(paths)).called(1);
      });

      test('should return false on exception during deletion', () async {
        // Arrange
        final paths = ['path1.png'];
        when(mockStorageFileApi.remove(any))
            .thenThrow(const StorageException('Deletion failed'));

        // Act
        final result = await imageStorageService.deleteFiles(bucket, paths);

        // Assert
        expect(result, isFalse);
      });
    });

    group('downloadImage', () {
      test('should return image bytes on success', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3]);
        when(mockStorageFileApi.download(any)).thenAnswer((_) async => bytes);

        // Act
        final result =
            await imageStorageService.downloadImage(bucket, 'image.png');

        // Assert
        expect(result, bytes);
        verify(mockStorageFileApi.download('image.png')).called(1);
      });

      test('should return null on failure', () async {
        // Arrange
        when(mockStorageFileApi.download(any))
            .thenThrow(const StorageException('Download failed'));

        // Act
        final result =
            await imageStorageService.downloadImage(bucket, 'image.png');

        // Assert
        expect(result, isNull);
      });
    });

    group('listFiles', () {
      test('should return list of FileObject on success', () async {
        // Arrange
        final fileList = [
          const FileObject(
              name: 'file1.png',
              bucketId: bucket,
              owner: '',
              id: '',
              updatedAt: null,
              createdAt: null,
              lastAccessedAt: null,
              metadata: null,
              buckets: null)
        ];
        when(mockStorageFileApi.list(path: anyNamed('path')))
            .thenAnswer((_) async => fileList);

        // Act
        final result =
            await imageStorageService.listFiles(bucket, folder: 'images');

        // Assert
        expect(result, fileList);
        verify(mockStorageFileApi.list(path: 'images')).called(1);
      });

      test('should return null on failure', () async {
        // Arrange
        when(mockStorageFileApi.list(path: anyNamed('path')))
            .thenThrow(const StorageException('List failed'));

        // Act
        final result = await imageStorageService.listFiles(bucket);

        // Assert
        expect(result, isNull);
      });
    });
  });
}
