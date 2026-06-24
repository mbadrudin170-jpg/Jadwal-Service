// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nama_pelanggan_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(namaPelangganSqlite)
final namaPelangganSqliteProvider = NamaPelangganSqliteFamily._();

final class NamaPelangganSqliteProvider
    extends
        $FunctionalProvider<
          AsyncValue<PelangganModel?>,
          PelangganModel?,
          FutureOr<PelangganModel?>
        >
    with $FutureModifier<PelangganModel?>, $FutureProvider<PelangganModel?> {
  NamaPelangganSqliteProvider._({
    required NamaPelangganSqliteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'namaPelangganSqliteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$namaPelangganSqliteHash();

  @override
  String toString() {
    return r'namaPelangganSqliteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PelangganModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PelangganModel?> create(Ref ref) {
    final argument = this.argument as String;
    return namaPelangganSqlite(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NamaPelangganSqliteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$namaPelangganSqliteHash() =>
    r'2f76f0007790a3a9698adc8976cc9092d0070607';

final class NamaPelangganSqliteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PelangganModel?>, String> {
  NamaPelangganSqliteFamily._()
    : super(
        retry: null,
        name: r'namaPelangganSqliteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NamaPelangganSqliteProvider call(String id) =>
      NamaPelangganSqliteProvider._(argument: id, from: this);

  @override
  String toString() => r'namaPelangganSqliteProvider';
}

@ProviderFor(namaPelangganFirebase)
final namaPelangganFirebaseProvider = NamaPelangganFirebaseFamily._();

final class NamaPelangganFirebaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<PelangganModel?>,
          PelangganModel?,
          Stream<PelangganModel?>
        >
    with $FutureModifier<PelangganModel?>, $StreamProvider<PelangganModel?> {
  NamaPelangganFirebaseProvider._({
    required NamaPelangganFirebaseFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'namaPelangganFirebaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$namaPelangganFirebaseHash();

  @override
  String toString() {
    return r'namaPelangganFirebaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PelangganModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PelangganModel?> create(Ref ref) {
    final argument = this.argument as String;
    return namaPelangganFirebase(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NamaPelangganFirebaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$namaPelangganFirebaseHash() =>
    r'736e7005a1ebfb7f8bdb051a1fc8d574cbb928d4';

final class NamaPelangganFirebaseFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PelangganModel?>, String> {
  NamaPelangganFirebaseFamily._()
    : super(
        retry: null,
        name: r'namaPelangganFirebaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NamaPelangganFirebaseProvider call(String id) =>
      NamaPelangganFirebaseProvider._(argument: id, from: this);

  @override
  String toString() => r'namaPelangganFirebaseProvider';
}
