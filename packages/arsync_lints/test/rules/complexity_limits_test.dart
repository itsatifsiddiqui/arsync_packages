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

  Future<void> test_good_fourParameters() async {
    await assertNoDiagnostics(r'''
void doSomething(String a, int b, bool c, double d) {}
''');
  }

  Future<void> test_bad_fiveParameters() async {
    await assertDiagnostics(r'''
void doSomething(String a, int b, bool c, double d, String e) {}
''', [lint(16, 45)]);
  }

  Future<void> test_bad_sixParameters() async {
    await assertDiagnostics(r'''
void updateProfile(
  String userId,
  String name,
  String email,
  String phone,
  String address,
  String city,
) {}
''', [lint(18, 100)]);
  }

  Future<void> test_bad_nestedTernary() async {
    await assertDiagnostics(r'''
void test(bool a, bool b) {
  final value = a ? 'first' : b ? 'second' : 'third';
}
''', [lint(44, 36)]);
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
