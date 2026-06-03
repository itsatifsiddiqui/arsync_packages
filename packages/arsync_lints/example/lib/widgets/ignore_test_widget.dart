// Test file for ignore comment functionality
// ignore_for_file: arsync_lints/file_class_match

// ignore: arsync_lints/shared_widget_purity
import 'package:riverpod/riverpod.dart';

// Mock Flutter types
class Widget {}

class StatelessWidget extends Widget {}

class BuildContext {}

class Scaffold extends Widget {}

// Global variable - should be suppressed by ignore_for_file
String testGlobal = 'test';

// Test: Single line ignore on scaffold
class IgnoreTestWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // ignore: arsync_lints/scaffold_location
    return Scaffold();
  }
}

// Test: Second widget with ignore
// ignore: arsync_lints/shared_widget_purity
class AnotherWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Widget();
  }
}
