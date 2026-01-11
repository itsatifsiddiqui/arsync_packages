import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/model_purity.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ModelPurityTest);
  });
}

@reflectiveTest
class ModelPurityTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ModelPurity();
    super.setUp();
  }

  // The rule only applies to files in lib/models/.
  // Since the test framework uses a default path outside this directory,
  // we verify the rule doesn't apply to files outside models/.

  Future<void> test_ruleDoesNotApplyOutsideModels() async {
    await assertNoDiagnostics(r'''
class User {
  final String name;
  User(this.name);
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
