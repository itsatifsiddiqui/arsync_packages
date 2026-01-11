// Example: GOOD - Proper user repository file
// 1 file = 1 repository class + 1 provider
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import '../providers/core/dio_provider.dart';
import '../models/good_model.dart';

// OK: Provider defined at top, ends with RepoProvider
final userRepoProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio);
});

/// User repository - class name matches file name
class UserRepository {
  // OK: Dependency injected via constructor
  final Dio _dio;

  UserRepository(this._dio);

  // OK: Returns Future<T> and throws on error
  Future<User> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // OK: Returns Future<List<T>>
  Future<List<User>> getAllUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List)
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // OK: Returns Future<T>
  Future<User> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // OK: Returns Future<T>
  Future<User> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return User.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  // OK: Returns Future<void>
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  // OK: Returns Future<T>
  Future<User> updateProfile(String name, String email) async {
    final response = await _dio.patch(
      '/users/me',
      data: {'name': name, 'email': email},
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
