// Example: GOOD - Color definition files are exempt from avoid_hardcoded_color
//
// Files with 'color' in their name can use hardcoded colors because they
// define the color palette for the application.

// Mock Flutter types for demonstration
class Color {
  final int value;

  const Color(this.value);
  const Color.fromARGB(int a, int r, int g, int b) : value = 0;
  const Color.fromRGBO(int r, int g, int b, double opacity) : value = 0;
}

class Colors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

/// App color definitions with hardcoded colors.
/// NO LINT - This file is exempt from avoid_hardcoded_color lint
/// because 'color' is in the file name.
class AppColors {
  // Brand colors - All ALLOWED because filename contains 'color'
  static const Color primaryBlue = Color(0xFF2196F3); // ✓ Allowed
  static const Color secondaryOrange = Color(0xFFFF9800); // ✓ Allowed

  // Status colors
  static const Color successGreen = Color(0xFF4CAF50); // ✓ Allowed
  static const Color warningYellow = Color(0xFFFFC107); // ✓ Allowed
  static const Color errorRed = Color(0xFFF44336); // ✓ Allowed

  // Using Colors class
  static const Color white = Colors.white; // ✓ Allowed
  static const Color black = Colors.black; // ✓ Allowed

  // Using Color methods
  static const Color customColor = Color.fromARGB(255, 100, 150, 200); // ✓ Allowed
  static const Color customColor2 = Color.fromRGBO(100, 150, 200, 0.5); // ✓ Allowed
}
