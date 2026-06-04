// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)

@ProviderFor(activeFeedbackList)
final activeFeedbackListProvider = ActiveFeedbackListProvider._();

/// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)

final class ActiveFeedbackListProvider extends $FunctionalProvider<
        AsyncValue<List<FeedbackModel>>,
        List<FeedbackModel>,
        FutureOr<List<FeedbackModel>>>
    with
        $FutureModifier<List<FeedbackModel>>,
        $FutureProvider<List<FeedbackModel>> {
  /// Provider untuk menampung list data aktif di halaman utama (FeedbackPage)
  ActiveFeedbackListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeFeedbackListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeFeedbackListHash();

  @$internal
  @override
  $FutureProviderElement<List<FeedbackModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<FeedbackModel>> create(Ref ref) {
    return activeFeedbackList(ref);
  }
}

String _$activeFeedbackListHash() =>
    r'bc4cabfd3cd79b8750e8cf649d9a3b8fad48b03f';

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

@ProviderFor(feedbackDetail)
final feedbackDetailProvider = FeedbackDetailFamily._();

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

final class FeedbackDetailProvider extends $FunctionalProvider<
        AsyncValue<FeedbackModel>, FeedbackModel, FutureOr<FeedbackModel>>
    with $FutureModifier<FeedbackModel>, $FutureProvider<FeedbackModel> {
  /// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
  /// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]
  FeedbackDetailProvider._(
      {required FeedbackDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'feedbackDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedbackDetailHash();

  @override
  String toString() {
    return r'feedbackDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FeedbackModel> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FeedbackModel> create(Ref ref) {
    final argument = this.argument as String;
    return feedbackDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedbackDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedbackDetailHash() => r'8bfda65e841e693cdfd2bc06f7edc9568a59a876';

/// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
/// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

final class FeedbackDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedbackModel>, String> {
  FeedbackDetailFamily._()
      : super(
          retry: null,
          name: r'feedbackDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider untuk menampung data detail berdasarkan ID di halaman detail (FeedbackDetailPage)
  /// Menggunakan `.family` secara otomatis lewat pengenalan argumen [id]

  FeedbackDetailProvider call(
    String id,
  ) =>
      FeedbackDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'feedbackDetailProvider';
}
