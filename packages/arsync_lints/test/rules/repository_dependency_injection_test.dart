import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/repository_dependency_injection.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryDependencyInjectionTest);
  });
}

@reflectiveTest
class RepositoryDependencyInjectionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryDependencyInjection();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideRepositories() async {
    await assertNoDiagnostics(r'''
class UserRepository {
  final client = Object();
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
