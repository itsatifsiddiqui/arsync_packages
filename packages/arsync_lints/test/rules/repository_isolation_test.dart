import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/repository_isolation.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryIsolationTest);
  });
}

@reflectiveTest
class RepositoryIsolationTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryIsolation();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideRepositories() async {
    await assertNoDiagnostics(r'''
class UserRepository {
  void fetch() {}
}
''');
  }

  Future<void> test_validDartCode() async {
    await assertNoDiagnostics(r'''
class MyClass {
  final String name;
  MyClass(this.name);
}
''');
  }
}
