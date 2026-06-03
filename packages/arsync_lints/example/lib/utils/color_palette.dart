// Example: GOOD - Palette files are exempt from avoid_hardcoded_color
//
// Files with 'palette' in their name can use hardcoded colors because they
// define the color palette for the application.

// Mock Flutter types for demonstration
class Color {
  final int value;

  const Color(this.value);
}

class Colors {
  static const blue = Color(0xFF2196F3);
}

class MaterialColor extends Color {
  final Map<int, Color> swatch;

  const MaterialColor(int value, this.swatch) : super(value);
}

/// Color palette definitions with hardcoded colors.
/// NO LINT - This file is exempt from avoid_hardcoded_color lint
/// because 'palette' is in the file name.
class ColorPalette {
  // Material Design color palette - All ALLOWED because filename contains 'palette'
  static const MaterialColor brandColor = MaterialColor(
    0xFF2196F3, // ✓ Allowed
    <int, Color>{
      50: Color(0xFFE3F2FD), // ✓ Allowed
      100: Color(0xFFBBDEFB), // ✓ Allowed
      200: Color(0xFF90CAF9), // ✓ Allowed
      300: Color(0xFF64B5F6), // ✓ Allowed
      400: Color(0xFF42A5F5), // ✓ Allowed
      500: Color(0xFF2196F3), // ✓ Allowed
      600: Color(0xFF1E88E5), // ✓ Allowed
      700: Color(0xFF1976D2), // ✓ Allowed
      800: Color(0xFF1565C0), // ✓ Allowed
      900: Color(0xFF0D47A1), // ✓ Allowed
    },
  );

  // Gradient colors
  static final List<Color> gradientColors = [
    Color(0xFF2196F3), // ✓ Allowed
    Color(0xFF1976D2), // ✓ Allowed
    Colors.blue, // ✓ Allowed
  ];
}
