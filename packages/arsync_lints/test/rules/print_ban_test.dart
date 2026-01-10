import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/print_ban.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrintBanTest);
  });
}

@reflectiveTest
class PrintBanTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PrintBan();
    super.setUp();
  }

  Future<void> test_good_noprint() async {
    await assertNoDiagnostics(r'''
void main() {
  final message = 'Hello';
}
''');
  }

  Future<void> test_good_customLog() async {
    await assertNoDiagnostics(r'''
void main() {
  log('Hello');
}

void log(String message) {}
''');
  }

  Future<void> test_bad_print() async {
    await assertDiagnostics(r'''
void main() {
  print('Hello');
}
''', [lint(16, 14)]);
  }

  Future<void> test_bad_debugPrint() async {
    await assertDiagnostics(r'''
void debugPrint(String message) {}

void main() {
  debugPrint('Hello');
}
''', [lint(52, 19)]);
  }

  Future<void> test_bad_multiplePrints() async {
    await assertDiagnostics(r'''
void main() {
  print('First');
  print('Second');
}
''', [lint(16, 14), lint(34, 15)]);
  }

  Future<void> test_ignore_single_line() async {
    await assertNoDiagnostics(r'''
void main() {
  // ignore: print_ban
  print('Hello');
}
''');
  }

  Future<void> test_ignore_for_file() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: print_ban
void main() {
  print('Hello');
  print('World');
}
''');
  }

  Future<void> test_ignore_partial() async {
    // First print is ignored, second is not
    await assertDiagnostics(r'''
void main() {
  // ignore: print_ban
  print('Hello');
  print('World');
}
''', [lint(57, 14)]);
  }

  Future<void> test_ignore_multiple_lints() async {
    await assertNoDiagnostics(r'''
void main() {
  // ignore: other_lint, print_ban, another
  print('Hello');
}
''');
  }
}
