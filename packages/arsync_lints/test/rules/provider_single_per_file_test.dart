import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/provider_single_per_file.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProviderSinglePerFileTest);
  });
}

@reflectiveTest
class ProviderSinglePerFileTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ProviderSinglePerFile();
    super.setUp();
  }

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    await assertNoDiagnostics(r'''
final provider1 = 1;
final provider2 = 2;
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
