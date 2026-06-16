// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsModel {

 String get id; int get waktuOtomatisSinkronisasi; int get waktuOtomatisHapusDataArsip; bool get modeMaintenance; String get infoMaintenance; DateTime? get diperbaruiPada;
/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsModelCopyWith<SettingsModel> get copyWith => _$SettingsModelCopyWithImpl<SettingsModel>(this as SettingsModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.waktuOtomatisSinkronisasi, waktuOtomatisSinkronisasi) || other.waktuOtomatisSinkronisasi == waktuOtomatisSinkronisasi)&&(identical(other.waktuOtomatisHapusDataArsip, waktuOtomatisHapusDataArsip) || other.waktuOtomatisHapusDataArsip == waktuOtomatisHapusDataArsip)&&(identical(other.modeMaintenance, modeMaintenance) || other.modeMaintenance == modeMaintenance)&&(identical(other.infoMaintenance, infoMaintenance) || other.infoMaintenance == infoMaintenance)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,waktuOtomatisSinkronisasi,waktuOtomatisHapusDataArsip,modeMaintenance,infoMaintenance,diperbaruiPada);

@override
String toString() {
  return 'SettingsModel(id: $id, waktuOtomatisSinkronisasi: $waktuOtomatisSinkronisasi, waktuOtomatisHapusDataArsip: $waktuOtomatisHapusDataArsip, modeMaintenance: $modeMaintenance, infoMaintenance: $infoMaintenance, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class $SettingsModelCopyWith<$Res>  {
  factory $SettingsModelCopyWith(SettingsModel value, $Res Function(SettingsModel) _then) = _$SettingsModelCopyWithImpl;
@useResult
$Res call({
 String id, int waktuOtomatisSinkronisasi, int waktuOtomatisHapusDataArsip, bool modeMaintenance, String infoMaintenance, DateTime? diperbaruiPada
});




}
/// @nodoc
class _$SettingsModelCopyWithImpl<$Res>
    implements $SettingsModelCopyWith<$Res> {
  _$SettingsModelCopyWithImpl(this._self, this._then);

  final SettingsModel _self;
  final $Res Function(SettingsModel) _then;

/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? waktuOtomatisSinkronisasi = null,Object? waktuOtomatisHapusDataArsip = null,Object? modeMaintenance = null,Object? infoMaintenance = null,Object? diperbaruiPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,waktuOtomatisSinkronisasi: null == waktuOtomatisSinkronisasi ? _self.waktuOtomatisSinkronisasi : waktuOtomatisSinkronisasi // ignore: cast_nullable_to_non_nullable
as int,waktuOtomatisHapusDataArsip: null == waktuOtomatisHapusDataArsip ? _self.waktuOtomatisHapusDataArsip : waktuOtomatisHapusDataArsip // ignore: cast_nullable_to_non_nullable
as int,modeMaintenance: null == modeMaintenance ? _self.modeMaintenance : modeMaintenance // ignore: cast_nullable_to_non_nullable
as bool,infoMaintenance: null == infoMaintenance ? _self.infoMaintenance : infoMaintenance // ignore: cast_nullable_to_non_nullable
as String,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsModel].
extension SettingsModelPatterns on SettingsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingModel value)  $default,){
final _that = this;
switch (_that) {
case _SettingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingModel value)?  $default,){
final _that = this;
switch (_that) {
case _SettingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int waktuOtomatisSinkronisasi,  int waktuOtomatisHapusDataArsip,  bool modeMaintenance,  String infoMaintenance,  DateTime? diperbaruiPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingModel() when $default != null:
return $default(_that.id,_that.waktuOtomatisSinkronisasi,_that.waktuOtomatisHapusDataArsip,_that.modeMaintenance,_that.infoMaintenance,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int waktuOtomatisSinkronisasi,  int waktuOtomatisHapusDataArsip,  bool modeMaintenance,  String infoMaintenance,  DateTime? diperbaruiPada)  $default,) {final _that = this;
switch (_that) {
case _SettingModel():
return $default(_that.id,_that.waktuOtomatisSinkronisasi,_that.waktuOtomatisHapusDataArsip,_that.modeMaintenance,_that.infoMaintenance,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int waktuOtomatisSinkronisasi,  int waktuOtomatisHapusDataArsip,  bool modeMaintenance,  String infoMaintenance,  DateTime? diperbaruiPada)?  $default,) {final _that = this;
switch (_that) {
case _SettingModel() when $default != null:
return $default(_that.id,_that.waktuOtomatisSinkronisasi,_that.waktuOtomatisHapusDataArsip,_that.modeMaintenance,_that.infoMaintenance,_that.diperbaruiPada);case _:
  return null;

}
}

}

/// @nodoc


class _SettingModel extends SettingsModel {
  const _SettingModel({this.id = idGlobalSetting, this.waktuOtomatisSinkronisasi = 24, this.waktuOtomatisHapusDataArsip = 30, this.modeMaintenance = false, this.infoMaintenance = '', this.diperbaruiPada}): super._();
  

@override@JsonKey() final  String id;
@override@JsonKey() final  int waktuOtomatisSinkronisasi;
@override@JsonKey() final  int waktuOtomatisHapusDataArsip;
@override@JsonKey() final  bool modeMaintenance;
@override@JsonKey() final  String infoMaintenance;
@override final  DateTime? diperbaruiPada;

/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingModelCopyWith<_SettingModel> get copyWith => __$SettingModelCopyWithImpl<_SettingModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.waktuOtomatisSinkronisasi, waktuOtomatisSinkronisasi) || other.waktuOtomatisSinkronisasi == waktuOtomatisSinkronisasi)&&(identical(other.waktuOtomatisHapusDataArsip, waktuOtomatisHapusDataArsip) || other.waktuOtomatisHapusDataArsip == waktuOtomatisHapusDataArsip)&&(identical(other.modeMaintenance, modeMaintenance) || other.modeMaintenance == modeMaintenance)&&(identical(other.infoMaintenance, infoMaintenance) || other.infoMaintenance == infoMaintenance)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,waktuOtomatisSinkronisasi,waktuOtomatisHapusDataArsip,modeMaintenance,infoMaintenance,diperbaruiPada);

