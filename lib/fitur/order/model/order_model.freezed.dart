// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderModel {
  String get id;
  String get customerId;
  String get packageId;
  DateTime get date;
  StatusOrderEnum get status;
  DateTime? get diperbaruiPada;
  bool get diHapus;
  DateTime? get diarsipkanPada;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderModelCopyWith<OrderModel> get copyWith =>
      _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrderModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.packageId, packageId) ||
                other.packageId == packageId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, customerId, packageId, date,
      status, diperbaruiPada, diHapus, diarsipkanPada);

  @override
  String toString() {
    return 'OrderModel(id: $id, customerId: $customerId, packageId: $packageId, date: $date, status: $status, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) _then) =
      _$OrderModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String customerId,
      String packageId,
      DateTime date,
      StatusOrderEnum status,
      DateTime? diperbaruiPada,
      bool diHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res> implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? packageId = null,
    Object? date = null,
    Object? status = null,
    Object? diperbaruiPada = freezed,
    Object? diHapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      packageId: null == packageId
          ? _self.packageId
          : packageId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusOrderEnum,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diHapus: null == diHapus
          ? _self.diHapus
          : diHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OrderModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OrderModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderModel():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OrderModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String customerId,
            String packageId,
            DateTime date,
            StatusOrderEnum status,
            DateTime? diperbaruiPada,
            bool diHapus,
            DateTime? diarsipkanPada)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderModel() when $default != null:
        return $default(
            _that.id,
            _that.customerId,
            _that.packageId,
            _that.date,
            _that.status,
            _that.diperbaruiPada,
            _that.diHapus,
            _that.diarsipkanPada);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String customerId,
            String packageId,
            DateTime date,
            StatusOrderEnum status,
            DateTime? diperbaruiPada,
            bool diHapus,
            DateTime? diarsipkanPada)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderModel():
        return $default(
            _that.id,
            _that.customerId,
            _that.packageId,
            _that.date,
            _that.status,
            _that.diperbaruiPada,
            _that.diHapus,
            _that.diarsipkanPada);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String customerId,
            String packageId,
            DateTime date,
            StatusOrderEnum status,
            DateTime? diperbaruiPada,
            bool diHapus,
            DateTime? diarsipkanPada)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderModel() when $default != null:
        return $default(
            _that.id,
            _that.customerId,
            _that.packageId,
            _that.date,
            _that.status,
            _that.diperbaruiPada,
            _that.diHapus,
            _that.diarsipkanPada);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OrderModel extends OrderModel {
  const _OrderModel(
      {required this.id,
      required this.customerId,
      required this.packageId,
      required this.date,
      this.status = StatusOrderEnum.baru,
      this.diperbaruiPada,
      this.diHapus = false,
      this.diarsipkanPada})
      : super._();

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String packageId;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final StatusOrderEnum status;
  @override
  final DateTime? diperbaruiPada;
  @override
  @JsonKey()
  final bool diHapus;
  @override
  final DateTime? diarsipkanPada;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderModelCopyWith<_OrderModel> get copyWith =>
      __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrderModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.packageId, packageId) ||
                other.packageId == packageId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, customerId, packageId, date,
      status, diperbaruiPada, diHapus, diarsipkanPada);

  @override
  String toString() {
    return 'OrderModel(id: $id, customerId: $customerId, packageId: $packageId, date: $date, status: $status, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(
          _OrderModel value, $Res Function(_OrderModel) _then) =
      __$OrderModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      String packageId,
      DateTime date,
      StatusOrderEnum status,
      DateTime? diperbaruiPada,
      bool diHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class __$OrderModelCopyWithImpl<$Res> implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? packageId = null,
    Object? date = null,
    Object? status = null,
    Object? diperbaruiPada = freezed,
    Object? diHapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_OrderModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      packageId: null == packageId
          ? _self.packageId
          : packageId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusOrderEnum,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diHapus: null == diHapus
          ? _self.diHapus
          : diHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
