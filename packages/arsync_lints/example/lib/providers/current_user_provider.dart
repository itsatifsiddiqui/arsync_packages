// Example: GOOD - Derived provider for current user
import 'package:riverpod/riverpod.dart';

import 'auth_notifier_provider.dart';

// OK: Provider for current user with autoDispose
// Provider name matches file name: current_user_provider.dart -> currentUserProvider
final currentUserProvider = Provider.autoDispose<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});
