// Example: GOOD - This file demonstrates correct model usage with freezed
import 'package:freezed_annotation/freezed_annotation.dart';

part 'good_model.freezed.dart';
part 'good_model.g.dart';

// OK: Class name matches file name
// OK: Has @freezed annotation
// OK: Has fromJson factory
@freezed
sealed class GoodModel with _$GoodModel {
  const factory GoodModel({
    required String id,
    required String name,
  }) = _GoodModel;

  factory GoodModel.fromJson(Map<String, dynamic> json) =>
      _$GoodModelFromJson(json);
}

// OK: Model with @freezed annotation and fromJson factory
@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
    @Default(false) bool isVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// OK: AuthState model with @freezed
@freezed
sealed class AuthStateModel with _$AuthStateModel {
  const factory AuthStateModel({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? user,
    String? error,
  }) = _AuthStateModel;

  factory AuthStateModel.fromJson(Map<String, dynamic> json) =>
      _$AuthStateModelFromJson(json);
}
