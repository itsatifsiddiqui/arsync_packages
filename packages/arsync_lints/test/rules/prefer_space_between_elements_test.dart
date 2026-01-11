import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/prefer_space_between_elements.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferSpaceBetweenElementsTest);
  });
}

@reflectiveTest
class PreferSpaceBetweenElementsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferSpaceBetweenElements();
    super.setUp();
  }

  Future<void> test_good_properSpacing() async {
    await assertNoDiagnostics(r'''
class Widget {}

class MyWidget extends Widget {
  final String title;

  MyWidget(this.title);

  Widget build(dynamic context) {
    return Widget();
  }
}
''');
  }

  Future<void> test_good_noFields() async {
    await assertNoDiagnostics(r'''
class Widget {}

class MyWidget extends Widget {
  Widget build(dynamic context) {
    return Widget();
  }
}
''');
  }

  Future<void> test_bad_noSpaceBetweenFieldAndConstructor() async {
    await assertDiagnostics(r'''
class Widget {}

class MyWidget extends Widget {
  final String title;
  MyWidget(this.title);

  Widget build(dynamic context) {
    return Widget();
  }
}
''', [lint(73, 21)]);
  }

  Future<void> test_bad_noSpaceBetweenConstructorAndBuild() async {
    await assertDiagnostics(r'''
class Widget {}

class MyWidget extends Widget {
  final String title;

  MyWidget(this.title);
  Widget build(dynamic context) {
    return Widget();
  }
}
''', [lint(98, 56)]);
  }

  Future<void> test_bad_noSpaceBetweenFieldAndBuild() async {
    await assertDiagnostics(r'''
class Widget {}

class MyWidget extends Widget {
  final String title = 'Hello';
  Widget build(dynamic context) {
    return Widget();
  }
}
''', [lint(83, 56)]);
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: prefer_space_between_elements

class Widget {}

class MyWidget extends Widget {
  final String title;
  MyWidget(this.title);
  Widget build(dynamic context) {
    return Widget();
  }
}
''');
  }
}
