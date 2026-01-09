// Example: Hook safety rule demonstrations

// Mock classes for example
class TextEditingController {}

class AnimationController {}

class ScrollController {}

class StatelessWidget {}

class BadHookExample extends StatelessWidget {
  void build() {
    // VIOLATION: hook_safety_enforcement
    // Creating controllers directly in build without hooks
    // ignore: unused_local_variable
    final controller = TextEditingController(); // LINT: hook_safety_enforcement
    // ignore: unused_local_variable
    final animation = AnimationController(); // LINT: hook_safety_enforcement
    // ignore: unused_local_variable
    final scroll = ScrollController(); // LINT: hook_safety_enforcement
  }
}

// In a real Flutter Hooks project, you would use:
// class GoodHookExample extends HookConsumerWidget {
//   Widget build(BuildContext context, WidgetRef ref) {
//     final controller = useTextEditingController(); // OK
//     final animation = useAnimationController(duration: Duration(seconds: 1)); // OK
//     return Container();
//   }
// }
