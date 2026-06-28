// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Feedback)
final feedbackProvider = FeedbackProvider._();

final class FeedbackProvider
    extends $AsyncNotifierProvider<Feedback, FeedbackState> {
  FeedbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackHash();

  @$internal
  @override
  Feedback create() => Feedback();
}

String _$feedbackHash() => r'8a8db05af5ea13701877c969fc6a09b273dcb5f3';

abstract class _$Feedback extends $AsyncNotifier<FeedbackState> {
  FutureOr<FeedbackState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FeedbackState>, FeedbackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedbackState>, FeedbackState>,
              AsyncValue<FeedbackState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(daftarFeedbackAktif)
final daftarFeedbackAktifProvider = DaftarFeedbackAktifProvider._();

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
    r'58cbd840ace4249dbd8a4ebeb5a2f386f8eb79b5';

@ProviderFor(detailFeedback)
final detailFeedbackProvider = DetailFeedbackFamily._();

final class DetailFeedbackProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedbackModel?>,
          FeedbackModel?,
          FutureOr<FeedbackModel?>
        >
    with $FutureModifier<FeedbackModel?>, $FutureProvider<FeedbackModel?> {
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
  $FutureProviderElement<FeedbackModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedbackModel?> create(Ref ref) {
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

String _$detailFeedbackHash() => r'9fb746244ed3ac8f12d4eb63760ca334b9804d74';

final class DetailFeedbackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedbackModel?>, String> {
  DetailFeedbackFamily._()
    : super(
        retry: null,
        name: r'detailFeedbackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailFeedbackProvider call(String id) =>
      DetailFeedbackProvider._(argument: id, from: this);

  @override
  String toString() => r'detailFeedbackProvider';
}
