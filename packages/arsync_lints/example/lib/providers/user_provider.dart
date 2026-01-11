// Example: Proper user provider file
// This file demonstrates a simple user state provider

import 'package:riverpod/riverpod.dart';

/// Simple User model for this provider
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});
}

/// User profile state
class UserState {
  final User? currentUser;
  final bool isLoading;
  final String? error;

  const UserState({this.currentUser, this.isLoading = false, this.error});

  UserState copyWith({User? currentUser, bool? isLoading, String? error}) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// OK: Using autoDispose
final userProvider = NotifierProvider.autoDispose<UserNotifier, UserState>(() {
  return UserNotifier();
});

// OK: Class name matches file name (UserProvider) - satisfies file_class_match
class UserProvider {
  // This class exists to satisfy file_class_match rule
}

// OK: Notifier class ends with "Notifier" - satisfies viewmodel_naming_convention
class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    return const UserState();
  }

  // OK: Async operation wrapped in try/catch
  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final user = User(id: '1', name: 'Test User', email: 'test@example.com');
      state = state.copyWith(currentUser: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // OK: Async operation wrapped in try/catch
  Future<void> updateProfile(String name, String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final user = User(id: '1', name: name, email: email);
      state = state.copyWith(currentUser: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
