// Example: GOOD - Asset path constants
/// Centralized image asset paths.
///
/// Using constants prevents typos and enables compile-time checking.
/// If an asset is renamed or removed, you only need to update it here.
abstract class Images {
  Images._();

  // App icons
  static const String appIcon = 'assets/icons/app_icon.png';
  static const String appLogo = 'assets/images/logo.png';

  // Generic aliases for common usage
  static const String logo = appLogo;
  static const String icon = appIcon;

  // Default images
  static const String defaultAvatar = 'assets/images/default_avatar.png';
  static const String placeholder = 'assets/images/placeholder.png';

  // Status icons
  static const String errorIcon = 'assets/icons/error.png';
  static const String successIcon = 'assets/icons/success.png';
  static const String warningIcon = 'assets/icons/warning.png';

  // Navigation icons
  static const String homeIcon = 'assets/icons/home.png';
  static const String profileIcon = 'assets/icons/profile.png';
  static const String settingsIcon = 'assets/icons/settings.png';

  // Illustrations
  static const String emptyState = 'assets/illustrations/empty.png';
  static const String onboarding1 = 'assets/illustrations/onboarding_1.png';
  static const String onboarding2 = 'assets/illustrations/onboarding_2.png';
}
