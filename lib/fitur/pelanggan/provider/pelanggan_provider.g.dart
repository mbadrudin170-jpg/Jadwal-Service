// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Pelanggan)
final pelangganProvider = PelangganProvider._();

final class PelangganProvider
    extends $AsyncNotifierProvider<Pelanggan, PelangganState> {
  PelangganProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganHash();

  @$internal
  @override
  Pelanggan create() => Pelanggan();
}

String _$pelangganHash() => r'c7988f66552b51ac7f3a57c654c1ae815e171adc';

abstract class _$Pelanggan extends $AsyncNotifier<PelangganState> {
  FutureOr<PelangganState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PelangganState>, PelangganState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PelangganState>, PelangganState>,
              AsyncValue<PelangganState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(IsSearchingPelanggan)
final isSearchingPelangganProvider = IsSearchingPelangganProvider._();

final class IsSearchingPelangganProvider
    extends $NotifierProvider<IsSearchingPelanggan, bool> {
  IsSearchingPelangganProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSearchingPelangganProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSearchingPelangganHash();

  @$internal
  @override
  IsSearchingPelanggan create() => IsSearchingPelanggan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSearchingPelangganHash() =>
    r'38724895cc23955136de503eb511810c7092933f';

abstract class _$IsSearchingPelanggan extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider generator modern untuk menyimpan text query pencarian pelanggan

@ProviderFor(SearchQueryPelanggan)
final searchQueryPelangganProvider = SearchQueryPelangganProvider._();

/// Provider generator modern untuk menyimpan text query pencarian pelanggan
final class SearchQueryPelangganProvider
    extends $NotifierProvider<SearchQueryPelanggan, String> {
  /// Provider generator modern untuk menyimpan text query pencarian pelanggan
  SearchQueryPelangganProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryPelangganProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryPelangganHash();

  @$internal
  @override
  SearchQueryPelanggan create() => SearchQueryPelanggan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryPelangganHash() =>
    r'd98c3e64b36f2e986e38ff15fa8338e4b99eb1d2';

/// Provider generator modern untuk menyimpan text query pencarian pelanggan

abstract class _$SearchQueryPelanggan extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(pelangganDetail)
final pelangganDetailProvider = PelangganDetailFamily._();

final class PelangganDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<(PelangganModel?, int)>,
          (PelangganModel?, int),
          FutureOr<(PelangganModel?, int)>
        >
    with
        $FutureModifier<(PelangganModel?, int)>,
        $FutureProvider<(PelangganModel?, int)> {
  PelangganDetailProvider._({
    required PelangganDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pelangganDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pelangganDetailHash();

  @override
  String toString() {
    return r'pelangganDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<(PelangganModel?, int)> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<(PelangganModel?, int)> create(Ref ref) {
    final argument = this.argument as String;
    return pelangganDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PelangganDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pelangganDetailHash() => r'f035ec5051457c1093e90687ba33b06fe986510c';

final class PelangganDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<(PelangganModel?, int)>, String> {
  PelangganDetailFamily._()
    : super(
        retry: null,
        name: r'pelangganDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PelangganDetailProvider call(String id) =>
      PelangganDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'pelangganDetailProvider';
}
