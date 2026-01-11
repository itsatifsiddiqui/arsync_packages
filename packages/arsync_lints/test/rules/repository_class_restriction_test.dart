import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/repository_class_restriction.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryClassRestrictionTest);
  });
}

@reflectiveTest
class RepositoryClassRestrictionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryClassRestriction();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideRepositories() async {
    await assertNoDiagnostics(r'''
class UserService {}
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
