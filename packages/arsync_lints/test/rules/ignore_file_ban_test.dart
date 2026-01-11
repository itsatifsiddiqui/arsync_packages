import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/ignore_file_ban.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(IgnoreFileBanTest);
  });
}

@reflectiveTest
class IgnoreFileBanTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = IgnoreFileBan();
    super.setUp();
  }

  Future<void> test_good_noIgnoreForFile() async {
    await assertNoDiagnostics(r'''
class MyClass {
  void doSomething() {}
}
''');
  }

  Future<void> test_good_lineIgnoreAllowed() async {
    await assertNoDiagnostics(r'''
// ignore: some_rule
void main() {}
''');
  }
}
