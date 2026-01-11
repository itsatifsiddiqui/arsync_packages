import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/provider_file_naming.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProviderFileNamingTest);
  });
}

@reflectiveTest
class ProviderFileNamingTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ProviderFileNaming();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    await assertNoDiagnostics(r'''
class AuthNotifier {}
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
