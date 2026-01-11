import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/complexity_limits.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ComplexityLimitsTest);
  });
}

@reflectiveTest
class ComplexityLimitsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ComplexityLimits();
    super.setUp();
  }

  Future<void> test_good_manyParameters() async {
    // Parameter count is no longer limited
    await assertNoDiagnostics(r'''
void doSomething(String a, int b, bool c, double d, String e, int f) {}
''');
  }

  Future<void> test_bad_nestedTernary() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  final value = a ? 'first' : b ? 'second' : 'third';
}
''',
      [lint(44, 36)],
    );
  }

  Future<void> test_good_shortMethod() async {
    await assertNoDiagnostics(r'''
class MyClass {
  void shortMethod() {
    final a = 1;
    final b = 2;
    final c = 3;
  }
}
''');
  }
}
