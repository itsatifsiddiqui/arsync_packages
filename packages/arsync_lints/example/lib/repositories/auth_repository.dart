// Example: GOOD - Repository with proper structure
// 1 file = 1 repository class + 1 provider
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import '../providers/core/dio_provider.dart';

// OK: Provider at top level, ends with RepoProvider
final authRepoProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

// OK: Class name contains "Repository"
class AuthRepository {
  // OK: Dependency injected via constructor
  final Dio _dio;

  AuthRepository(this._dio);

  // OK: Returns Future<T>
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  // OK: Returns Future<void>
  Future<void> logout() async {
    await _dio.post('/logout');
  }
}
