// Example: GOOD - Persistent auth provider with ref.keepAlive()
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'persistent_auth_provider.freezed.dart';

// OK: State class is annotated with @freezed
@freezed
sealed class PersistentAuthState with _$PersistentAuthState {
  const factory PersistentAuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? error,
  }) = _PersistentAuthState;
}

// OK: Using autoDispose with .new syntax (no explicit generics)
// Provider name matches file name: persistent_auth_provider.dart -> persistentAuthProvider
final persistentAuthProvider = NotifierProvider.autoDispose(
  PersistentAuthNotifier.new,
);

class PersistentAuthNotifier extends Notifier<PersistentAuthState> {
  @override
  PersistentAuthState build() {
    // OK: Using ref.keepAlive() - explicit opt-in to persistence
    ref.keepAlive();
    return const PersistentAuthState();
  }
}
