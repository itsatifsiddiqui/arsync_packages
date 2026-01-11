import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/shared_widget_purity.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SharedWidgetPurityTest);
  });
}

@reflectiveTest
class SharedWidgetPurityTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = SharedWidgetPurity();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideWidgets() async {
    await assertNoDiagnostics(r'''
class MyWidget {}
class AnotherWidget {}
''');
  }

  Future<void> test_validDartCode() async {
    await assertNoDiagnostics(r'''
class StatelessWidget {}

class MyWidget extends StatelessWidget {}
''');
  }
}
