import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// A quick fix that creates a new `dispose()` method with notifier disposal.
///
/// This fix is triggered by the `dispose_notifier` lint rule when a
/// `ChangeNotifier` field is used but the `State` class has no `dispose()`
/// method.
///
/// ## Example
///
/// Before fix:
/// ```dart
/// class _MyState extends State<MyWidget> {
///   final _controller = TextEditingController();
///
///   @override
///   Widget build(BuildContext context) => TextField(controller: _controller);
/// }
/// ```
///
/// After fix:
/// ```dart
/// class _MyState extends State<MyWidget> {
///   final _controller = TextEditingController();
///
///   @override
///   Widget build(BuildContext context) => TextField(controller: _controller);
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }
/// ```
class AddDisposeMethodFix extends ResolvedCorrectionProducer {
  AddDisposeMethodFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.addDisposeMethod',
    50,
    'Add dispose() method',
  );

  @override
  FixKind get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Find the variable declaration
    final node = this.node;
    if (node is! VariableDeclaration) return;

    final fieldName = node.name.lexeme;

    // Find the containing class
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;

    // Check if dispose method already exists
    final hasDispose = classDeclaration.members.any(
      (m) => m is MethodDeclaration && m.name.lexeme == 'dispose',
    );

    if (hasDispose) return; // Use AddDisposeCallFix instead

    // Find the last member to insert after
    final lastMember = classDeclaration.members.lastOrNull;
    if (lastMember == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(lastMember.end, (builder) {
        builder.writeln();
        builder.writeln();
        builder.writeln('  @override');
        builder.writeln('  void dispose() {');
        builder.writeln('    $fieldName.dispose();');
        builder.writeln('    super.dispose();');
        builder.write('  }');
      });
    });
  }
}

/// A quick fix that adds a dispose call to an existing `dispose()` method.
///
/// This fix is triggered by the `dispose_notifier` lint rule when a
/// `ChangeNotifier` field is used but not disposed, and a `dispose()` method
/// already exists.
///
/// ## Example
///
/// Before fix:
/// ```dart
/// @override
/// void dispose() {
///   super.dispose();
/// }
/// ```
///
/// After fix:
/// ```dart
/// @override
/// void dispose() {
///   _controller.dispose();
///   super.dispose();
/// }
/// ```
class AddDisposeCallFix extends ResolvedCorrectionProducer {
  AddDisposeCallFix({required super.context});

  String? _fieldName;

  static const _fixKind = FixKind(
    'arsync.fix.addDisposeCall',
    51,
    "Add '.dispose()' call",
  );

  @override
  FixKind get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  List<String> get fixArguments => [_fieldName ?? ''];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Find the variable declaration
    final node = this.node;
    if (node is! VariableDeclaration) return;

    _fieldName = node.name.lexeme;

    // Find the containing class
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;

    // Find the dispose method
    MethodDeclaration? disposeMethod;
    for (final member in classDeclaration.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        disposeMethod = member;
        break;
      }
    }

    if (disposeMethod == null) return; // Use AddDisposeMethodFix instead

    final body = disposeMethod.body;
    if (body is! BlockFunctionBody) return;

    final block = body.block;

    // Find super.dispose() call to insert before it
    ExpressionStatement? superDisposeStatement;
    for (final statement in block.statements) {
      if (statement is ExpressionStatement) {
        final expr = statement.expression;
        if (expr is MethodInvocation &&
            expr.methodName.name == 'dispose' &&
            expr.target is SuperExpression) {
          superDisposeStatement = statement;
          break;
        }
      }
    }

    await builder.addDartFileEdit(file, (builder) {
      if (superDisposeStatement != null) {
        // Insert before super.dispose() - get indent from that line
        final lineStart = _getLineStart(superDisposeStatement.offset);
        final indent = unitResult.content.substring(
          lineStart,
          superDisposeStatement.offset,
        );
        builder.addInsertion(superDisposeStatement.offset, (builder) {
          builder.write('$_fieldName.dispose();');
          builder.writeln();
          builder.write(indent);
        });
      } else if (block.statements.isNotEmpty) {
        // No super.dispose(), insert after last statement
        final lastStatement = block.statements.last;
        final lineStart = _getLineStart(lastStatement.offset);
        final indent = unitResult.content.substring(
          lineStart,
          lastStatement.offset,
        );
        builder.addInsertion(lastStatement.end, (builder) {
          builder.writeln();
          builder.write('$indent$_fieldName.dispose();');
        });
      } else {
        // Empty dispose method, insert before closing brace
        final lineStart = _getLineStart(block.rightBracket.offset);
        final braceIndent = unitResult.content.substring(
          lineStart,
          block.rightBracket.offset,
        );
        // Statement indent is typically brace indent + 2 spaces
        final stmtIndent = '$braceIndent  ';
        builder.addInsertion(block.rightBracket.offset, (builder) {
          builder.write('$stmtIndent$_fieldName.dispose();');
          builder.writeln();
        });
      }
    });
  }

  /// Gets the offset of the start of the line containing [offset].
  int _getLineStart(int offset) {
    final content = unitResult.content;
    int lineStart = offset;
    while (lineStart > 0 && content[lineStart - 1] != '\n') {
      lineStart--;
    }
    return lineStart;
  }
}
