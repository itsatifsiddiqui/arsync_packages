import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/file_class_match.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FileClassMatchTest);
  });
}

@reflectiveTest
class FileClassMatchTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FileClassMatch();
    super.setUp();
  }

  Future<void> test_good_noClasses() async {
    // Files without classes don't trigger the rule
    await assertNoDiagnostics(r'''
void main() {
  final x = 1;
}
''');
  }

  Future<void> test_good_functionOnly() async {
    await assertNoDiagnostics(r'''
void helper() {}
''');
  }
}
