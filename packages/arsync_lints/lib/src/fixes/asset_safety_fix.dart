import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `asset_safety` — replace string literal with `Images.*`.
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
    final literal = node.thisOrAncestorOfType<StringLiteral>();
    if (literal == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(literal.offset, literal.length),
        'Images.${_constName(literal.stringValue ?? '')}',
      );
    });
  }

  /// `assets/images/logo.png` → `logo`; `assets/icons/home_icon.svg` → `homeIcon`.
  static String _constName(String path) {
    var name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot > 0) name = name.substring(0, dot);

    final parts = name.split(RegExp(r'[_\-]')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'asset';

    final buf = StringBuffer(parts.first.toLowerCase());
    for (final p in parts.skip(1)) {
      buf.write(p[0].toUpperCase());
      buf.write(p.substring(1).toLowerCase());
    }
    return buf.toString();
  }
}
