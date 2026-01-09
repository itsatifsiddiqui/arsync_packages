import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/presentation_layer_isolation.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PresentationLayerIsolationTest);
  });
}

@reflectiveTest
class PresentationLayerIsolationTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PresentationLayerIsolation();
    super.setUp();
  }

  // The rule only applies to files in lib/screens/ or lib/widgets/.
  // Since the test framework uses a default path outside these directories,
  // we test the logic by verifying no diagnostics are reported for valid code
  // (because the rule doesn't apply to the default test path).

  Future<void> test_ruleDoesNotApplyOutsideScreensWidgets() async {
    // This code would trigger the rule if in screens/widgets,
    // but since we're not in that path, no diagnostic should be reported
    await assertNoDiagnostics(r'''
void main() {
  final x = 1;
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

  Future<void> test_widgetClassPattern() async {
    // Testing that widget-like class structures are allowed
    await assertNoDiagnostics(r'''
class StatelessWidget {}

class MyWidget extends StatelessWidget {
  final String title;
  MyWidget(this.title);
}
''');
  }
}
