import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/repository_no_try_catch.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryNoTryCatchTest);
  });
}

@reflectiveTest
class RepositoryNoTryCatchTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryNoTryCatch();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideRepositories() async {
    await assertNoDiagnostics(r'''
class MyClass {
  void doSomething() {
    try {
      print('hello');
    } catch (e) {
      print(e);
    }
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
