// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'good_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GoodState {
  int get count => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of GoodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoodStateCopyWith<GoodState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoodStateCopyWith<$Res> {
  factory $GoodStateCopyWith(GoodState value, $Res Function(GoodState) then) =
      _$GoodStateCopyWithImpl<$Res, GoodState>;
  @useResult
  $Res call({int count, bool isLoading});
}

/// @nodoc
class _$GoodStateCopyWithImpl<$Res, $Val extends GoodState>
    implements $GoodStateCopyWith<$Res> {
  _$GoodStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoodStateImplCopyWith<$Res>
    implements $GoodStateCopyWith<$Res> {
  factory _$$GoodStateImplCopyWith(
          _$GoodStateImpl value, $Res Function(_$GoodStateImpl) then) =
      __$$GoodStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int count, bool isLoading});
}

/// @nodoc
class __$$GoodStateImplCopyWithImpl<$Res>
    extends _$GoodStateCopyWithImpl<$Res, _$GoodStateImpl>
    implements _$$GoodStateImplCopyWith<$Res> {
  __$$GoodStateImplCopyWithImpl(
      _$GoodStateImpl _value, $Res Function(_$GoodStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? isLoading = null,
  }) {
    return _then(_$GoodStateImpl(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$GoodStateImpl implements _GoodState {
  const _$GoodStateImpl({this.count = 0, this.isLoading = false});

  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'GoodState(count: $count, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoodStateImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, count, isLoading);

  /// Create a copy of GoodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoodStateImplCopyWith<_$GoodStateImpl> get copyWith =>
      __$$GoodStateImplCopyWithImpl<_$GoodStateImpl>(this, _$identity);
}

abstract class _GoodState implements GoodState {
  const factory _GoodState({final int count, final bool isLoading}) =
      _$GoodStateImpl;

  @override
  int get count;
  @override
  bool get isLoading;

  /// Create a copy of GoodState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoodStateImplCopyWith<_$GoodStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
