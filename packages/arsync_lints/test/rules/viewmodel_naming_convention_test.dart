import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/viewmodel_naming_convention.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ViewModelNamingConventionTest);
  });
}

@reflectiveTest
class ViewModelNamingConventionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ViewModelNamingConvention();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    await assertNoDiagnostics(r'''
class Notifier<T> {}

class AuthViewModel extends Notifier<String> {}
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
