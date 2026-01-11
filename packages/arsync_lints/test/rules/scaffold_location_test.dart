import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/scaffold_location.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ScaffoldLocationTest);
  });
}

@reflectiveTest
class ScaffoldLocationTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ScaffoldLocation();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideWidgets() async {
    await assertNoDiagnostics(r'''
class Scaffold {}

class MyWidget {
  Scaffold build() => Scaffold();
}
''');
  }

  Future<void> test_validDartCode() async {
    await assertNoDiagnostics(r'''
class MyClass {
  void doSomething() {}
}
''');
  }
}
