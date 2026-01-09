import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule C1: repository_no_try_catch
///
/// Repositories must throw errors to the ViewModel, not swallow them.
class RepositoryNoTryCatch extends DartLintRule {
  const RepositoryNoTryCatch() : super(code: _code);

  static const _code = LintCode(
    name: 'repository_no_try_catch',
    problemMessage:
        'Repositories must throw errors, not swallow them with try/catch.',
    correctionMessage:
        'Remove the try-catch block. Let the exception bubble up to the ViewModel.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/repositories/
    if (!PathUtils.isInRepositories(resolver.path)) {
      return;
    }

    context.registry.addTryStatement((node) {
      reporter.atNode(node, _code);
    });
  }
}
