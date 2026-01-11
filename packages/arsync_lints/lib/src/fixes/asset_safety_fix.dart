import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `asset_safety` rule - replace string literal with Images constant.
///
/// Replaces the string literal with a placeholder Images.* constant.
class AssetSafetyFix extends ResolvedCorrectionProducer {
  AssetSafetyFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.assetSafety',
    100,
    'Replace with Images constant',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final stringLiteral = _findStringLiteral(node);
    if (stringLiteral == null) return;

    // Extract the asset path to generate a reasonable constant name
    final assetPath = stringLiteral.stringValue ?? '';
    final constantName = _generateConstantName(assetPath);

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(stringLiteral.offset, stringLiteral.length),
        'Images.$constantName',
      );
    });
  }

  /// Generate a reasonable constant name from the asset path.
  ///
  /// e.g., 'assets/images/logo.png' -> 'logo'
  /// e.g., 'assets/icons/home_icon.svg' -> 'homeIcon'
  String _generateConstantName(String assetPath) {
    // Extract the file name without extension
    final parts = assetPath.split('/');
    if (parts.isEmpty) return 'asset';

    var fileName = parts.last;

    // Remove extension
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      fileName = fileName.substring(0, dotIndex);
    }

    // Convert to camelCase
    final segments = fileName.split(RegExp(r'[_\-]'));
    if (segments.isEmpty) return 'asset';

    final buffer = StringBuffer(segments.first.toLowerCase());
    for (var i = 1; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.isNotEmpty) {
        buffer.write(segment[0].toUpperCase());
        buffer.write(segment.substring(1).toLowerCase());
      }
    }

    final result = buffer.toString();
    return result.isEmpty ? 'asset' : result;
  }

  StringLiteral? _findStringLiteral(AstNode? node) {
    if (node == null) return null;
    if (node is StringLiteral) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is StringLiteral) return current;
      current = current.parent;
    }
    return null;
  }
}
