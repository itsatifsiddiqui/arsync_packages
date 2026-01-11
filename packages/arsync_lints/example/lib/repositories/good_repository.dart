// Example: GOOD - This file demonstrates correct repository usage
// 1 file = 1 repository class + 1 provider
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import '../providers/core/dio_provider.dart';
import '../models/good_model.dart';

// OK: Provider at top level, ends with RepoProvider
final goodRepoProvider = Provider<GoodRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return GoodRepository(dio);
});

/// Good repository for data access.
class GoodRepository {
  // OK: Dependency injected via constructor
  final Dio _dio;

  GoodRepository(this._dio);

  // OK: Returns Future<T> and throws on error
  Future<User> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  }

  // OK: Returns Future<List<T>>
  Future<List<User>> getAllUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List)
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // OK: Returns Future<void>
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  // OK: Returns Stream<T>
  Stream<List<User>> watchUsers() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      final users = await getAllUsers();
      yield users;
    }
  }
}
