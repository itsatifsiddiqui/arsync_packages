import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/barrel_file_restriction.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(BarrelFileRestrictionTest);
  });
}

@reflectiveTest
class BarrelFileRestrictionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = BarrelFileRestriction();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyToNonIndexFile() async {
    // Rule only applies to index.dart files in specific directories
    await assertNoDiagnostics(r'''
class MyWidget {}
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
