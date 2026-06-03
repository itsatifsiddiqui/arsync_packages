import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../arsync_lint_rule.dart';

/// Lint rule: a `ChangeNotifier` (or any subtype — `TextEditingController`,
/// `ScrollController`, `ValueNotifier`, etc.) created as a field in a
/// `State` subclass must be disposed in `dispose()` *if it is actually used*.
/// Unused notifiers are not reported (they get GC'd).
class DisposeNotifier extends AnalysisRule {
  DisposeNotifier() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'dispose_notifier',
    "ChangeNotifier '{0}' is created but never disposed.",
    correctionMessage: "Call '{0}.dispose()' in the State's dispose() method.",
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

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!_extendsByName(node.extendsClause?.superclass.element, 'State')) {
      return;
    }

    final notifierVars = [
      for (final m in node.classMembers.whereType<FieldDeclaration>())
        for (final v in m.fields.variables)
          if (_isNotifierCreation(v)) v,
    ];
    if (notifierVars.isEmpty) return;

    final disposed = <String>{};
    final referenced = <String>{};
    for (final member in node.classMembers) {
      if (member is MethodDeclaration) {
        if (member.name.lexeme == 'dispose') {
          if (member.body is BlockFunctionBody) {
            member.body.accept(_DisposeVisitor(disposed));
          }
        } else {
          member.body.accept(_ReferenceVisitor(referenced));
        }
      } else if (member is ConstructorDeclaration) {
        for (final i in member.initializers) {
          i.accept(_ReferenceVisitor(referenced));
        }
        member.body.accept(_ReferenceVisitor(referenced));
      }
    }

    for (final v in notifierVars) {
      final name = v.name.lexeme;
      if (!referenced.contains(name) || disposed.contains(name)) continue;
      rule.reportAtNode(v, arguments: [name]);
    }
  }

  static bool _isNotifierCreation(VariableDeclaration v) {
    final init = v.initializer;
    final DartType? type;
    if (init is InstanceCreationExpression) {
      type = init.staticType;
    } else if (init is MethodInvocation) {
      type = init.staticType;
    } else {
      return false;
    }
    return type is InterfaceType && _isChangeNotifierType(type.element);
  }

  static bool _isChangeNotifierType(InterfaceElement e) {
    if (e.name == 'ChangeNotifier') return true;
    if (e.supertype != null && _isChangeNotifierType(e.supertype!.element)) {
      return true;
    }
    for (final m in e.mixins) {
      if (_isChangeNotifierType(m.element)) return true;
    }
    for (final i in e.interfaces) {
      if (_isChangeNotifierType(i.element)) return true;
    }
    return false;
  }

  static bool _extendsByName(Element? e, String name) {
    if (e is! InterfaceElement) return false;
    if (e.name == name) return true;
    return _extendsByName(e.supertype?.element, name);
  }
}

class _DisposeVisitor extends RecursiveAstVisitor<void> {
  final Set<String> sink;
  _DisposeVisitor(this.sink);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'dispose') {
      final t = node.target;
      if (t is SimpleIdentifier) {
        sink.add(t.name);
      } else if (t is PrefixedIdentifier) {
        sink.add(t.identifier.name);
      } else if (t is PropertyAccess) {
        sink.add(t.propertyName.name);
      }
    }
    super.visitMethodInvocation(node);
  }
}

class _ReferenceVisitor extends RecursiveAstVisitor<void> {
  final Set<String> sink;
  _ReferenceVisitor(this.sink);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    sink.add(node.name);
    super.visitSimpleIdentifier(node);
  }
}
