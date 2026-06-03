import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../arsync_lint_rule.dart';

/// Lint rule: don't hardcode colors (`Color(0x...)`, `Colors.red`,
/// `Color.fromARGB(...)`, etc.) — use `Theme.of(context).colorScheme` or a
/// `ThemeExtension` instead. `Colors.transparent`, definitions inside a
/// `ColorScheme(...)`, theme/palette files, and test files are exempt.
class AvoidHardcodedColor extends AnalysisRule {
  AvoidHardcodedColor()
    : super(name: code.lowerCaseName, description: code.problemMessage);

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
    final visitor = _Visitor(this, context);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addMethodInvocation(this, visitor)
      ..addPrefixedIdentifier(this, visitor);
  }
}

const _colorClassNames = {'Color', 'MaterialColor', 'MaterialAccentColor'};

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule, this.context);

  final RuleContext context;

  bool _exempt(AstNode node) {
    if (context.isInTestDirectory) return true;
    if (_isInsideColorScheme(node)) return true;
    final path = context.currentUnit?.file.path;
    return path != null && PathUtils.isThemeOrColorFile(path);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_exempt(node)) return;
    if (_isColorClass(node.staticType?.element)) rule.reportAtNode(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_exempt(node)) return;
    final element = node.methodName.element;
    if (element is ConstructorElement &&
        _isColorClass(element.enclosingElement)) {
      rule.reportAtNode(node);
    } else if (element is MethodElement &&
        element.isStatic &&
        _isColorClass(element.enclosingElement)) {
      // e.g. Color.fromARGB
      rule.reportAtNode(node);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_exempt(node)) return;

    final element = node.element;
    if (element is! PropertyAccessorElement && element is! FieldElement) return;

    final parent = element?.enclosingElement;
    if (parent is! ClassElement || parent.name != 'Colors') return;
    if (node.identifier.name == 'transparent') return;

    final type = element is PropertyAccessorElement
        ? element.returnType
        : (element! as FieldElement).type;
    if (_isColorType(type)) rule.reportAtNode(node);
  }

  static bool _isColorClass(Element? e) =>
      e is ClassElement && _colorClassNames.contains(e.name);

  static bool _isColorType(DartType? t) =>
      t != null && !t.isDartCoreInt && _isColorClass(t.element);

  static bool _isInsideColorScheme(AstNode node) {
    for (AstNode? p = node.parent; p != null; p = p.parent) {
      if (p is InstanceCreationExpression &&
          p.staticType?.element?.name == 'ColorScheme') {
        return true;
      }
      if (p is MethodInvocation) {
        if (p.target?.staticType?.element?.name == 'ColorScheme') return true;
        if (p.methodName.element?.enclosingElement?.name == 'ColorScheme') {
          return true;
        }
      }
    }
    return false;
  }
}
