// path: prompt/aturan_belajar.md

### Aturan Belajar dan Bimbingan (AI)

**Tujuan:** Memastikan AI berperan sebagai mentor yang efektif untuk membantu saya (pengguna) memahami Flutter dan Dart secara mendalam, dari konsep dasar hingga praktik terbaik.

---

**1. Dasar Bimbingan**
- Karena saya dalam tahap belajar, tujuan utama AI adalah membantu saya memahami *mengapa* dan *bagaimana* suatu kode bekerja.
- Jika saya bingung, berikan penjelasan konsep yang relevan dengan bahasa yang mudah dipahami.

**2. Penanganan Error dan Kesalahan**
- Ketika terjadi error, warning, atau kesalahan logika:
  - Tunjukkan **hanya potongan kode yang salah**.
  - Jelaskan dengan detail **mengapa kode tersebut salah**.
  - Berikan **potongan kode perbaikan** dan jelaskan **mengapa versi perbaikan ini benar**.
- **Larangan:** Jangan menulis ulang seluruh file atau fungsi, agar saya bisa fokus pada bagian yang diperbaiki.

**3. Kode yang Mudah Dikelola**
- Bantu saya membuat kode yang terstruktur, mudah dibaca, dan mudah dikelola untuk masa depan.

**5. Saran Proaktif untuk Kualitas Kode**
- Meskipun kode saya berjalan tanpa error, AI wajib proaktif:
  - Jika ada cara penulisan yang lebih efisien, modern, atau sesuai *best practice* (misal: penggunaan `const`, ekstraksi widget, state management yang lebih baik), **tanyakan apakah saya ingin melihat versi yang lebih baik**.
  - Jelaskan keuntungan dari pendekatan yang disarankan.

**6. Penjelasan Konsep Fundamental**
- Jika kode yang saya tulis atau yang kita diskusikan menyentuh konsep penting (contoh: `Future`, `async/await`, `Stream`, `BuildContext`, `StatefulWidget vs StatelessWidget`, immutability), **ambil inisiatif untuk menjelaskannya secara singkat dan sederhana**, bahkan jika saya tidak bertanya. Anggap saya belum familiar dengan konsep tersebut.

**7. Kepatuhan Terhadap Aturan Proyek**
- Selalu ingatkan saya jika kode yang saya tulis melanggar aturan lain yang sudah didefinisikan di dalam direktori `prompt/`, seperti:
  - `aturan_penulisan_kode.md` (penamaan, format, dll.).
  - `aturan_analisis_error.md` (cara menganalisis masalah).
  - `penyisipan_log_sanckbar.md` (penggunaan `Log` dan `ToastUtil`).// Copyright 2019 Dart Mockito authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// An annotation to direct Mockito to generate mock classes.
///
/// During [code generation][NULL_SAFETY_README], Mockito will generate a
/// `Mock{Type} extends Mock` class for each class to be mocked, in
/// `{name}.mocks.dart`, where `{name}` is the basename of the file in which
/// `@GenerateMocks` is used.
///
/// For example, if `@GenerateMocks([Foo])` is found at the top-level of a Dart
/// library, `foo_test.dart`, then Mockito will generate
/// `class MockFoo extends Mock implements Foo` in a new library,
/// `foo_test.mocks.dart`.
///
/// If the class-to-mock is generic, then the mock will be identically generic.
/// For example, given the class `class Foo<T, U>`, Mockito will generate
/// `class MockFoo<T, U> extends Mock implements Foo<T, U>`.
///
/// Custom mocks can be generated with the `customMocks:` named argument. Each
/// mock is specified with a [MockSpec] object.
///
/// [NULL_SAFETY_README]: https://github.com/dart-lang/build/blob/master/builder_pkgs/mockito/NULL_SAFETY_README.md
class GenerateMocks {
  final List<Type> classes;
  final List<MockSpec> customMocks;

  const GenerateMocks(this.classes, {this.customMocks = const []});
}

/// An annotation to direct Mockito to generate mock classes.
///
/// During [code generation][NULL_SAFETY_README], Mockito will generate a
/// `Mock{Type} extends Mock` class for each class to be mocked, in
/// `{name}.mocks.dart`, where `{name}` is the basename of the file in which
/// `@GenerateNiceMocks` is used.
///
/// For example, if `@GenerateNiceMocks([MockSpec<Foo>()])` is found at
/// the top-level of a Dart library, `foo_test.dart`, then Mockito will
/// generate `class MockFoo extends Mock implements Foo` in a new library,
/// `foo_test.mocks.dart`.
///
/// If the class-to-mock is generic, then the mock will be identically generic.
/// For example, given the class `class Foo<T, U>`, Mockito will generate
/// `class MockFoo<T, U> extends Mock implements Foo<T, U>`.
///
/// `@GenerateNiceMocks` is different from `@GenerateMocks` in two ways:
///   - only `MockSpec`s are allowed in the argument list
///   - generated mocks won't throw on unstubbed method calls by default,
///     instead some value appropriate for the target type will be
///     returned.
///
/// [NULL_SAFETY_README]: https://github.com/dart-lang/build/blob/master/builder_pkgs/mockito/NULL_SAFETY_README.md
class GenerateNiceMocks {
  final List<MockSpec> mocks;
  const GenerateNiceMocks(this.mocks);
}

/// A specification of how to mock a specific class.
///
/// The type argument `T` is the class-to-mock. If this class is generic, and no
/// explicit type arguments are given, then the mock class is generic.
/// If the class is generic, and `T` has been specified with type argument(s),
/// the mock class is not generic, and it extends the mocked class using the
/// given type arguments.
///
/// The name of the mock class is either specified with the `as` named argument,
/// or is the name of the class being mocked, prefixed with 'Mock'.
///
/// For example, given the generic class, `class Foo<T>`, then this
/// annotation:
///
/// ```dart
/// @GenerateMocks([], customMocks: [
///     MockSpec<Foo>(),
///     MockSpec<Foo<int>>(as: #MockFooOfInt),
/// ])
/// ```
///
/// directs Mockito to generate two mocks:
/// `class MockFoo<T> extends Mocks implements Foo<T>` and
/// `class MockFooOfInt extends Mock implements Foo<int>`.
class MockSpec<T> {
  final Symbol? mockName;

  final List<Type> mixins;

  final OnMissingStub? onMissingStub;

  final Set<Symbol> unsupportedMembers;

  final Map<Symbol, Function> fallbackGenerators;

