import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/prefer_dedicated_media_query_methods.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferDedicatedMediaQueryMethodsTest);
  });
}

@reflectiveTest
class PreferDedicatedMediaQueryMethodsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferDedicatedMediaQueryMethods();
    super.setUp();
  }

  Future<void> test_good_sizeOf() async {
    await assertNoDiagnostics(r'''
// Mock types
class Size {
  final double width;
  final double height;
  const Size(this.width, this.height);
}

class MediaQuery {
  static Size sizeOf(dynamic context) => Size(100, 100);
  static double widthOf(dynamic context) => 100;
  static double heightOf(dynamic context) => 100;
}

void main(dynamic context) {
  final size = MediaQuery.sizeOf(context);
}
''');
  }

  Future<void> test_good_widthOf() async {
    await assertNoDiagnostics(r'''
// Mock types
class MediaQuery {
  static double widthOf(dynamic context) => 100;
}

void main(dynamic context) {
  final width = MediaQuery.widthOf(context);
}
''');
  }

  Future<void> test_bad_mediaQueryOf() async {
    await assertDiagnostics(r'''
// Mock types
class Size {
  final double width;
  const Size(this.width);
}

class MediaQueryData {
  final Size size;
  const MediaQueryData({required this.size});
}

class MediaQuery {
  static MediaQueryData of(dynamic context) => MediaQueryData(size: Size(100));
}

void main(dynamic context) {
  final data = MediaQuery.of(context);
}
''', [lint(315, 22)]);
  }

  Future<void> test_bad_mediaQueryMaybeOf() async {
    await assertDiagnostics(r'''
// Mock types
class Size {
  final double width;
  const Size(this.width);
}

class MediaQueryData {
  final Size size;
  const MediaQueryData({required this.size});
}

class MediaQuery {
  static MediaQueryData? maybeOf(dynamic context) => null;
}

void main(dynamic context) {
  final data = MediaQuery.maybeOf(context);
}
''', [lint(294, 27)]);
  }

  Future<void> test_bad_sizeOfWidth() async {
    await assertDiagnostics(r'''
// Mock types
class Size {
  final double width;
  final double height;
  const Size(this.width, this.height);
}

class MediaQuery {
  static Size sizeOf(dynamic context) => Size(100, 100);
}

void main(dynamic context) {
  final width = MediaQuery.sizeOf(context).width;
}
''', [lint(238, 32)]);
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: prefer_dedicated_media_query_methods

// Mock types
class MediaQueryData {}

class MediaQuery {
  static MediaQueryData of(dynamic context) => MediaQueryData();
}

void main(dynamic context) {
  final data = MediaQuery.of(context);
}
''');
  }
}
