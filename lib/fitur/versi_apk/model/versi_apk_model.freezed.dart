// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'versi_apk_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VersiApkModel {

 String get id; String get catatanRilis; Map<ArsitekturApk, int> get nomorBuildTerakhir; Map<ArsitekturApk, String> get linkDownload; String get versiTerkahir; bool get wajibUpdate; String get linkYoutubeTutorial; bool get diHapus; DateTime? get diarsipkanPada; DateTime? get diperbaruiPada;
/// Create a copy of VersiApkModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersiApkModelCopyWith<VersiApkModel> get copyWith => _$VersiApkModelCopyWithImpl<VersiApkModel>(this as VersiApkModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersiApkModel&&(identical(other.id, id) || other.id == id)&&(identical(other.catatanRilis, catatanRilis) || other.catatanRilis == catatanRilis)&&const DeepCollectionEquality().equals(other.nomorBuildTerakhir, nomorBuildTerakhir)&&const DeepCollectionEquality().equals(other.linkDownload, linkDownload)&&(identical(other.versiTerkahir, versiTerkahir) || other.versiTerkahir == versiTerkahir)&&(identical(other.wajibUpdate, wajibUpdate) || other.wajibUpdate == wajibUpdate)&&(identical(other.linkYoutubeTutorial, linkYoutubeTutorial) || other.linkYoutubeTutorial == linkYoutubeTutorial)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,catatanRilis,const DeepCollectionEquality().hash(nomorBuildTerakhir),const DeepCollectionEquality().hash(linkDownload),versiTerkahir,wajibUpdate,linkYoutubeTutorial,diHapus,diarsipkanPada,diperbaruiPada);

