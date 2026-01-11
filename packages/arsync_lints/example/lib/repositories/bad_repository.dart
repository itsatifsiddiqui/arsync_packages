// Example: BAD - This file demonstrates violations in repositories
import 'package:dio/dio.dart';

// VIOLATION: repository_isolation - Importing screens
import '../screens/bad_screen.dart';

// VIOLATION: repository_isolation - Importing providers
import 'package:riverpod/riverpod.dart';
import '../providers/auth_provider.dart';

// VIOLATION: repository_provider_declaration - No RepoProvider defined
// Should have: final badUserRepoProvider = Provider((ref) => BadUserRepository(...));

class BadUserRepository {
  // VIOLATION: repository_dependency_injection - Direct instantiation!
  // Should be: final Dio _dio; BadUserRepository(this._dio);
  final Dio _dio = Dio();

  // VIOLATION: repository_no_try_catch - Catching errors in repository
  Future<User?> getUser(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      // BAD: Swallowing the error!
      return null;
    }
  }

  // VIOLATION: repository_no_try_catch - Another try/catch
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      // BAD: Returning empty list hides the error
      return [];
    }
  }

  // VIOLATION: repository_async_return - Synchronous public method
  User? getCachedUser() {
    // Public methods should return Future<T> or Stream<T>
    return null;
  }

  // VIOLATION: repository_async_return - Another sync method
  bool isLoggedIn() {
    return false;
  }

  // VIOLATION: repository_async_return - Returns void instead of Future<void>
  void clearCache() {
    // Should be Future<void> clearCache() async
  }
}

// VIOLATION: repository_class_restriction - Class name doesn't contain "Repository"
// Should be in models/ directory
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name']);
  }
}
