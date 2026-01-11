// Example: GOOD - Constants file with k-prefixed variables

/// Application-wide constants.
///
/// All constants must start with 'k' prefix as per arsync_lints rules.
/// This file is the only place where k-prefixed top-level variables are allowed.

// Mock Color class for pure Dart example
class Color {
  final int value;
  const Color(this.value);
}

// OK: Class name matches file name
class Constants {
  Constants._();
}

// Animation durations
const kAnimationDurationFast = Duration(milliseconds: 150);
const kAnimationDurationNormal = Duration(milliseconds: 300);
const kAnimationDurationSlow = Duration(milliseconds: 500);

// Spacing
const kSpacingXS = 4.0;
const kSpacingS = 8.0;
const kSpacingM = 16.0;
const kSpacingL = 24.0;
const kSpacingXL = 32.0;

// Border radius
const kBorderRadiusS = 4.0;
const kBorderRadiusM = 8.0;
const kBorderRadiusL = 16.0;
const kBorderRadiusXL = 24.0;

// Colors (using mock Color class)
const kPrimaryColor = Color(0xFF6200EE);
const kSecondaryColor = Color(0xFF03DAC6);
const kErrorColor = Color(0xFFB00020);
const kBackgroundColor = Color(0xFFFAFAFA);

// API configuration
const kApiBaseUrl = 'https://api.example.com';
const kApiVersion = 'v1';
const kApiTimeout = Duration(seconds: 30);

// Pagination
const kDefaultPageSize = 20;
const kMaxPageSize = 100;

// Validation
const kMinPasswordLength = 8;
const kMaxUsernameLength = 30;

// Feature flags (compile-time constants)
const kEnableAnalytics = true;
const kEnableDebugMode = false;
const kEnableCrashReporting = true;
