// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)

@ProviderFor(daftarFeedbackAktif)
final daftarFeedbackAktifProvider = DaftarFeedbackAktifProvider._();

/// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)

final class DaftarFeedbackAktifProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedbackModel>>,
          List<FeedbackModel>,
          FutureOr<List<FeedbackModel>>
        >
    with
        $FutureModifier<List<FeedbackModel>>,
        $FutureProvider<List<FeedbackModel>> {
  /// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)
  DaftarFeedbackAktifProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'daftarFeedbackAktifProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$daftarFeedbackAktifHash();

  @$internal
  @override
  $FutureProviderElement<List<FeedbackModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FeedbackModel>> create(Ref ref) {
    return daftarFeedbackAktif(ref);
  }
}

String _$daftarFeedbackAktifHash() =>
    r'22ac9e9b00e3b76e8febc021b4d1b9b0cf94731b';

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

@ProviderFor(detailFeedback)
final detailFeedbackProvider = DetailFeedbackFamily._();

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

final class DetailFeedbackProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedbackModel>,
          FeedbackModel,
          FutureOr<FeedbackModel>
        >
    with $FutureModifier<FeedbackModel>, $FutureProvider<FeedbackModel> {
  /// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
  /// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]
  DetailFeedbackProvider._({
    required DetailFeedbackFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailFeedbackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailFeedbackHash();

  @override
  String toString() {
    return r'detailFeedbackProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FeedbackModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedbackModel> create(Ref ref) {
    final argument = this.argument as String;
    return detailFeedback(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailFeedbackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailFeedbackHash() => r'7a2426b79ddfa428b35a52c199ce26ece0af068b';

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

final class DetailFeedbackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedbackModel>, String> {
  DetailFeedbackFamily._()
    : super(
        retry: null,
        name: r'detailFeedbackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
  /// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

  DetailFeedbackProvider call(String id) =>
      DetailFeedbackProvider._(argument: id, from: this);

  @override
  String toString() => r'detailFeedbackProvider';
}