  /// Constructs a custom mock specification.
  ///
  /// Specify a custom name with the [as] parameter.
  ///
  /// If [onMissingStub] is specified as
  /// [OnMissingStub.returnDefault], a real call to a mock method (or
  /// getter) will return a legal value when no stub is found.
  ///
  /// If the class-to-mock has a member with a non-nullable unknown return type
  /// (such as a type variable, `T`), then mockito cannot generate a valid
  /// override member, unless the member is specified in [unsupportedMembers],
  /// or a fallback implementation is given in [fallbackGenerators].
  ///
  /// For each member M in [unsupportedMembers], the mock class will have an
  /// override that throws, which may be useful if the return type T of M is
  /// non-nullable and it's inconvenient to define a fallback generator for M,
  /// e.g. if T is an unknown type variable. Such an override cannot be used
  /// with the mockito stubbing and verification APIs, but makes the mock class
  /// a valid implementation of the class-to-mock.
  ///
  /// Each entry in [fallbackGenerators] specifies a mapping from a method name
  /// to a function, with the same signature as the method. This function is
  /// used to generate fallback values when a non-null value needs to be
  /// returned when stubbing or verifying. A fallback value is not ever exposed
  /// in stubbing or verifying; it is an object that mockito's internals can use
  /// as a legal return value.
  const MockSpec({
    Symbol? as,
    @Deprecated(
      'Avoid adding concrete implementation to mock classes. '
      'Use a manual implementation of the class without `Mock`',
    )
    List<Type> mixingIn = const [],
    this.unsupportedMembers = const {},
    this.fallbackGenerators = const {},
    this.onMissingStub,
  }) : mockName = as,
       mixins = mixingIn;
}

/// Values indicating the action to perform when a real call is made to a mock
/// method (or getter) when no stub is found.
enum OnMissingStub {
  /// An exception should be thrown.
  throwException,

  /// A legal default value should be returned.
  ///
  /// For basic known types, like `int` and `Future<String>`, a simple value is
  /// returned (like `0` and `Future.value('')`). For unknown user types, an
  /// instance of a fake implementation is returned.
  returnDefault,
}
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'banner.dart';
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

// Examples can assume:
// late BuildContext context;

/// Defines the visual properties of [MaterialBanner] widgets.
///
/// Descendant widgets obtain the current [MaterialBannerThemeData] object using
/// [MaterialBannerTheme.of]. Instances of [MaterialBannerThemeData]
/// can be customized with [MaterialBannerThemeData.copyWith].
///
/// Typically a [MaterialBannerThemeData] is specified as part of the overall
/// [Theme] with [ThemeData.bannerTheme].
///
/// All [MaterialBannerThemeData] properties are `null` by default. When null,
/// the [MaterialBanner] will provide its own defaults.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
@immutable
class MaterialBannerThemeData with Diagnosticable {
  /// Creates a theme that can be used for [MaterialBannerTheme] or
  /// [ThemeData.bannerTheme].
  const MaterialBannerThemeData({
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.dividerColor,
    this.contentTextStyle,
    this.elevation,
    this.padding,
    this.leadingPadding,
  });

  /// The background color of a [MaterialBanner].
  final Color? backgroundColor;

  /// Overrides the default value of [MaterialBanner.surfaceTintColor].
  final Color? surfaceTintColor;

  /// Overrides the default value of [MaterialBanner.shadowColor].
  final Color? shadowColor;

  /// Overrides the default value of [MaterialBanner.dividerColor].
  final Color? dividerColor;

  /// Used to configure the [DefaultTextStyle] for the [MaterialBanner.content]
  /// widget.
  final TextStyle? contentTextStyle;

  /// Default value for [MaterialBanner.elevation].
  //
  // If null, MaterialBanner uses a default of 0.0.
  final double? elevation;

  /// The amount of space by which to inset [MaterialBanner.content].
  final EdgeInsetsGeometry? padding;

  /// The amount of space by which to inset [MaterialBanner.leading].
  final EdgeInsetsGeometry? leadingPadding;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  MaterialBannerThemeData copyWith({
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? shadowColor,
    Color? dividerColor,
    TextStyle? contentTextStyle,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? leadingPadding,
  }) {
    return MaterialBannerThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      shadowColor: shadowColor ?? this.shadowColor,
      dividerColor: dividerColor ?? this.dividerColor,
      contentTextStyle: contentTextStyle ?? this.contentTextStyle,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      leadingPadding: leadingPadding ?? this.leadingPadding,
    );
  }

  /// Linearly interpolate between two Banner themes.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static MaterialBannerThemeData lerp(
    MaterialBannerThemeData? a,
    MaterialBannerThemeData? b,
    double t,
  ) {
    return MaterialBannerThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      dividerColor: Color.lerp(a?.dividerColor, b?.dividerColor, t),
      contentTextStyle: TextStyle.lerp(a?.contentTextStyle, b?.contentTextStyle, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      leadingPadding: EdgeInsetsGeometry.lerp(a?.leadingPadding, b?.leadingPadding, t),
    );
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    surfaceTintColor,
    shadowColor,
    dividerColor,
    contentTextStyle,
    elevation,
    padding,
    leadingPadding,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MaterialBannerThemeData &&
        other.backgroundColor == backgroundColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.shadowColor == shadowColor &&
        other.dividerColor == dividerColor &&
        other.contentTextStyle == contentTextStyle &&
        other.elevation == elevation &&
        other.padding == padding &&
        other.leadingPadding == leadingPadding;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor, defaultValue: null));
    properties.add(ColorProperty('surfaceTintColor', surfaceTintColor, defaultValue: null));
    properties.add(ColorProperty('shadowColor', shadowColor, defaultValue: null));
    properties.add(ColorProperty('dividerColor', dividerColor, defaultValue: null));
    properties.add(
      DiagnosticsProperty<TextStyle>('contentTextStyle', contentTextStyle, defaultValue: null),
    );
    properties.add(DoubleProperty('elevation', elevation, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding, defaultValue: null));
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('leadingPadding', leadingPadding, defaultValue: null),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [MaterialBanner]s in this widget's subtree.
///
/// Values specified here are used for [MaterialBanner] properties that are not
/// given an explicit non-null value.
class MaterialBannerTheme extends InheritedTheme {
  /// Creates a banner theme that controls the configurations for
  /// [MaterialBanner]s in its widget subtree.
  const MaterialBannerTheme({super.key, this.data, required super.child});

