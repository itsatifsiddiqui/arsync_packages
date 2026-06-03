import 'package:analyzer/dart/ast/visitor.dart';

/// Base for the per-rule `_Visitor` boilerplate. Generic over the rule type so
/// it works for both `AnalysisRule` and `MultiAnalysisRule` subclasses
/// (`reportAtNode` / `reportAtOffset` live on each, not on the shared base).
///
/// Holds only the rule reference. Rules that need source content / file path
/// should stash `RuleContext` themselves and read `context.currentUnit`
/// during visit.
///
/// Generated files are NOT filtered here — users exclude them via
/// `analysis_options.yaml`:
///
/// ```yaml
/// analyzer:
///   exclude:
///     - "**/*.g.dart"
///     - "**/*.freezed.dart"
///     - "**/*.gr.dart"
/// ```
abstract class ArsyncRuleVisitor<R> extends SimpleAstVisitor<void> {
  final R rule;

  ArsyncRuleVisitor(this.rule);
}
