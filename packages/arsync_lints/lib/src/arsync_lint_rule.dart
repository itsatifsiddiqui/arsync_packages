/// Base exports for arsync lint rules.
///
/// This provides convenient imports for creating lint rules that enforce
/// the Arsync 4-Layer Architecture.
library;

// Core analysis rule APIs from the Dart SDK
// See: https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/writing_rules.md
export 'package:analyzer/analysis_rule/analysis_rule.dart';
export 'package:analyzer/analysis_rule/rule_context.dart';
export 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
export 'package:analyzer/dart/ast/ast.dart';
export 'package:analyzer/dart/ast/visitor.dart';
export 'package:analyzer/error/error.dart';
export 'utils.dart';