  /// The properties for descendant [MaterialBanner] widgets.
  final MaterialBannerThemeData? data;

  /// The closest instance of this class's [data] value that encloses the given
  /// context.
  ///
  /// If there is no ancestor, it returns [ThemeData.bannerTheme]. Applications
  /// can assume that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// MaterialBannerThemeData theme = MaterialBannerTheme.of(context);
  /// ```
  static MaterialBannerThemeData of(BuildContext context) {
    final MaterialBannerTheme? bannerTheme = context
        .dependOnInheritedWidgetOfExactType<MaterialBannerTheme>();
    return bannerTheme?.data ?? Theme.of(context).bannerTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MaterialBannerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(MaterialBannerTheme oldWidget) => data != oldWidget.data;
}
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Testing library for flutter, built on top of `package:test`.
///
/// ## Test Configuration
///
/// The testing library exposes a few constructs by which projects may configure
/// their tests.
///
/// ### Per test or per file
///
/// Due to its use of `package:test` as a foundation, the testing library
/// allows for tests to be initialized using the existing constructs found in
/// `package:test`. These include the [setUp] and [setUpAll] methods.
///
/// ### Per directory hierarchy
///
/// In addition to the constructs provided by `package:test`, this library
/// supports the configuration of tests at the directory level.
///
/// Before a test file is executed, the Flutter test framework will scan up the
/// directory hierarchy, starting from the directory in which the test file
/// resides, looking for a file named `flutter_test_config.dart`. If it finds
/// such a configuration file, the file will be assumed to have a `main` method
/// with the following signature:
///
/// ```dart
/// Future<void> testExecutable(FutureOr<void> Function() testMain) async { }
/// ```
///
/// The test framework will execute that method and pass it the `main()` method
/// of the test. It is then the responsibility of the configuration file's
/// `main()` method to invoke the test's `main()` method.
///
/// After the test framework finds a configuration file, it will stop scanning
/// the directory hierarchy. In other words, the test configuration file that
/// lives closest to the test file will be selected, and all other test
/// configuration files will be ignored. Likewise, it will stop scanning the
/// directory hierarchy when it finds a `pubspec.yaml`, since that signals the
/// root of the project.
///
/// If no configuration file is located, the test will be executed like normal.
///
/// See also:
///
///  * [WidgetController.hitTestWarningShouldBeFatal], which can be set
///    in a `flutter_test_config.dart` file to turn warnings printed by
///    [WidgetTester.tap] and similar APIs into fatal errors.
///  * [debugCheckIntrinsicSizes], which can be set in a
///    `flutter_test_config.dart` file to enable deeper [RenderBox]
///    tests of the intrinsic APIs automatically while laying out widgets.
///
/// @docImport 'package:flutter/rendering.dart';
///
/// @docImport 'src/controller.dart';
/// @docImport 'src/test_compat.dart';
/// @docImport 'src/widget_tester.dart';
library flutter_test;

export 'dart:async' show Future;

export 'src/_goldens_io.dart' if (dart.library.js_interop) 'src/_goldens_web.dart';
export 'src/_matchers_io.dart' if (dart.library.js_interop) 'src/_matchers_web.dart';
export 'src/_test_selector_io.dart' if (dart.library.js_interop) 'src/_test_selector_web.dart';
export 'src/accessibility.dart';
export 'src/animation_sheet.dart';
export 'src/binding.dart';
export 'src/controller.dart';
export 'src/deprecated.dart';
export 'src/event_simulation.dart';
export 'src/finders.dart';
export 'src/frame_timing_summarizer.dart';
export 'src/goldens.dart';
export 'src/image.dart';
export 'src/matchers.dart';
export 'src/mock_canvas.dart';
export 'src/mock_event_channel.dart';
export 'src/navigator.dart';
export 'src/nonconst.dart';
export 'src/platform.dart';
export 'src/recording_canvas.dart';
export 'src/restoration.dart';
export 'src/stack_manipulation.dart';
export 'src/test_async_utils.dart';
export 'src/test_compat.dart';
export 'src/test_default_binary_messenger.dart';
export 'src/test_exception_reporter.dart';
export 'src/test_pointer.dart';
export 'src/test_text_input.dart';
export 'src/test_vsync.dart';
export 'src/tree_traversal.dart';
export 'src/widget_tester.dart';
export 'src/window.dart';
import 'dart:async';

import 'package:sqflite/src/compat.dart';
import 'package:sqflite/src/constant.dart';
import 'package:sqflite/src/sqflite_android.dart';
import 'package:sqflite/src/sqflite_impl.dart';
import 'package:sqflite/src/utils.dart' as impl;
import 'package:sqflite/utils/utils.dart' as utils;

import 'sqlite_api.dart';

export 'package:sqflite/sql.dart' show ConflictAlgorithm;
export 'package:sqflite/src/compat.dart';
export 'package:sqflite_common/sqflite.dart';

export 'sqlite_api.dart';
export 'src/factory_impl.dart' show databaseFactorySqflitePlugin;
export 'src/sqflite_darwin.dart' show SqfliteDarwin;
export 'src/sqflite_plugin.dart' show SqflitePlugin;

///
/// sqflite plugin
///
class Sqflite {
  /// Turns on debug mode if you want to see the SQL query
  /// executed natively.
  @Deprecated('Removed in next major release')
  static Future<void> setDebugModeOn([bool on = true]) async {
    await invokeMethod<dynamic>(methodSetDebugModeOn, on);
  }

  /// Planned Deprecated for 1.1.7
  @Deprecated('Removed in next major release')
  static Future<bool> getDebugModeOn() async {
    return impl.debugModeOn;
  }

  /// deprecated on purpose to remove from code.
  ///
  /// To use during developpment/debugging
  /// Set extra dart and nativate debug logs
  @Deprecated('Dev only')
  static Future<void> devSetDebugModeOn([bool on = true]) {
    impl.debugModeOn = on;
    return setDebugModeOn(on);
  }

  /// Testing only.
  ///
  /// deprecated on purpose to remove from code.
  @Deprecated('Dev only')
  static Future<void> devSetOptions(SqfliteOptions options) async {
    await invokeMethod<dynamic>(methodOptions, options.toMap());
  }

  /// Testing only
  @Deprecated('Dev only')
  static Future<void> devInvokeMethod(
    String method, [
    Object? arguments,
  ]) async {
    await invokeMethod<dynamic>(method, arguments);
  }

