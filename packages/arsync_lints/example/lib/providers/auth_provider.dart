// Example: Proper auth provider file
// This file demonstrates the recommended structure for an auth provider

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_provider.freezed.dart';

// OK: State class is annotated with @freezed and defined in the same file
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    String? userId,
    String? error,
  }) = _AuthState;
}

// OK: Using autoDispose
final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);

// OK: Notifier class ends with "Notifier" - satisfies viewmodel_naming_convention
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  // OK: Async method wrapped in try/catch
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(error: null);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isAuthenticated: true, userId: 'user_123');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
