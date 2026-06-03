import 'package:analyzer/dart/ast/ast.dart';

import 'rule_visitor_base.dart';

/// Reusable visitor for the "rule reports any `import` whose URI matches a
/// pattern" shape shared by `presentation_layer_isolation`,
/// `shared_widget_purity`, `model_purity`, and `repository_isolation`.
class BannedImportVisitor extends ArsyncRuleVisitor<Object> {
  BannedImportVisitor(super.rule, this.bannedPatterns, this.report);

  final List<String> bannedPatterns;
  final void Function(ImportDirective node) report;

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri != null && bannedPatterns.any(uri.contains)) report(node);
  }
}
