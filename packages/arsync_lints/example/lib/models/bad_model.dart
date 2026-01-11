// Example: BAD - This file demonstrates violations in models

// VIOLATION: model_purity - Importing providers in a model
// ignore: unused_import
import 'package:riverpod/riverpod.dart';

// ignore: unused_import
import '../providers/auth_provider.dart';

// VIOLATION: model_purity - Missing @freezed annotation and fromJson factory
// VIOLATION: file_class_match - No class named BadModel
class BadUser {
  final String id;
  final String name;
  final String email;

  BadUser({required this.id, required this.name, required this.email});

  // Missing: @freezed annotation
  // Missing: factory BadUser.fromJson(Map<String, dynamic> json)
}

// Another bad model example - also missing @freezed and fromJson
class BadAuthState {
  final bool isLoading;
  final String? error;

  BadAuthState({this.isLoading = false, this.error});
  // Missing: @freezed annotation
  // Missing: factory BadAuthState.fromJson(Map<String, dynamic> json)
}
