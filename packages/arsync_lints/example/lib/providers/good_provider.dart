// Example: GOOD - This file demonstrates correct provider usage
// Each provider file contains ONE NotifierProvider matching the file name
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'good_provider.freezed.dart';

// OK: State class is annotated with @freezed and defined in the same file
@freezed
sealed class GoodState with _$GoodState {
  const factory GoodState({
    @Default(0) int count,
    @Default(false) bool isLoading,
  }) = _GoodState;
}

// OK: Provider name matches file name (good_provider.dart -> goodProvider)
// OK: Using autoDispose with .new syntax (no explicit generics)
final goodProvider = NotifierProvider.autoDispose(GoodNotifier.new);

// OK: Class name ends with "Notifier" and matches provider
class GoodNotifier extends AutoDisposeNotifier<GoodState> {
  @override
  GoodState build() => const GoodState();

  void increment() => state = state.copyWith(count: state.count + 1);

  void decrement() => state = state.copyWith(count: state.count - 1);

  Future<void> reset() async {
    state = state.copyWith(isLoading: true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      state = const GoodState();
    } catch (e, _) {
      state = state.copyWith(isLoading: false);
    }
  }
}
