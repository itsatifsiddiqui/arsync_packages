// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'good_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GoodModel _$GoodModelFromJson(Map<String, dynamic> json) {
  return _GoodModel.fromJson(json);
}

/// @nodoc
mixin _$GoodModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this GoodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoodModelCopyWith<GoodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoodModelCopyWith<$Res> {
  factory $GoodModelCopyWith(GoodModel value, $Res Function(GoodModel) then) =
      _$GoodModelCopyWithImpl<$Res, GoodModel>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$GoodModelCopyWithImpl<$Res, $Val extends GoodModel>
    implements $GoodModelCopyWith<$Res> {
  _$GoodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoodModelImplCopyWith<$Res>
    implements $GoodModelCopyWith<$Res> {
  factory _$$GoodModelImplCopyWith(
    _$GoodModelImpl value,
    $Res Function(_$GoodModelImpl) then,
  ) = __$$GoodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$GoodModelImplCopyWithImpl<$Res>
    extends _$GoodModelCopyWithImpl<$Res, _$GoodModelImpl>
    implements _$$GoodModelImplCopyWith<$Res> {
  __$$GoodModelImplCopyWithImpl(
    _$GoodModelImpl _value,
    $Res Function(_$GoodModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$GoodModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoodModelImpl implements _GoodModel {
  const _$GoodModelImpl({required this.id, required this.name});

  factory _$GoodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoodModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'GoodModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of GoodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoodModelImplCopyWith<_$GoodModelImpl> get copyWith =>
      __$$GoodModelImplCopyWithImpl<_$GoodModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoodModelImplToJson(this);
  }
}

abstract class _GoodModel implements GoodModel {
  const factory _GoodModel({
    required final String id,
    required final String name,
  }) = _$GoodModelImpl;

  factory _GoodModel.fromJson(Map<String, dynamic> json) =
      _$GoodModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of GoodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoodModelImplCopyWith<_$GoodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String name,
    String email,
    String? avatarUrl,
    bool isVerified,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? avatarUrl = freezed,
    Object? isVerified = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String email,
    String? avatarUrl,
    bool isVerified,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? avatarUrl = freezed,
    Object? isVerified = null,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isVerified = false,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isVerified;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, email, avatarUrl, isVerified);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    required final String name,
    required final String email,
    final String? avatarUrl,
    final bool isVerified,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String? get avatarUrl;
  @override
  bool get isVerified;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthStateModel _$AuthStateModelFromJson(Map<String, dynamic> json) {
  return _AuthStateModel.fromJson(json);
}

/// @nodoc
mixin _$AuthStateModel {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isAuthenticated => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this AuthStateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateModelCopyWith<AuthStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateModelCopyWith<$Res> {
  factory $AuthStateModelCopyWith(
    AuthStateModel value,
    $Res Function(AuthStateModel) then,
  ) = _$AuthStateModelCopyWithImpl<$Res, AuthStateModel>;
  @useResult
  $Res call({bool isLoading, bool isAuthenticated, User? user, String? error});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthStateModelCopyWithImpl<$Res, $Val extends AuthStateModel>
    implements $AuthStateModelCopyWith<$Res> {
  _$AuthStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isAuthenticated = null,
    Object? user = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAuthenticated: null == isAuthenticated
                ? _value.isAuthenticated
                : isAuthenticated // ignore: cast_nullable_to_non_nullable
                      as bool,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthStateModelImplCopyWith<$Res>
    implements $AuthStateModelCopyWith<$Res> {
  factory _$$AuthStateModelImplCopyWith(
    _$AuthStateModelImpl value,
    $Res Function(_$AuthStateModelImpl) then,
  ) = __$$AuthStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, bool isAuthenticated, User? user, String? error});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthStateModelImplCopyWithImpl<$Res>
    extends _$AuthStateModelCopyWithImpl<$Res, _$AuthStateModelImpl>
    implements _$$AuthStateModelImplCopyWith<$Res> {
  __$$AuthStateModelImplCopyWithImpl(
    _$AuthStateModelImpl _value,
    $Res Function(_$AuthStateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isAuthenticated = null,
    Object? user = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AuthStateModelImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAuthenticated: null == isAuthenticated
            ? _value.isAuthenticated
            : isAuthenticated // ignore: cast_nullable_to_non_nullable
                  as bool,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthStateModelImpl implements _AuthStateModel {
  const _$AuthStateModelImpl({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  factory _$AuthStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthStateModelImplFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isAuthenticated;
  @override
  final User? user;
  @override
  final String? error;

  @override
  String toString() {
    return 'AuthStateModel(isLoading: $isLoading, isAuthenticated: $isAuthenticated, user: $user, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateModelImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isAuthenticated, user, error);

  /// Create a copy of AuthStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateModelImplCopyWith<_$AuthStateModelImpl> get copyWith =>
      __$$AuthStateModelImplCopyWithImpl<_$AuthStateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthStateModelImplToJson(this);
  }
}

abstract class _AuthStateModel implements AuthStateModel {
  const factory _AuthStateModel({
    final bool isLoading,
    final bool isAuthenticated,
    final User? user,
    final String? error,
  }) = _$AuthStateModelImpl;

  factory _AuthStateModel.fromJson(Map<String, dynamic> json) =
      _$AuthStateModelImpl.fromJson;

  @override
  bool get isLoading;
  @override
  bool get isAuthenticated;
  @override
  User? get user;
  @override
  String? get error;

  /// Create a copy of AuthStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthStateModelImplCopyWith<_$AuthStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
