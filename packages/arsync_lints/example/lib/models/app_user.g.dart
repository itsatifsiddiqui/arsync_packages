// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  userid: readUserId(json, 'userid') as String,
  name: json['name'] as String,
  email: json['email'] as String,
  photoURL: json['photoURL'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  userType:
      $enumDecodeNullable(_$UserTypeEnumMap, json['userType']) ?? UserType.user,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'userid': instance.userid,
  'name': instance.name,
  'email': instance.email,
  'photoURL': instance.photoURL,
  'isEmailVerified': instance.isEmailVerified,
  'userType': _$UserTypeEnumMap[instance.userType]!,
  'isActive': instance.isActive,
};

const _$UserTypeEnumMap = {UserType.user: 'user', UserType.admin: 'admin'};
