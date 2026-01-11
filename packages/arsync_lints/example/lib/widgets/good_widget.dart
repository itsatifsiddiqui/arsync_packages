// Example: GOOD - This file demonstrates correct widget usage

// OK: Only importing utility constants - no providers, no repositories
import '../utils/images.dart';

// Mock Flutter types
class Widget {
  const Widget();
}

class StatelessWidget extends Widget {
  const StatelessWidget();
}

class BuildContext {}

class Card extends Widget {
  const Card();
}

class Image {
  const Image.asset(String path);
}

// OK: Private top-level variables are allowed
// ignore: unused_element
const _kDefaultPadding = 16.0;
// ignore: unused_element
const _kBorderRadius = 8.0;

// OK: Class name matches file name - satisfies file_class_match
class GoodWidget extends StatelessWidget {
  Widget build(BuildContext context) => Widget();
}

/// A reusable user card widget.
///
/// This widget is "pure" - it receives all data through parameters
/// and has no knowledge of business logic or state management.
class UserCard extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final void Function()? onTap;
  final bool isSelected;

  const UserCard({
    required this.userName,
    this.avatarUrl,
    this.onTap,
    this.isSelected = false,
  });

  Widget build(BuildContext context) {
    // OK: No Scaffold - this is a fragment widget
    // OK: Using Images constants instead of string literals
    Image.asset(Images.defaultAvatar);
    return Card();
  }
}

/// A reusable error message widget.
class ErrorMessage extends StatelessWidget {
  final String message;
  final void Function()? onRetry;

  const ErrorMessage({required this.message, this.onRetry});

  Widget build(BuildContext context) {
    // OK: Using constant from Images class
    Image.asset(Images.errorIcon);
    return Widget();
  }
}
