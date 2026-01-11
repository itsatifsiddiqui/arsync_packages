import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/async_viewmodel_safety.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AsyncViewModelSafetyTest);
  });
}

@reflectiveTest
class AsyncViewModelSafetyTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AsyncViewModelSafety();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    await assertNoDiagnostics(r'''
class MyClass {
  Future<void> doSomething() async {
    await Future.delayed(Duration(seconds: 1));
  }
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
