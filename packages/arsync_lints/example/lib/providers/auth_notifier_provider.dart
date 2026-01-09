// Example: GOOD - Auth provider with proper structure
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_notifier_provider.freezed.dart';

// OK: State class is annotated with @freezed and defined in the same file
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? user,
    String? error,
  }) = _AuthState;
}

// OK: User model is also freezed (used as part of state)
@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;
}

// OK: Using autoDispose with .new syntax (no explicit generics)
// Provider name matches file name: auth_notifier_provider.dart -> authNotifierProvider
final authNotifierProvider = NotifierProvider.autoDispose(AuthNotifier.new);

// OK: Provider name ends with "Provider", Class name ends with "Notifier"
class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  // OK: No BuildContext parameter - UI-agnostic
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // OK: Wrapped in try/catch
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final user = User(id: '1', name: 'Test User', email: email);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e, _) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      // In real app: use a logger from utils/ or services/
    }
  }

  Future<void> logout() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = const AuthState();
    } catch (e, _) {
      state = state.copyWith(error: e.toString());
    }
  }
}
