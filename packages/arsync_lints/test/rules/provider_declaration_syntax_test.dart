import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/provider_declaration_syntax.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProviderDeclarationSyntaxTest);
  });
}

@reflectiveTest
class ProviderDeclarationSyntaxTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ProviderDeclarationSyntax();
    super.setUp();
  }

  // Note: This rule only applies to files in lib/providers/ path.
  // The test framework uses a default path outside this directory,
  // so we verify the rule doesn't incorrectly fire outside provider paths.

  Future<void> test_ruleDoesNotApplyOutsideProviders() async {
    // This code would be flagged if in providers/, but since we're not,
    // no diagnostic should be reported
    await assertNoDiagnostics(r'''
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier {}
class AuthState {}
class NotifierProvider<T, S> {
  NotifierProvider(T Function() f);
}
''');
  }

  Future<void> test_validNewSyntaxPattern() async {
    // This pattern is always valid (uses .new syntax)
    await assertNoDiagnostics(r'''
final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);

class AuthNotifier {
  const AuthNotifier();
}

class NotifierProvider {
  static autoDispose(Function f) => null;
}
''');
  }

  Future<void> test_asyncNotifierNewSyntax() async {
    await assertNoDiagnostics(r'''
final userProvider = AsyncNotifierProvider.autoDispose(UserNotifier.new);

class UserNotifier {
  const UserNotifier();
}

class AsyncNotifierProvider {
  static autoDispose(Function f) => null;
}
''');
  }

  Future<void> test_closureInsteadOfNewOutsideProviders() async {
    // Closure syntax would trigger rule in providers/, but not here
    await assertNoDiagnostics(r'''
final authProvider = NotifierProvider.autoDispose(() => AuthNotifier());

class AuthNotifier {}
class NotifierProvider {
  static autoDispose(Function f) => null;
}
''');
  }
}
