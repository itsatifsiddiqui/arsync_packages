// Example: GOOD - Theme files are exempt from avoid_hardcoded_color
//
// Files with 'theme', 'color', or 'palette' in their name can use hardcoded
// colors because they define the color scheme for the application.

// Mock Flutter types for demonstration
class Color {
  final int value;

  const Color(this.value);
  const Color.fromARGB(int a, int r, int g, int b) : value = 0;
}

class Colors {
  static const blue = Color(0xFF2196F3);
  static const orange = Color(0xFFFF9800);
  static const deepOrange = Color(0xFFFF5722);
}

class ThemeData {
  final Color? primaryColor;
  final ColorScheme? colorScheme;

  const ThemeData({this.primaryColor, this.colorScheme});
}

class ColorScheme {
  final Color primary;
  final Color secondary;
  final Color error;
  final Color surface;

  const ColorScheme.light({
    required this.primary,
    required this.secondary,
    required this.error,
    required this.surface,
  });

  const ColorScheme.dark({
    required this.primary,
    required this.secondary,
    required this.error,
    required this.surface,
  });
}

/// App theme definitions with hardcoded colors.
/// NO LINT - This file is exempt from avoid_hardcoded_color lint
/// because 'theme' is in the file name.
class AppTheme {
  // These hardcoded colors are ALLOWED because filename contains 'theme'
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF2196F3), // ✓ Allowed
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3), // ✓ Allowed
      secondary: Colors.orange, // ✓ Allowed
      error: Color(0xFFB00020), // ✓ Allowed
      surface: Color(0xFFFFFFFF), // ✓ Allowed
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Color(0xFF1976D2), // ✓ Allowed
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF1976D2), // ✓ Allowed
      secondary: Colors.deepOrange, // ✓ Allowed
      error: Color(0xFFCF6679), // ✓ Allowed
      surface: Color(0xFF121212), // ✓ Allowed
    ),
  );
}