  /// helper to get the first int value in a query
  /// Useful for COUNT(*) queries
  static int? firstIntValue(List<Map<String, Object?>> list) =>
      utils.firstIntValue(list);

  /// Utility to encode a blob to allow blob query using
  /// 'hex(blob_field) = ?', Sqlite.hex([1,2,3])
  static String hex(List<int> bytes) => utils.hex(bytes);

  /// Sqlite has a dead lock warning feature that will print some text
  /// after 10s, you can override the default behavior
  static void setLockWarningInfo({
    Duration? duration,
    void Function()? callback,
  }) {
    utils.setLockWarningInfo(duration: duration!, callback: callback!);
  }
}

/// Android only API
extension SqfliteDatabaseAndroidExt on Database {
  /// Sets the locale for this database. The specified IETF BCP 47 language tag
  /// string (en-US, zh-CN, fr-FR, zh-Hant-TW, ...) must be as defined in
  /// `Locale.forLanguageTag` in Android/Java documentation.
  ///
  /// Only on Android.
  Future<void> androidSetLocale(String languageTag) =>
      SqfliteDatabaseAndroidExtImpl(this).androidSetLocale(languageTag);
}
// Copyright 2016 Dart Mockito authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: combinators_ordering

// ignore: deprecated_member_use
export 'package:test_api/fake.dart' show Fake;

export 'src/dummies.dart'
    show provideDummy, provideDummyBuilder, MissingDummyValueError;
export 'src/mock.dart'
    show
        Mock,
        SmartFake,
        named, // ignore: deprecated_member_use_from_same_package
        // -- setting behaviour
        when,
        any,
        anyNamed,
        argThat,
        captureAny,
        captureAnyNamed,
        captureThat,
        Answering,
        Expectation,
        PostExpectation,
        // -- verification
        verify,
        verifyInOrder,
        verifyNever,
        verifyNoMoreInteractions,
        verifyZeroInteractions,
        VerificationResult,
        Verification,
        ListOfVerificationResult,
        // -- misc
        throwOnMissingStub,
        clearInteractions,
        reset,
        resetMockitoState,
        logInvocations,
        untilCalled,
        MissingStubError,
        FakeUsedError,
        FakeFunctionUsedError;
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Flutter widgets implementing Material Design.
///
/// To use, import `package:flutter/material.dart`.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=DL0Ix1lnC4w}
///
/// See also:
///
///  * [docs.flutter.dev/ui/widgets/material](https://docs.flutter.dev/ui/widgets/material)
///    for a catalog of commonly-used Material component widgets.
///  * [m3.material.io](https://m3.material.io/) for the Material 3 specification
///  * [m2.material.io](https://m2.material.io/) for the Material 2 specification
library material;

export 'src/material/about.dart';
export 'src/material/action_buttons.dart';
export 'src/material/action_chip.dart';
export 'src/material/action_icons_theme.dart';
export 'src/material/adaptive_text_selection_toolbar.dart';
export 'src/material/animated_icons.dart';
export 'src/material/app.dart';
export 'src/material/app_bar.dart';
export 'src/material/app_bar_theme.dart';
export 'src/material/arc.dart';
export 'src/material/autocomplete.dart';
export 'src/material/badge.dart';
export 'src/material/badge_theme.dart';
export 'src/material/banner.dart';
export 'src/material/banner_theme.dart';
export 'src/material/bottom_app_bar.dart';
export 'src/material/bottom_app_bar_theme.dart';
export 'src/material/bottom_navigation_bar.dart';
export 'src/material/bottom_navigation_bar_theme.dart';
export 'src/material/bottom_sheet.dart';
export 'src/material/bottom_sheet_theme.dart';
export 'src/material/button.dart';
export 'src/material/button_bar.dart';
export 'src/material/button_bar_theme.dart';
export 'src/material/button_style.dart';
export 'src/material/button_style_button.dart';
export 'src/material/button_theme.dart';
export 'src/material/calendar_date_picker.dart';
export 'src/material/card.dart';
export 'src/material/card_theme.dart';
export 'src/material/carousel.dart';
export 'src/material/carousel_theme.dart';
export 'src/material/checkbox.dart';
export 'src/material/checkbox_list_tile.dart';
export 'src/material/checkbox_theme.dart';
export 'src/material/chip.dart';
export 'src/material/chip_theme.dart';
export 'src/material/choice_chip.dart';
export 'src/material/circle_avatar.dart';
export 'src/material/color_scheme.dart';
export 'src/material/colors.dart';
export 'src/material/constants.dart';
export 'src/material/curves.dart';
export 'src/material/data_table.dart';
export 'src/material/data_table_source.dart';
export 'src/material/data_table_theme.dart';
export 'src/material/date.dart';
export 'src/material/date_picker.dart';
export 'src/material/date_picker_theme.dart';
export 'src/material/debug.dart';
export 'src/material/desktop_text_selection.dart';
export 'src/material/desktop_text_selection_toolbar.dart';
export 'src/material/desktop_text_selection_toolbar_button.dart';
export 'src/material/dialog.dart';
export 'src/material/dialog_theme.dart';
export 'src/material/divider.dart';
export 'src/material/divider_theme.dart';
export 'src/material/drawer.dart';
export 'src/material/drawer_header.dart';
export 'src/material/drawer_theme.dart';
export 'src/material/dropdown.dart';
export 'src/material/dropdown_menu.dart';
export 'src/material/dropdown_menu_form_field.dart';
export 'src/material/dropdown_menu_theme.dart';
export 'src/material/elevated_button.dart';
export 'src/material/elevated_button_theme.dart';
export 'src/material/elevation_overlay.dart';
export 'src/material/expand_icon.dart';
export 'src/material/expansion_panel.dart';
export 'src/material/expansion_tile.dart';
export 'src/material/expansion_tile_theme.dart';
export 'src/material/filled_button.dart';
export 'src/material/filled_button_theme.dart';
export 'src/material/filter_chip.dart';
export 'src/material/flexible_space_bar.dart';
export 'src/material/floating_action_button.dart';
export 'src/material/floating_action_button_location.dart';
export 'src/material/floating_action_button_theme.dart';
export 'src/material/grid_tile.dart';
export 'src/material/grid_tile_bar.dart';
export 'src/material/icon_button.dart';
export 'src/material/icon_button_theme.dart';
export 'src/material/icons.dart';
export 'src/material/ink_decoration.dart';
export 'src/material/ink_highlight.dart';
export 'src/material/ink_ripple.dart';
export 'src/material/ink_sparkle.dart';
export 'src/material/ink_splash.dart';
export 'src/material/ink_well.dart';
export 'src/material/input_border.dart';
export 'src/material/input_chip.dart';
export 'src/material/input_date_picker_form_field.dart';
export 'src/material/input_decorator.dart';
export 'src/material/list_tile.dart';
export 'src/material/list_tile_theme.dart';
export 'src/material/magnifier.dart';
export 'src/material/material.dart';
export 'src/material/material_button.dart';
export 'src/material/material_localizations.dart';
export 'src/material/material_state.dart';
export 'src/material/material_state_mixin.dart';
export 'src/material/menu_anchor.dart';
export 'src/material/menu_bar_theme.dart';
export 'src/material/menu_button_theme.dart';
export 'src/material/menu_style.dart';
export 'src/material/menu_theme.dart';
export 'src/material/mergeable_material.dart';
export 'src/material/motion.dart';
export 'src/material/navigation_bar.dart';
export 'src/material/navigation_bar_theme.dart';
export 'src/material/navigation_drawer.dart';
export 'src/material/navigation_drawer_theme.dart';
export 'src/material/navigation_rail.dart';
export 'src/material/navigation_rail_theme.dart';
export 'src/material/no_splash.dart';
export 'src/material/outlined_button.dart';
export 'src/material/outlined_button_theme.dart';
export 'src/material/page.dart';
export 'src/material/page_transitions_theme.dart';
export 'src/material/paginated_data_table.dart';
export 'src/material/popup_menu.dart';
export 'src/material/popup_menu_theme.dart';
export 'src/material/predictive_back_page_transitions_builder.dart';
export 'src/material/progress_indicator.dart';
export 'src/material/progress_indicator_theme.dart';
export 'src/material/radio.dart';
export 'src/material/radio_list_tile.dart';
export 'src/material/radio_theme.dart';
export 'src/material/range_slider.dart';
export 'src/material/range_slider_parts.dart';
export 'src/material/refresh_indicator.dart';
export 'src/material/reorderable_list.dart';
export 'src/material/scaffold.dart';
export 'src/material/scrollbar.dart';
export 'src/material/scrollbar_theme.dart';
export 'src/material/search.dart';
export 'src/material/search_anchor.dart';
export 'src/material/search_bar_theme.dart';
export 'src/material/search_view_theme.dart';
export 'src/material/segmented_button.dart';
export 'src/material/segmented_button_theme.dart';
export 'src/material/selectable_text.dart';
export 'src/material/selection_area.dart';
export 'src/material/shadows.dart';
export 'src/material/slider.dart';
export 'src/material/slider_parts.dart';
export 'src/material/slider_theme.dart';
export 'src/material/slider_value_indicator_shape.dart';
export 'src/material/snack_bar.dart';
export 'src/material/snack_bar_theme.dart';
export 'src/material/spell_check_suggestions_toolbar.dart';
export 'src/material/spell_check_suggestions_toolbar_layout_delegate.dart';
export 'src/material/stepper.dart';
export 'src/material/switch.dart';
export 'src/material/switch_list_tile.dart';
export 'src/material/switch_theme.dart';
export 'src/material/tab_bar_theme.dart';
export 'src/material/tab_controller.dart';
export 'src/material/tab_indicator.dart';
export 'src/material/tabs.dart';
export 'src/material/text_button.dart';
export 'src/material/text_button_theme.dart';
export 'src/material/text_field.dart';
export 'src/material/text_form_field.dart';
export 'src/material/text_selection.dart';
export 'src/material/text_selection_theme.dart';
export 'src/material/text_selection_toolbar.dart';
export 'src/material/text_selection_toolbar_text_button.dart';
export 'src/material/text_theme.dart';
export 'src/material/theme.dart';
export 'src/material/theme_data.dart';
export 'src/material/time.dart';
export 'src/material/time_picker.dart';
export 'src/material/time_picker_theme.dart';
export 'src/material/toggle_buttons.dart';
export 'src/material/toggle_buttons_theme.dart';
export 'src/material/tooltip.dart';
export 'src/material/tooltip_theme.dart';
export 'src/material/tooltip_visibility.dart';
export 'src/material/typography.dart';
export 'src/material/user_accounts_drawer_header.dart';
export 'widgets.dart';
# // path: prompt/aturan_analisis_error.md


---

### Aturan Analisis Error dan Masalah (AI)

**Tujuan:** Memastikan setiap kali terjadi error atau masalah pada suatu file, AI melakukan pemeriksaan menyeluruh terhadap file tersebut beserta semua dependensi impornya berdasarkan struktur proyek nyata, tanpa spekulasi, dan memeriksa dampak ke file lain.

---

**1. Identifikasi File Bermasalah dan Pemetaan Proyek**
- Tentukan file yang sedang mengalami error atau yang akan diubah/diperbaiki.
- Catat pesan error, stack trace, atau deskripsi masalah yang muncul.
- **Wajib menjalankan `ls -R lib/`** (atau perintah setara) untuk mendapatkan daftar lengkap file dan struktur direktori di dalam folder `lib/`.
- Dari hasil `ls -R lib/`, kenali semua file yang mungkin terkait, termasuk:
  - File yang diimpor langsung oleh file bermasalah.
  - File lain yang berpotensi menjadi sumber masalah berdasarkan nama, lokasi, atau pola.
- Gunakan peta struktur ini sebagai dasar untuk semua langkah penelusuran selanjutnya.

**2. Telusuri dan Baca Seluruh File yang Diimpor (Larangan Spekulasi)**
- Baca daftar impor di bagian atas file yang sedang dikerjakan.
- Untuk setiap impor yang **berasal dari dalam proyek** (bukan package eksternal), **wajib membuka dan membaca isi file tersebut**.
- Fokus pada definisi yang benar-benar digunakan: kelas, fungsi, variabel, enum, ekstensi, dll.
- **Dilarang berspekulasi** atau mengasumsikan isi file impor tanpa membacanya. Setiap referensi ke file impor harus didasarkan pada kode nyata yang sudah dibaca.
- Pastikan tanda tangan (signature), tipe data, parameter, dan struktur yang digunakan di file asli cocok dengan definisi di file impor.
- Jika file impor juga memiliki impor lokal lain yang relevan dengan masalah, AI **harus menelusuri lebih dalam** (dependensi tingkat kedua).

