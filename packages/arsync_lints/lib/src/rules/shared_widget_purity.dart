import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule A2: shared_widget_purity
///
/// Shared Widgets must be dumb and pure. They cannot know about business logic.
/// Each widget file should contain only ONE public widget.
class SharedWidgetPurity extends DartLintRule {
  const SharedWidgetPurity() : super(code: _importCode);

  static const _importCode = LintCode(
    name: 'shared_widget_purity',
    problemMessage:
        'Shared Widgets must be pure. Pass data as parameters, do not read providers.',
    correctionMessage:
        'Pass data as Constructor Arguments instead of reading providers.',
  );

  static const _singleWidgetCode = LintCode(
    name: 'shared_widget_purity',
    problemMessage:
        'Widget file should only contain ONE public widget. Other widgets must be private (_).',
    correctionMessage:
        'Make this widget private by prefixing with _ or move to a separate file.',
  );

  /// Banned import patterns for shared widgets.
  static const _bannedPatterns = [
    'providers/',
    'package:flutter_riverpod',
    'package:riverpod',
    'package:hooks_riverpod',
  ];

  /// Widget base classes (excluding Widget itself to avoid mock class issues)
  static const _widgetBaseClasses = {
    'StatelessWidget',
    'StatefulWidget',
    'HookWidget',
    'HookConsumerWidget',
    'ConsumerWidget',
    'ConsumerStatefulWidget',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/widgets/
    if (!PathUtils.isInWidgets(resolver.path)) {
      return;
    }

    // Check imports
    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      if (_isBannedImport(importUri)) {
        reporter.atNode(node, _importCode);
      }
    });

    // Collect public widget classes
    final publicWidgets = <ClassDeclaration>[];

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;

      // Skip private classes
      if (className.startsWith('_')) return;

      // Check if it's a widget class
      if (_isWidgetClass(node)) {
        publicWidgets.add(node);
      }
    });

    // After collecting, check for multiple public widgets
    context.addPostRunCallback(() {
      if (publicWidgets.length > 1) {
        // Report on all widgets after the first one
        for (var i = 1; i < publicWidgets.length; i++) {
          reporter.atToken(publicWidgets[i].name, _singleWidgetCode);
        }
      }
    });
  }

  bool _isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Check if class extends a Widget base class
  bool _isWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name2.lexeme;
    return _widgetBaseClasses.contains(superclassName);
  }
}
