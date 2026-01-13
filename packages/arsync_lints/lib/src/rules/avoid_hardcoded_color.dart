import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../arsync_lint_rule.dart';

/// A lint rule that discourages the use of hardcoded colors directly in code,
/// promoting the use of `ColorScheme`, `ThemeExtension`, or other Theme-based
/// systems for defining colors.
///
/// This practice ensures that colors are consistent and adaptable to different
/// themes and accessibility settings.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// Container(
///   color: Color(0xFF00FF00), // LINT
/// );
/// Container(
///   color: Colors.red, // LINT
/// );
/// ```
///
/// #### GOOD:
/// ```dart
/// Container(
///   color: Theme.of(context).colorScheme.primary,
/// );
/// ```
class AvoidHardcodedColor extends AnalysisRule {
  AvoidHardcodedColor()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'avoid_hardcoded_color',
    'Avoid using hardcoded color. Use ColorScheme based definitions.',
    correctionMessage:
        'Use Theme.of(context).colorScheme or a ThemeExtension for colors.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    final visitor = _Visitor(this, context.allUnits);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addMethodInvocation(this, visitor)
      ..addPrefixedIdentifier(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Skip generated files, test files, and nodes with ignore comments
    if (_shouldSkipNode(node)) return;
    if (_isInsideColorScheme(node)) return;

    final type = node.staticType;
    if (_isColorClass(type?.element)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Skip generated files, test files, and nodes with ignore comments
    if (_shouldSkipNode(node)) return;
    if (_isInsideColorScheme(node)) return;

    final element = node.methodName.element;

    if (element is ConstructorElement) {
      if (_isColorClass(element.enclosingElement)) {
        rule.reportAtNode(node);
      }
      return;
    }

    // e.g. Color.fromARGB
    if (element is MethodElement && element.isStatic) {
      if (_isColorClass(element.enclosingElement)) {
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    // Skip generated files, test files, and nodes with ignore comments
    if (_shouldSkipNode(node)) return;
    if (_isInsideColorScheme(node)) return;

    final element = node.element;

    if (element is PropertyAccessorElement || element is FieldElement) {
      final parentClass = element?.enclosingElement;
      if (parentClass is ClassElement && parentClass.name == 'Colors') {
        // Colors.transparent is allowed
        if (node.identifier.name == 'transparent') {
          return;
        }

        final type = (element is PropertyAccessorElement)
            ? element.returnType
            : (element! as FieldElement).type;

        if (_isColorType(type)) {
          rule.reportAtNode(node);
        }
      }
    }
  }

  bool _shouldSkipNode(AstNode node) {
    // Check for generated files and ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return true;

    // Check for test files
    final path = NodeContentHelper.getFilePathForNode(node, allUnits);
    if (path != null && TypeUtils.isTestFile(path)) return true;

    return false;
  }

  bool _isColorClass(Element? element) {
    if (element is! ClassElement) {
      return false;
    }
    return element.name == 'Color' ||
        element.name == 'MaterialColor' ||
        element.name == 'MaterialAccentColor';
  }

  bool _isColorType(DartType? type) {
    if (type == null) {
      return false;
    }
    if (type.isDartCoreInt) {
      return false;
    }
    return _isColorClass(type.element);
  }

  /// Checks if the node is defined inside a ColorScheme context.
  bool _isInsideColorScheme(AstNode node) {
    var parent = node.parent;
    while (parent != null) {
      // Check if we are inside a ColorScheme(...) constructor
      if (parent is InstanceCreationExpression) {
        final type = parent.staticType;
        if (type != null && type.element?.name == 'ColorScheme') {
          return true;
        }
      }

      // Check if we are inside a method call on a ColorScheme object
      if (parent is MethodInvocation) {
        final targetType = parent.target?.staticType;
        if (targetType != null && targetType.element?.name == 'ColorScheme') {
          return true;
        }

        final methodElement = parent.methodName.element;
        if (methodElement?.enclosingElement?.name == 'ColorScheme') {
          return true;
        }
      }
      parent = parent.parent;
    }
    return false;
  }
}