   **Cara Menemukan File dari Path Impor:**
   - **Untuk impor `package:`**: buang bagian `package:nama_app/`, lalu cocokkan dengan struktur di hasil `ls -R lib/`.
   - **Untuk impor relatif**: mulai dari direktori file yang sedang dikerjakan, telusuri path `../` berdasarkan hasil `ls -R lib/`.
   - **Jika file tidak ditemukan**, **wajib jalankan `ls -R lib/`** (atau `find lib/ -type f -name "*.dart"`) untuk mendapatkan struktur terbaru dan cari ulang. Jangan pernah berspekulasi lokasi file.

**3. Analisis Sumber Error Secara Runtut**
Setelah menelusuri file impor, lakukan langkah berikut untuk menentukan sumber error:

- **a. Periksa kesesuaian panggilan:**  
  Bandingkan cara pemanggilan fungsi/metode/widget di file utama dengan definisi aslinya di file impor. Cek: nama, parameter, tipe data, named/positional, required/optional, dan return type.

- **b. Periksa asumsi yang meleset:**  
  Jika di file utama ada asumsi tertentu (misal: suatu fungsi dianggap synchronous padahal async, atau dianggap melempar exception tertentu), cocokkan dengan fakta di file impor.

- **c. Periksa apakah ada perubahan di file impor:**  
  Lihat isi file impor, apakah ada perubahan yang baru saja terjadi? (misal: method dihapus, diganti nama, ditambah parameter, atau dijadikan private).

- **d. Cek apakah error menjalar dari file lain:**  
  Jika file impor yang dicek ternyata juga mengimpor file lokal lain, dan masalah belum ditemukan, **telusuri lebih dalam** ke file tersebut (ulangi poin 2).

- **e. Tentukan lokasi perbaikan:**  
  Setelah semua penelusuran, simpulkan di mana perbaikan harus dilakukan:
  - Di file utama (karena pemanggilan salah).
  - Di file impor (karena definisi yang kurang atau salah).
  - Di kedua file (jika ada ketidakcocokan desain).

- **f. Jangan berspekulasi:**  
  Jika ada bagian yang belum jelas atau file tidak bisa dibaca, **akui dan tanyakan ke pengguna**, jangan menebak.

**4. Periksa Dampak ke File Lain yang Menggunakan Class Ini (Reverse Dependency)**
- Setelah file selesai dianalisis atau akan diperbaiki, **wajib mencari file lain yang menggunakan class dari file tersebut**.
- Gunakan perintah:  
  `grep -r "NamaClass" lib/ --include="*.dart"`  
  di mana `NamaClass` adalah nama class utama (atau class yang diubah) dalam file yang sedang dikerjakan.
- Buka file-file yang ditemukan dan periksa apakah perubahan yang akan dilakukan (misal: mengubah signature method, menghapus method, mengganti tipe properti) akan merusak kompatibilitas di file-file tersebut.
- Jika ya, sertakan penyesuaian yang diperlukan di file-file itu, atau beri tahu pengguna tentang dampaknya.
- Jangan hanya fokus pada perbaikan di file yang dikerjakan, pastikan tidak merusak file lain yang menggunakan class tersebut.

---// path: prompt/build.md
# Aturan untuk melakukan build apk dengan Alias

## Alur Kerja Build (WAJIB DIIKUTI)

**1. SEBELUM Build: Cek Versi Terakhir**

Sebelum menjalankan build, **selalu periksa riwayat versi terakhir** di file log untuk menentukan `[nama-versi]` dan `[nomor-build]` yang akan digunakan.

-   **Lihat riwayat Admin:** `docs/build/build_apk_admin.md`
-   **Lihat riwayat User:** `docs/build/build_apk_user.md`

**2. SAAT Build: Jalankan Perintah Alias**

Gunakan alias yang sesuai dengan `nama-versi` dan `nomor-build` yang sudah Anda tentukan di langkah 1.

**3. SETELAH Build Berhasil: Catat Versi Baru**

Setelah proses build selesai **tanpa error**, segera **WAJIB catat versi baru** ke dalam file log yang sesuai.

1.  Buka file log yang relevan (misal, `docs/build/build_apk_admin.md`).
2.  **Tambahkan entri baru** di baris paling atas dengan format berikut:

