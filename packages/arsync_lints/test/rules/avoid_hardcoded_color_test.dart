import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/avoid_hardcoded_color.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidHardcodedColorTest);
  });
}

@reflectiveTest
class AvoidHardcodedColorTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidHardcodedColor();
    super.setUp();
  }

  Future<void> test_good_noColor() async {
    await assertNoDiagnostics(r'''
void main() {
  final x = 5;
}
''');
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: avoid_hardcoded_color

class Color {
  final int value;
  const Color(this.value);
}

void main() {
  final color = Color(0xFF00FF00);
}
''');
  }
}
