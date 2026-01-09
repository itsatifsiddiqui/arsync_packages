// Example: BAD - This file demonstrates violations in providers
import 'package:riverpod/riverpod.dart';

// Mock BuildContext for demonstration
class BuildContext {}

// VIOLATION: provider_autodispose_enforcement - Missing autoDispose
// VIOLATION: provider_declaration_syntax - Should use .new syntax without generics
final badAuthProvider = NotifierProvider<BadAuthNotifier, AuthState>(() {
  return BadAuthNotifier();
});

// VIOLATION: viewmodel_naming_convention - Should end with "Notifier"
class BadAuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  // VIOLATION: no_context_in_providers - BuildContext in provider
  void showMessage(BuildContext context, String message) {
    // UI logic in provider - BAD!
  }

  // VIOLATION: async_viewmodel_safety - No try/catch around await
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    // This await is not wrapped in try/catch
    final user = await _mockLogin(email, password);

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: user,
    );
  }

  // VIOLATION: async_viewmodel_safety - Multiple awaits without try/catch
  Future<void> fetchUserData() async {
    // ignore: unused_local_variable
    final profile = await _mockFetch('profile');
    // ignore: unused_local_variable
    final settings = await _mockFetch('settings');
    // No error handling!
  }

  // Mock methods for demonstration
  Future<User> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return User('1', 'Test User');
  }

  Future<String> _mockFetch(String type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return type;
  }
}

// Another bad notifier example
class BadAuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }
}

// VIOLATION: provider_state_class - State class must be annotated with @freezed
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
    );
  }
}

// VIOLATION: provider_class_restriction - Plain classes not allowed in providers
// This should be a @freezed class or moved to models/
class User {
  final String id;
  final String name;
  User(this.id, this.name);
}