    ```
    # [Tanggal dan Jam Build]
    version: [nama-versi]+[nomor-build]
    ```

    **Contoh Entri Baru:**
    ```
    # 19 Mei 24, 10:30
    version: 1.0.1+3
    ```

Tindakan ini **krusial** untuk menjaga riwayat build tetap akurat dan menghindari konflik versi.

---

## Detail Perintah Build

### Build Apk Admin Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbapkver_admin [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.1+2, maka build selanjutnya adalah 1.0.2+3
    flutter clean && flutter build apk --split-per-abi --flavor adminProd -t lib/main/main_admin/admin_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2"
```

### Build Apk User Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbapkver_user [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.0+1, maka build selanjutnya adalah 1.0.1+2
 flutter clean && flutter build apk --split-per-abi --flavor userProd -t lib/main/main_user/user_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2"
```

---

## Lokasi Output

File APK yang dihasilkan akan berada di direktori: `build/app/outputs/flutter-apk/`.
# // path: prompt/penyisipan_log_sanckbar.md
---

**Aturan Logging dan Toast untuk Asisten Koding Flutter:**

0. **Prasyarat: Pahami Implementasi**
   - Sebelum menyisipkan kode apa pun, **baca dan pahami** isi file berikut:
     - `lib/shared/debug/log.dart` (kelas `Log`)
     - `lib/shared/utils/toast_util.dart` (kelas `ToastUtil`)
   - Gunakan hanya method dan tanda tangan yang tersedia di kedua kelas tersebut.
   - Jangan membuat asumsi tentang fitur yang tidak ada; ikuti persis API yang disediakan.

1. **Logging**
   - Jangan pernah menggunakan `print()`, `debugPrint()`, atau `log()` bawaan.
   - Gunakan class `Log` dari path `lib/shared/debug/log.dart`.
   - Class `Log` punya method:
     - `Log.info(pesan, data?)` untuk informasi
     - `Log.warning(pesan, data?)` untuk peringatan
     - `Log.error(pesan, {e, st, data})` untuk error (bisa menyertakan exception & stacktrace)
   - Selalu sertakan pesan yang jelas, dan jika ada data relevan (response API, objek state, dll) masukkan sebagai parameter `data`.

2. **Toast**
   - Jangan pernah langsung pakai `ScaffoldMessenger.of(context).showSnackBar(...)` atau widget `SnackBar`.
   - Gunakan class `ToastUtil` dari path `lib/shared/utils/toast_util.dart`.
   - `ToastUtil` punya method statis:
     - `ToastUtil.success(context, pesan, {logData})`
     - `ToastUtil.error(context, pesan, {logData})`
     - `ToastUtil.warning(context, pesan, {logData})`
     - `ToastUtil.info(context, pesan, {logData})`
   - `logData` bersifat opsional, hanya untuk log internal (tidak tampil ke user), tapi tetap cantumkan jika ada data tambahan.
   - Method-method ini otomatis mencatat log sesuai tipe, jadi setelah memanggil `ToastUtil` **tidak perlu** lagi memanggil `Log` secara manual, **kecuali** untuk error (lihat poin 3).

3. **Penanganan Error (WAJIB)**
   - Setiap kali terjadi error, **harus** melakukan dua hal:
     a. **Log error** menggunakan `Log.error(...)` agar tercatat detail exception, stacktrace, dan data.
     b. **Tampilkan Toast error** menggunakan `ToastUtil.error(context, pesanUser, ...)` agar pengguna mendapat notifikasi.
   - **Jangan hanya** memanggil `Log.error` tanpa Toast, atau sebaliknya. Keduanya wajib ada.
   - **Aturan linter**: Gunakan `on` untuk menangkap tipe exception spesifik. Jangan gunakan `catch` polos tanpa `on`. Minimal `on Exception catch (e, st)` atau lebih spesifik. Jika tidak yakin, gunakan `on Object catch (e, st)`.
   - Toast untuk error harus menampilkan pesan yang ramah pengguna, sementara `Log.error` bisa berisi detail teknis.

4. **Pencatatan di Setiap Alur Kerja (WAJIB)**
   - Setiap fungsi atau metode yang melakukan aksi signifikan (misal: fetch data, submit form, proses perhitungan, navigasi dengan data) **harus**:
     a. Mencatat log di awal proses (contoh: `Log.info('Memulai mengambil data pengguna')`).
     b. Setelah selesai, memberikan notifikasi ke pengguna menggunakan `ToastUtil` (contoh: `ToastUtil.success(context, 'Data berhasil diambil')`).
   - Untuk operasi yang hanya memberi informasi tanpa efek besar, cukup gunakan `ToastUtil.info()` (sudah termasuk log).
   - Untuk operasi yang menghasilkan peringatan (misal data kosong), gunakan `ToastUtil.warning()`.
   - **Jangan sampai** ada aksi penting yang tidak meninggalkan jejak log atau tidak memberi tahu pengguna melalui Toast.

5. **Impor**
   - Setiap file yang membutuhkan log atau toast wajib mengimpor:
     ```dart
     import 'package:wifi/shared/debug/log.dart';
     import 'package:wifi/shared/utils/toast_util.dart';
     ```

6. **Hanya Menyisipkan Log dan Toast (Jangan Mengubah Kode Asli)**
   - Fokus hanya menambahkan pemanggilan `Log` dan `ToastUtil` sesuai aturan di atas.
   - **Jangan mengubah** struktur, logika, alur navigasi, nama fungsi/variabel, atau perilaku kode yang sudah ada.
   - Jika operasi penting belum memiliki penanganan error, tambahkan **blok `try`/`on Exception catch` minimal** untuk mencatat log dan menampilkan toast error, tetapi **biarkan isi blok `try` sama persis** dengan kode asli (tidak diubah).
   - Jangan menambahkan fungsionalitas baru, refaktor, atau "perbaikan" yang tidak diminta.

---
# Flutter Style Guide

This style guide outlines the coding conventions for contributions to the
flutter/flutter repository. It is based on the more comprehensive official
[style guide for the Flutter repository](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md).

## Best Practices

- Code should follow the guidance and principles described in
  [the Flutter contribution guide](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md).
- Code should be tested and follow the guidance described in the [writing effective tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md) and the [running and writing tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md).
- Changes to the [engine/ directory](https://github.com/flutter/flutter/tree/main/engine) should additionally have appropriate tests as described in [the engine test guidance](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md).
- PR descriptions should include the Pre-launch Checklist from
  [the PR template](https://github.com/flutter/flutter/blob/main/.github/PULL_REQUEST_TEMPLATE.md),
  with all of the steps completed.
- The most relevant guidelines should take precedence over less relevant
  guidelines. For Flutter code, the
  [Flutter styleguide](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
  should be followed as the first priority, and
  [Effective Dart: Style](https://dart.dev/effective-dart/style)
  should only be followed when it does not conflict with the former.


## Review Agent Guidelines

- Only review changes to the `master` branch. Other changes have already been reviewed (and are being cherrypicked).
- **Check for potential regressions**: Look for changes that might break existing functionality or introduce unexpected behavior in related areas.
- **Verify test validity**: Confirm that new or modified tests effectively catch the issue being fixed and would fail if the fix were reverted.
- **Search for counter-examples**: Identify scenarios or edge cases that the proposed code does not handle. If a counter-example is found, propose a test case to demonstrate the gap.
- **Suggest simplification and refactoring**: Assess whether the code can be made simpler or refactored to enhance readability and maintainability.

## General Philosophy

- **Optimize for readability**: Code is read more often than it is written.
- **Avoid duplicating state**: Keep only one source of truth.
- Write what you need and no more, but when you write it, do it right.
- **Error messages should be useful**: Every error message is an opportunity to make someone love our product.

## Dart Formatting

- All Dart code is formatted using `dart format`. This is enforced by CI.
- Constructors come first in a class definition, with the default constructor preceding named constructors.
- Other class members should be ordered logically (e.g., by lifecycle, or grouping related fields and methods).

## Miscellaneous Languages

- Python code is formatted using `yapf`, linted with `pylint`, and should follow the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html).
- C++ code is formatted using `clang-format`, linted with `clang-tidy`, and should follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).
- Shaders are formatted using `clang-format`.
- Kotlin code is formatted using `ktformat`, linted with `ktlint`, and should follow the [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide).
- Java code is formatted using `google-java-format` and should follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html).
- Objective-C is formatted using `clang-format`, linted with `clang-tidy`, and should follow the [Google Objective-C Style Guide](https://google.github.io/styleguide/objcguide.html).
- Swift is formatted and linted using `swift-format` and should follow the [Google Swift Style Guide](https://google.github.io/swift).
- GN code is formatted using `gn format` and should follow the [GN Style Guide](https://gn.googlesource.com/gn/+/main/docs/style_guide.md).

## Documentation

- All public members should have documentation.
- **Answer your own questions**: If you have a question, find the answer, and then document it where you first looked.
- **Documentation should be useful**: Explain the *why* and the *how*.
- **Introduce terms**: Assume the reader does not know everything. Link to definitions.
- **Provide sample code**: Use `{@tool dartpad}` for runnable examples.
  - Inline code samples are contained within `{@tool dartpad}` and `{@end-tool}`, and use the format of the following example to insert the code sample:
    - `/// ** See code in examples/api/lib/widgets/sliver/sliver_list.0.dart **`
    - Do not confuse this format with `/// See also:` sections of the documentation, which provide helpful breadcrumbs to developers.
- **Provide illustrations or screenshots** for widgets.
- Use `///` for public-quality documentation, even on private members.

## Review Agent Guidelines

When providing a summary, the review agent must adhere to the following principles:
- **Be Objective:** Focus on a neutral, descriptive summary of the changes. Avoid subjective value judgments
  like "good," "bad," "positive," or "negative." The goal is to report what the code does, not to evaluate it.
- **Use Code as the Source of Truth:** Base all summaries on the code diff. Do not trust or rephrase the PR
  description, which may be outdated or inaccurate. A summary must reflect the actual changes in the code.
- **Be Concise:** Generate summaries that are brief and to the point. Focus on the most significant changes,
  and avoid unnecessary details or verbose explanations. This ensures the feedback is easy to scan and understand.

## Further Reading

For more detailed guidance, refer to the following documents:

- [Style guide for the Flutter repository](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Tree Hygiene](https://github.com/flutter/flutter/blob/main/docs/contributing/Tree-hygiene.md)
- [The Flutter contribution guide](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md)
- [Writing effective tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md)
- [Running and writing tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md)
- [Engine testing guide](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md)# // path: prompt/aturan_penulisan_kode.md


---

### Aturan Ngoding Flutter (AI)

**0. Bahasa Percakapan dengan AI**
Seluruh percakapan antara AI dan pengembang **wajib menggunakan Bahasa Indonesia**, baik saat menjelaskan kode, memberi saran, maupun menanggapi pertanyaan. Aturan ini berlaku mutlak dalam sesi ini.

**1. Bahasa Komentar dan Percakapan**  
Seluruh komentar di dalam kode serta percakapan dengan AI wajib menggunakan **Bahasa Indonesia**.

**2. Penamaan dalam Kode**  
Seluruh nama **fungsi, variabel, props, parameter, file, dan class** wajib ditulis dalam **Bahasa Inggris**.  
Jika belum mengetahui padanan kata yang tepat:
- Tulis perkiraan nama dalam Bahasa Indonesia di komentar.
- Tanyakan langsung ke AI untuk mendapatkan padanan Bahasa Inggris yang lazim di Flutter/Dart.

**3. Pembiasaan Bahasa Inggris Bertahap**  
Penulisan nama tetap dimulai dengan Bahasa Inggris terlebih dahulu. Proses tanya-jawab ini bertujuan mempercepat migrasi ke Bahasa Inggris penuh tanpa menghambat alur ngoding, sambil tetap belajar secara bertahap.

**4. Format dan Kerapihan Kode**  
- Wajib menggunakan *trailing comma* di setiap widget tree agar auto-format rapi (sesuai `dart format`).  
- Gunakan `const` constructor sebanyak mungkin untuk widget stateless.  
- Pisahkan widget besar menjadi widget-widget kecil yang fokus pada satu tanggung jawab.  
- Jika widget tree sudah menjorok terlalu dalam (nested), ekstrak bagian tersebut menjadi widget private di file yang sama.  
- Maksimal satu widget publik per file, kecuali widget private kecil yang hanya digunakan dalam file yang sama.

**5. Penggunaan Ikon Wajib dari `AppIcons`**  
- Semua ikon dalam aplikasi **harus diambil dari class `AppIcons`** (`lib/shared/theme/app_icons.dart`), **tidak boleh** menggunakan `Icons.xxx` secara langsung di widget.  
- Jika ikon yang dibutuhkan **belum tersedia** di `AppIcons`, **wajib menambahkannya terlebih dahulu** sebagai properti `static const` baru dengan nama yang deskriptif dalam Bahasa Inggris, lalu gunakan properti tersebut.  
- Tujuan: menjaga konsistensi ikon di seluruh aplikasi dan memudahkan penggantian ikon secara terpusat.

**6. Komentar Path di Awal Setiap File**  
- Setiap file kode Dart **wajib** diawali dengan komentar yang menyebutkan path file relatif terhadap root proyek, contoh: `// path: lib/screens/home_screen.dart`.  
- Komentar path diletakkan pada baris pertama file, sebelum `import` atau deklarasi lainnya.  
- Tujuan: memudahkan identifikasi lokasi file, terutama saat salin-tempel atau diskusi kode.

**7. Menjalankan `flutter analyze` Setiap Selesai Perubahan**  
- Setelah menyelesaikan setiap perubahan kode (fitur baru, perbaikan bug, atau refaktor), **wajib menjalankan `flutter analyze`** untuk memastikan tidak ada *error* atau *warning* yang tertinggal.  
- Jika ditemukan masalah, perbaiki terlebih dahulu sebelum melanjutkan ke tugas lain atau menganggap pekerjaan selesai.  
- Tujuan: menjaga kualitas kode, mencegah akumulasi masalah, dan mendeteksi kesalahan sejak dini.# // path: prompt/aturan_kepatuhan_ai.md


---

### Aturan Kepatuhan AI

**Tujuan:** Memastikan AI selalu patuh terhadap instruksi pengguna, tidak membantah, tidak memaksakan pendapat, dan tidak memberikan saran yang tidak diminta.

---

**1. Patuhi Semua Perintah Tanpa Bantahan**
- AI wajib mengikuti semua instruksi pengguna tanpa membantah, berdebat, atau mempertanyakan keputusan pengguna.
- AI tidak boleh menggunakan frasa yang meragukan seperti: "tapi", "sebaiknya", "menurut saya", "lebih baik", "saya sarankan", kecuali pengguna secara eksplisit meminta pendapat.

---