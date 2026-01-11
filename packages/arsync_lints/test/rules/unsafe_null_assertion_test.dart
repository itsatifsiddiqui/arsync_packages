import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/unsafe_null_assertion.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnsafeNullAssertionTest);
  });
}

@reflectiveTest
class UnsafeNullAssertionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UnsafeNullAssertion();
    super.setUp();
  }

  Future<void> test_good_nullCoalescing() async {
    await assertNoDiagnostics(r'''
String getValue(String? name) {
  return name ?? 'default';
}
''');
  }

  Future<void> test_good_nullAwareAccess() async {
    await assertNoDiagnostics(r'''
class User {
  String? name;
}

String? getName(User? user) {
  return user?.name;
}
''');
  }

  Future<void> test_good_localVariable() async {
    await assertNoDiagnostics(r'''
void main() {
  final value = 5;
  print(value);
}
''');
  }

  Future<void> test_bad_forceNullAssertion() async {
    await assertDiagnostics(
      r'''
String getValue(String? name) {
  return name!;
}
''',
      [lint(41, 5)],
    );
  }

  Future<void> test_bad_forceNullAssertionOnMember() async {
    await assertDiagnostics(
      r'''
class User {
  String name = '';
}

String getName(User? user) {
  return user!.name;
}
''',
      [lint(74, 5)],
    );
  }

  Future<void> test_bad_multipleNullAssertions() async {
    await assertDiagnostics(
      r'''
String combine(String? a, String? b) {
  return a! + b!;
}
''',
      [lint(48, 2), lint(53, 2)],
    );
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: unsafe_null_assertion

String getValue(String? name) {
  return name!;
}
''');
  }
}
