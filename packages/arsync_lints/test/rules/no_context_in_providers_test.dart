import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/no_context_in_providers.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoContextInProvidersTest);
  });
}

@reflectiveTest
class NoContextInProvidersTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoContextInProviders();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    await assertNoDiagnostics(r'''
class BuildContext {}

class MyClass {
  void doSomething(BuildContext context) {}
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
