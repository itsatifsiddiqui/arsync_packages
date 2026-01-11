import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/repository_provider_declaration.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryProviderDeclarationTest);
  });
}

@reflectiveTest
class RepositoryProviderDeclarationTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryProviderDeclaration();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideRepositories() async {
    await assertNoDiagnostics(r'''
class UserRepository {}
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
