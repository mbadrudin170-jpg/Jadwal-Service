// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventModel {

 String get id; String get linkGambar; bool get statusAktif; DateTime get tanggalDibuat; DateTime get tanggalMulai; DateTime get tanggalBerakhir; DateTime? get diperbaruiPada;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.linkGambar, linkGambar) || other.linkGambar == linkGambar)&&(identical(other.statusAktif, statusAktif) || other.statusAktif == statusAktif)&&(identical(other.tanggalDibuat, tanggalDibuat) || other.tanggalDibuat == tanggalDibuat)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalBerakhir, tanggalBerakhir) || other.tanggalBerakhir == tanggalBerakhir)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,linkGambar,statusAktif,tanggalDibuat,tanggalMulai,tanggalBerakhir,diperbaruiPada);

@override
String toString() {
  return 'EventModel(id: $id, linkGambar: $linkGambar, statusAktif: $statusAktif, tanggalDibuat: $tanggalDibuat, tanggalMulai: $tanggalMulai, tanggalBerakhir: $tanggalBerakhir, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String id, String linkGambar, bool statusAktif, DateTime tanggalDibuat, DateTime tanggalMulai, DateTime tanggalBerakhir, DateTime? diperbaruiPada
});




}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? linkGambar = null,Object? statusAktif = null,Object? tanggalDibuat = null,Object? tanggalMulai = null,Object? tanggalBerakhir = null,Object? diperbaruiPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,linkGambar: null == linkGambar ? _self.linkGambar : linkGambar // ignore: cast_nullable_to_non_nullable
as String,statusAktif: null == statusAktif ? _self.statusAktif : statusAktif // ignore: cast_nullable_to_non_nullable
as bool,tanggalDibuat: null == tanggalDibuat ? _self.tanggalDibuat : tanggalDibuat // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalBerakhir: null == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String linkGambar,  bool statusAktif,  DateTime tanggalDibuat,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  DateTime? diperbaruiPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.linkGambar,_that.statusAktif,_that.tanggalDibuat,_that.tanggalMulai,_that.tanggalBerakhir,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String linkGambar,  bool statusAktif,  DateTime tanggalDibuat,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  DateTime? diperbaruiPada)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.linkGambar,_that.statusAktif,_that.tanggalDibuat,_that.tanggalMulai,_that.tanggalBerakhir,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String linkGambar,  bool statusAktif,  DateTime tanggalDibuat,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  DateTime? diperbaruiPada)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.linkGambar,_that.statusAktif,_that.tanggalDibuat,_that.tanggalMulai,_that.tanggalBerakhir,_that.diperbaruiPada);case _:
  return null;

}
}

}

/// @nodoc


class _EventModel extends EventModel {
  const _EventModel({required this.id, required this.linkGambar, this.statusAktif = false, required this.tanggalDibuat, required this.tanggalMulai, required this.tanggalBerakhir, this.diperbaruiPada}): super._();
  

@override final  String id;
@override final  String linkGambar;
@override@JsonKey() final  bool statusAktif;
@override final  DateTime tanggalDibuat;
@override final  DateTime tanggalMulai;
@override final  DateTime tanggalBerakhir;
@override final  DateTime? diperbaruiPada;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.linkGambar, linkGambar) || other.linkGambar == linkGambar)&&(identical(other.statusAktif, statusAktif) || other.statusAktif == statusAktif)&&(identical(other.tanggalDibuat, tanggalDibuat) || other.tanggalDibuat == tanggalDibuat)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalBerakhir, tanggalBerakhir) || other.tanggalBerakhir == tanggalBerakhir)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,linkGambar,statusAktif,tanggalDibuat,tanggalMulai,tanggalBerakhir,diperbaruiPada);

@override
String toString() {
  return 'EventModel(id: $id, linkGambar: $linkGambar, statusAktif: $statusAktif, tanggalDibuat: $tanggalDibuat, tanggalMulai: $tanggalMulai, tanggalBerakhir: $tanggalBerakhir, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String linkGambar, bool statusAktif, DateTime tanggalDibuat, DateTime tanggalMulai, DateTime tanggalBerakhir, DateTime? diperbaruiPada
});




}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? linkGambar = null,Object? statusAktif = null,Object? tanggalDibuat = null,Object? tanggalMulai = null,Object? tanggalBerakhir = null,Object? diperbaruiPada = freezed,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,linkGambar: null == linkGambar ? _self.linkGambar : linkGambar // ignore: cast_nullable_to_non_nullable
as String,statusAktif: null == statusAktif ? _self.statusAktif : statusAktif // ignore: cast_nullable_to_non_nullable
as bool,tanggalDibuat: null == tanggalDibuat ? _self.tanggalDibuat : tanggalDibuat // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalBerakhir: null == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
