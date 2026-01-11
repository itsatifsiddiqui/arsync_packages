import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/provider_class_restriction.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProviderClassRestrictionTest);
  });
}

@reflectiveTest
class ProviderClassRestrictionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ProviderClassRestriction();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    await assertNoDiagnostics(r'''
class Helper {}
class Utils {}
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
