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

  Future<void> test_good_nestingDepth_nestedIfWithClosure() async {
    // Nesting depth: if (1) -> if (2) -> closure (3) = 3 levels, not 6
    await assertNoDiagnostics(r'''
class MyClass {
  void didChangeMetrics() {
    final isVisibleNow = true;
    final _isKeyboardVisible = false;
    final rebuildOnChange = true;

    if (isVisibleNow != _isKeyboardVisible) {
      final x = 1;

      if (rebuildOnChange) {
        setState(() {});
      }
    }
  }

  void setState(Function fn) {}
}
''');
  }

  Future<void> test_good_nestingDepth_fiveLevels() async {
    // Exactly 5 levels of nesting should be allowed
    await assertNoDiagnostics(r'''
void test() {
  if (true) {           // Level 1
    if (true) {         // Level 2
      if (true) {       // Level 3
        if (true) {     // Level 4
          if (true) {   // Level 5
            final x = 1;
          }
        }
      }
    }
  }
}
''');
  }

  Future<void> test_bad_nestingDepth_sixLevels() async {
    // 6 levels of nesting should trigger the lint
    await assertDiagnostics(
      r'''
void test() {
  if (true) {           // Level 1
    if (true) {         // Level 2
      if (true) {       // Level 3
        if (true) {     // Level 4
          if (true) {   // Level 5
            if (true) { // Level 6 - ERROR
              final x = 1;
            }
          }
        }
      }
    }
  }
}
''',
      [lint(211, 61)], // The innermost block
    );
  }

  Future<void> test_good_nestingDepth_closureInsideLoop() async {
    // for (1) -> if (2) -> closure (3) = 3 levels
    await assertNoDiagnostics(r'''
void test() {
  final list = [1, 2, 3];
  for (int i = 0; i < 10; i++) {
    if (i > 5) {
      list.forEach((item) {
        final x = item;
      });
    }
  }
}
''');
  }
}
