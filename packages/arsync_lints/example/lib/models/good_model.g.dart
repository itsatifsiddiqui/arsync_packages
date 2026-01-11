// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'good_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoodModelImpl _$$GoodModelImplFromJson(Map<String, dynamic> json) =>
    _$GoodModelImpl(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$$GoodModelImplToJson(_$GoodModelImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'isVerified': instance.isVerified,
    };

_$AuthStateModelImpl _$$AuthStateModelImplFromJson(Map<String, dynamic> json) =>
    _$AuthStateModelImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$AuthStateModelImplToJson(
  _$AuthStateModelImpl instance,
) => <String, dynamic>{
  'isLoading': instance.isLoading,
  'isAuthenticated': instance.isAuthenticated,
  'user': instance.user,
  'error': instance.error,
};
