// Example: BAD - This file demonstrates violations in widgets

// VIOLATION: shared_widget_purity - Importing providers in widgets
import 'package:riverpod/riverpod.dart';
import '../providers/auth_provider.dart';

// VIOLATION: presentation_layer_isolation - Importing data layer
import 'package:dio/dio.dart';
import '../repositories/user_repository.dart';

// Mock Flutter types
class Widget {}
class StatelessWidget extends Widget {}
class BuildContext {}
class Scaffold extends Widget {}
class Card extends Widget {}
class Image {
  Image.asset(String path);
}

// VIOLATION: scaffold_location - Scaffold not allowed in widgets folder
class BadCardWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // VIOLATION: scaffold_location - Scaffold in widgets folder
    return Scaffold();
  }
}

// VIOLATION: global_variable_restriction - Non-private top-level variable
String widgetTitle = 'Bad Widget';
int widgetCounter = 0;

class AnotherBadWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // VIOLATION: asset_safety - String literal in Image.asset
    Image.asset('assets/images/logo.png');
    Image.asset('assets/icons/home.svg');
    return Widget();
  }
}
