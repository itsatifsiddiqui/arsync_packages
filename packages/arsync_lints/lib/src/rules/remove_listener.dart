import 'package:analyzer/dart/element/element.dart';

import '../arsync_lint_rule.dart';

/// Extracts the target name from an expression for listener matching.
/// `widget.controller` → `"widget.controller"`, etc. Returns `null` if not
/// representable as a dotted-identifier path.
String? _getTargetName(Expression? target) {
  if (target == null) return null;
  if (target is SimpleIdentifier) return target.name;
  if (target is PrefixedIdentifier) {
    return '${target.prefix.name}.${target.identifier.name}';
  }
  if (target is PropertyAccess) {
    final inner = _getTargetName(target.target);
    return inner == null ? target.propertyName.name : '$inner.${target.propertyName.name}';
  }
  return null;
}

/// Lint rule: listeners added to a `Listenable` must be removed in `dispose()`.
class RemoveListener extends AnalysisRule {
  RemoveListener() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'remove_listener',
    "Listener '{0}' is added but never removed.",
    correctionMessage:
        "Call 'removeListener({0})' in the dispose() method to prevent memory "
        'leaks.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  static const _addNames = {'addListener', 'addStatusListener'};
  static const _removeNames = {'removeListener', 'removeStatusListener'};
  static const _setupMethods = {
    'initState',
    'didChangeDependencies',
    'didUpdateWidget',
  };

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!_extendsState(node.extendsClause?.superclass.element)) return;

    final added = <_ListenerInfo>[];
    final removed = <_ListenerInfo>[];

    for (final m in node.classMembers.whereType<MethodDeclaration>()) {
      if (_setupMethods.contains(m.name.lexeme)) {
        m.accept(_ListenerCallVisitor(added, _addNames));
      } else if (m.name.lexeme == 'dispose') {
        m.accept(_ListenerCallVisitor(removed, _removeNames));
      }
    }

    for (final a in added) {
      final isRemoved = removed.any(
        (r) =>
            r.callbackName == a.callbackName &&
            _targetMatches(a.targetName, r.targetName),
      );
      if (isRemoved) continue;
      rule.reportAtNode(a.node, arguments: [a.callbackName]);
    }
  }

  bool _targetMatches(String? a, String? r) {
    if (a == null && r == null) return true;
    if (a == null || r == null) return false;
    if (a == r) return true;
    return a.split('.').last == r.split('.').last;
  }

  static bool _extendsState(Element? element) {
    if (element is! InterfaceElement) return false;
    if (element.name == 'State') return true;
    return _extendsState(element.supertype?.element);
  }
}

class _ListenerInfo {
  final String? targetName;
  final String callbackName;
  final AstNode node;

  _ListenerInfo(this.targetName, this.callbackName, this.node);
}

class _ListenerCallVisitor extends RecursiveAstVisitor<void> {
  final List<_ListenerInfo> sink;
  final Set<String> methodNames;

  _ListenerCallVisitor(this.sink, this.methodNames);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (methodNames.contains(node.methodName.name)) {
      final callback = node.argumentList.arguments.firstOrNull;
      final name = callback is SimpleIdentifier
          ? callback.name
          : callback is PrefixedIdentifier
          ? callback.identifier.name
          : null;
      if (name != null) {
        sink.add(_ListenerInfo(_getTargetName(node.target), name, node));
      }
    }
    super.visitMethodInvocation(node);
  }
}
