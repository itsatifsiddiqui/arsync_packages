import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/hook_safety_enforcement.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(HookSafetyEnforcementTest);
  });
}

@reflectiveTest
class HookSafetyEnforcementTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = HookSafetyEnforcement();
    super.setUp();
  }

  Future<void> test_good_noControllersInBuild() async {
    await assertNoDiagnostics(r'''
class Widget {}
class BuildContext {}

class MyWidget extends Widget {
  Widget build(BuildContext context) {
    return Widget();
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
