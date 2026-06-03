// Example: BAD - Hardcoded colors in regular files trigger the lint
//
// This file is NOT exempt (no 'theme', 'color', or 'palette' in filename)
// so hardcoded colors will trigger avoid_hardcoded_color lint.

// Mock Flutter types for demonstration
class Widget {}

class StatelessWidget extends Widget {}

class BuildContext {}

class Color {
  final int value;
  const Color(this.value);
  const Color.fromARGB(int a, int r, int g, int b) : value = 0;
}

class Colors {
  static const red = Color(0xFFFF0000);
  static const black = Color(0xFF000000);
}

/// Test screen that should trigger avoid_hardcoded_color lint
/// because this is NOT a theme/color/palette file.
class TestHardcodedColorScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    // VIOLATION: avoid_hardcoded_color - Direct Color constructor
    // ignore: unused_local_variable
    final backgroundColor = Color(0xFF2196F3);

    // VIOLATION: avoid_hardcoded_color - Colors class usage
    // ignore: unused_local_variable
    final textColor = Colors.red;

    // VIOLATION: avoid_hardcoded_color - Color.fromARGB
    // ignore: unused_local_variable
    final customColor = Color.fromARGB(255, 0, 0, 0);

    return Widget();
  }
}
