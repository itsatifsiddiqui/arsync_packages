import 'arsync_exception.dart';

/// A key→string lookup from your i18n. Returns the localized string,
/// or `null` to keep the built-in English for that field.
typedef ArsyncTr = String? Function(String key);

extension ArsyncLocalize on ArsyncException {
  /// Localizes via [lookup]: each field is read under `<id>.<field>` (`<field>` ∈
  /// `title`, `message`, `briefTitle`, `briefMessage`); a `null` result keeps English.
  ArsyncException tr(ArsyncTr lookup) {
    final id = exceptionCode.id;
    return copyWith(
      title: lookup('$id.title') ?? title,
      message: lookup('$id.message') ?? message,
      briefTitle: lookup('$id.briefTitle') ?? briefTitle,
      briefMessage: lookup('$id.briefMessage') ?? briefMessage,
    );
  }
}