@override
String toString() {
  return 'SettingsModel(id: $id, waktuOtomatisSinkronisasi: $waktuOtomatisSinkronisasi, waktuOtomatisHapusDataArsip: $waktuOtomatisHapusDataArsip, modeMaintenance: $modeMaintenance, infoMaintenance: $infoMaintenance, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class _$SettingModelCopyWith<$Res> implements $SettingsModelCopyWith<$Res> {
  factory _$SettingModelCopyWith(_SettingModel value, $Res Function(_SettingModel) _then) = __$SettingModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int waktuOtomatisSinkronisasi, int waktuOtomatisHapusDataArsip, bool modeMaintenance, String infoMaintenance, DateTime? diperbaruiPada
});




}
/// @nodoc
class __$SettingModelCopyWithImpl<$Res>
    implements _$SettingModelCopyWith<$Res> {
  __$SettingModelCopyWithImpl(this._self, this._then);

  final _SettingModel _self;
  final $Res Function(_SettingModel) _then;

/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? waktuOtomatisSinkronisasi = null,Object? waktuOtomatisHapusDataArsip = null,Object? modeMaintenance = null,Object? infoMaintenance = null,Object? diperbaruiPada = freezed,}) {
  return _then(_SettingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,waktuOtomatisSinkronisasi: null == waktuOtomatisSinkronisasi ? _self.waktuOtomatisSinkronisasi : waktuOtomatisSinkronisasi // ignore: cast_nullable_to_non_nullable
as int,waktuOtomatisHapusDataArsip: null == waktuOtomatisHapusDataArsip ? _self.waktuOtomatisHapusDataArsip : waktuOtomatisHapusDataArsip // ignore: cast_nullable_to_non_nullable
as int,modeMaintenance: null == modeMaintenance ? _self.modeMaintenance : modeMaintenance // ignore: cast_nullable_to_non_nullable
as bool,infoMaintenance: null == infoMaintenance ? _self.infoMaintenance : infoMaintenance // ignore: cast_nullable_to_non_nullable
as String,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