@override
String toString() {
  return 'VersiApkModel(id: $id, catatanRilis: $catatanRilis, nomorBuildTerakhir: $nomorBuildTerakhir, linkDownload: $linkDownload, versiTerkahir: $versiTerkahir, wajibUpdate: $wajibUpdate, linkYoutubeTutorial: $linkYoutubeTutorial, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class $VersiApkModelCopyWith<$Res>  {
  factory $VersiApkModelCopyWith(VersiApkModel value, $Res Function(VersiApkModel) _then) = _$VersiApkModelCopyWithImpl;
@useResult
$Res call({
 String id, String catatanRilis, Map<ArsitekturApk, int> nomorBuildTerakhir, Map<ArsitekturApk, String> linkDownload, String versiTerkahir, bool wajibUpdate, String linkYoutubeTutorial, bool diHapus, DateTime? diarsipkanPada, DateTime? diperbaruiPada
});




}
/// @nodoc
class _$VersiApkModelCopyWithImpl<$Res>
    implements $VersiApkModelCopyWith<$Res> {
  _$VersiApkModelCopyWithImpl(this._self, this._then);

  final VersiApkModel _self;
  final $Res Function(VersiApkModel) _then;

/// Create a copy of VersiApkModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? catatanRilis = null,Object? nomorBuildTerakhir = null,Object? linkDownload = null,Object? versiTerkahir = null,Object? wajibUpdate = null,Object? linkYoutubeTutorial = null,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? diperbaruiPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,catatanRilis: null == catatanRilis ? _self.catatanRilis : catatanRilis // ignore: cast_nullable_to_non_nullable
as String,nomorBuildTerakhir: null == nomorBuildTerakhir ? _self.nomorBuildTerakhir : nomorBuildTerakhir // ignore: cast_nullable_to_non_nullable
as Map<ArsitekturApk, int>,linkDownload: null == linkDownload ? _self.linkDownload : linkDownload // ignore: cast_nullable_to_non_nullable
as Map<ArsitekturApk, String>,versiTerkahir: null == versiTerkahir ? _self.versiTerkahir : versiTerkahir // ignore: cast_nullable_to_non_nullable
as String,wajibUpdate: null == wajibUpdate ? _self.wajibUpdate : wajibUpdate // ignore: cast_nullable_to_non_nullable
as bool,linkYoutubeTutorial: null == linkYoutubeTutorial ? _self.linkYoutubeTutorial : linkYoutubeTutorial // ignore: cast_nullable_to_non_nullable
as String,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VersiApkModel].
extension VersiApkModelPatterns on VersiApkModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersiApkModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersiApkModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersiApkModel value)  $default,){
final _that = this;
switch (_that) {
case _VersiApkModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersiApkModel value)?  $default,){
final _that = this;
switch (_that) {
case _VersiApkModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String catatanRilis,  Map<ArsitekturApk, int> nomorBuildTerakhir,  Map<ArsitekturApk, String> linkDownload,  String versiTerkahir,  bool wajibUpdate,  String linkYoutubeTutorial,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersiApkModel() when $default != null:
return $default(_that.id,_that.catatanRilis,_that.nomorBuildTerakhir,_that.linkDownload,_that.versiTerkahir,_that.wajibUpdate,_that.linkYoutubeTutorial,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String catatanRilis,  Map<ArsitekturApk, int> nomorBuildTerakhir,  Map<ArsitekturApk, String> linkDownload,  String versiTerkahir,  bool wajibUpdate,  String linkYoutubeTutorial,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)  $default,) {final _that = this;
switch (_that) {
case _VersiApkModel():
return $default(_that.id,_that.catatanRilis,_that.nomorBuildTerakhir,_that.linkDownload,_that.versiTerkahir,_that.wajibUpdate,_that.linkYoutubeTutorial,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String catatanRilis,  Map<ArsitekturApk, int> nomorBuildTerakhir,  Map<ArsitekturApk, String> linkDownload,  String versiTerkahir,  bool wajibUpdate,  String linkYoutubeTutorial,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)?  $default,) {final _that = this;
switch (_that) {
case _VersiApkModel() when $default != null:
return $default(_that.id,_that.catatanRilis,_that.nomorBuildTerakhir,_that.linkDownload,_that.versiTerkahir,_that.wajibUpdate,_that.linkYoutubeTutorial,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
  return null;

}
}

}

/// @nodoc


class _VersiApkModel extends VersiApkModel {
  const _VersiApkModel({required this.id, this.catatanRilis = '', final  Map<ArsitekturApk, int> nomorBuildTerakhir = const <ArsitekturApk, int>{}, final  Map<ArsitekturApk, String> linkDownload = const <ArsitekturApk, String>{}, this.versiTerkahir = '', this.wajibUpdate = false, this.linkYoutubeTutorial = '', this.diHapus = false, this.diarsipkanPada, this.diperbaruiPada}): _nomorBuildTerakhir = nomorBuildTerakhir,_linkDownload = linkDownload,super._();
  

@override final  String id;
@override@JsonKey() final  String catatanRilis;
 final  Map<ArsitekturApk, int> _nomorBuildTerakhir;
@override@JsonKey() Map<ArsitekturApk, int> get nomorBuildTerakhir {
  if (_nomorBuildTerakhir is EqualUnmodifiableMapView) return _nomorBuildTerakhir;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nomorBuildTerakhir);
}

 final  Map<ArsitekturApk, String> _linkDownload;
@override@JsonKey() Map<ArsitekturApk, String> get linkDownload {
  if (_linkDownload is EqualUnmodifiableMapView) return _linkDownload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_linkDownload);
}

@override@JsonKey() final  String versiTerkahir;
@override@JsonKey() final  bool wajibUpdate;
@override@JsonKey() final  String linkYoutubeTutorial;
@override@JsonKey() final  bool diHapus;
@override final  DateTime? diarsipkanPada;
@override final  DateTime? diperbaruiPada;

/// Create a copy of VersiApkModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersiApkModelCopyWith<_VersiApkModel> get copyWith => __$VersiApkModelCopyWithImpl<_VersiApkModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersiApkModel&&(identical(other.id, id) || other.id == id)&&(identical(other.catatanRilis, catatanRilis) || other.catatanRilis == catatanRilis)&&const DeepCollectionEquality().equals(other._nomorBuildTerakhir, _nomorBuildTerakhir)&&const DeepCollectionEquality().equals(other._linkDownload, _linkDownload)&&(identical(other.versiTerkahir, versiTerkahir) || other.versiTerkahir == versiTerkahir)&&(identical(other.wajibUpdate, wajibUpdate) || other.wajibUpdate == wajibUpdate)&&(identical(other.linkYoutubeTutorial, linkYoutubeTutorial) || other.linkYoutubeTutorial == linkYoutubeTutorial)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,catatanRilis,const DeepCollectionEquality().hash(_nomorBuildTerakhir),const DeepCollectionEquality().hash(_linkDownload),versiTerkahir,wajibUpdate,linkYoutubeTutorial,diHapus,diarsipkanPada,diperbaruiPada);

@override
String toString() {
  return 'VersiApkModel(id: $id, catatanRilis: $catatanRilis, nomorBuildTerakhir: $nomorBuildTerakhir, linkDownload: $linkDownload, versiTerkahir: $versiTerkahir, wajibUpdate: $wajibUpdate, linkYoutubeTutorial: $linkYoutubeTutorial, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class _$VersiApkModelCopyWith<$Res> implements $VersiApkModelCopyWith<$Res> {
  factory _$VersiApkModelCopyWith(_VersiApkModel value, $Res Function(_VersiApkModel) _then) = __$VersiApkModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String catatanRilis, Map<ArsitekturApk, int> nomorBuildTerakhir, Map<ArsitekturApk, String> linkDownload, String versiTerkahir, bool wajibUpdate, String linkYoutubeTutorial, bool diHapus, DateTime? diarsipkanPada, DateTime? diperbaruiPada
});




}
/// @nodoc
class __$VersiApkModelCopyWithImpl<$Res>
    implements _$VersiApkModelCopyWith<$Res> {
  __$VersiApkModelCopyWithImpl(this._self, this._then);

  final _VersiApkModel _self;
  final $Res Function(_VersiApkModel) _then;

/// Create a copy of VersiApkModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? catatanRilis = null,Object? nomorBuildTerakhir = null,Object? linkDownload = null,Object? versiTerkahir = null,Object? wajibUpdate = null,Object? linkYoutubeTutorial = null,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? diperbaruiPada = freezed,}) {
  return _then(_VersiApkModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,catatanRilis: null == catatanRilis ? _self.catatanRilis : catatanRilis // ignore: cast_nullable_to_non_nullable
as String,nomorBuildTerakhir: null == nomorBuildTerakhir ? _self._nomorBuildTerakhir : nomorBuildTerakhir // ignore: cast_nullable_to_non_nullable
as Map<ArsitekturApk, int>,linkDownload: null == linkDownload ? _self._linkDownload : linkDownload // ignore: cast_nullable_to_non_nullable
as Map<ArsitekturApk, String>,versiTerkahir: null == versiTerkahir ? _self.versiTerkahir : versiTerkahir // ignore: cast_nullable_to_non_nullable
as String,wajibUpdate: null == wajibUpdate ? _self.wajibUpdate : wajibUpdate // ignore: cast_nullable_to_non_nullable
as bool,linkYoutubeTutorial: null == linkYoutubeTutorial ? _self.linkYoutubeTutorial : linkYoutubeTutorial // ignore: cast_nullable_to_non_nullable
as String,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
