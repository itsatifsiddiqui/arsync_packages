import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/global_variable_restriction.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(GlobalVariableRestrictionTest);
  });
}

@reflectiveTest
class GlobalVariableRestrictionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = GlobalVariableRestriction();
    super.setUp();
  }

  Future<void> test_good_privateVariable() async {
    await assertNoDiagnostics(r'''
final _privateVar = 'value';
''');
  }

  Future<void> test_good_classMembers() async {
    // Class members are not top-level variables
    await assertNoDiagnostics(r'''
class Config {
  static const apiUrl = 'https://api.example.com';
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
