// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tema_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Tema)
final temaProvider = TemaProvider._();

final class TemaProvider extends $AsyncNotifierProvider<Tema, ThemeMode> {
  TemaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'temaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$temaHash();

  @$internal
  @override
  Tema create() => Tema();
}

String _$temaHash() => r'9343a6134e542731d766b6abffea607e191ad3c7';

abstract class _$Tema extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
