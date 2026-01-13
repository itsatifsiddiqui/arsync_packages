import '../arsync_lint_rule.dart';

/// A lint rule that ensures widgets returning a Sliver-type widget include
/// "Sliver" in their class names.
///
/// This naming convention improves code readability and consistency by clearly
/// indicating the widget's functionality and return type through its name.
///
/// The rule also allows "Sliver" in the named constructor.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// class MyCustomList extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return SliverList(...); // LINT
///   }
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// class SliverMyCustomList extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return SliverList(...);
///   }
/// }
/// ```
class PreferToIncludeSliverInName extends AnalysisRule {
  PreferToIncludeSliverInName()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'prefer_to_include_sliver_in_name',
    'Widgets returning Sliver should include "Sliver" '
        'in the class name or named constructor.',
    correctionMessage:
        'Add "Sliver" to the class name or use a named constructor with "sliver".',
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
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    // Find the build method
    MethodDeclaration? buildMethod;
    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'build') {
        buildMethod = member;
        break;
      }
    }

    if (buildMethod == null) {
      return;
    }

    final methodBody = buildMethod.body;
    if (methodBody is! BlockFunctionBody) {
      return;
    }

    // Check if any return statement returns a Sliver widget
    final returnsSliverWidget = _returnsSliverWidget(methodBody.block);

    if (!returnsSliverWidget) {
      return;
    }

    final className = node.name.lexeme;

    // Check if class name contains "Sliver"
    if (className.contains('Sliver')) {
      return;
    }

    // Check if any named constructor contains "sliver"
    for (final member in node.members) {
      if (member is ConstructorDeclaration) {
        final constructorName = member.name?.lexeme;
        if (constructorName != null &&
            constructorName.toLowerCase().contains('sliver')) {
          return;
        }
      }
    }

    rule.reportAtNode(node);
  }

  bool _returnsSliverWidget(Block block) {
    for (final statement in block.statements) {
      if (statement is ReturnStatement) {
        final returnType = statement.expression?.staticType;
        final typeName = returnType?.getDisplayString();
        if (typeName != null && typeName.startsWith('Sliver')) {
          return true;
        }
      }
    }
    return false;
  }
}
