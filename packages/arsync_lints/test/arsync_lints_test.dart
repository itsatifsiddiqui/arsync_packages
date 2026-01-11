import 'package:test/test.dart';
import 'package:arsync_lints/src/utils.dart';

void main() {
  group('arsync_lints package', () {
    test('PathUtils exports are available', () {
      expect(PathUtils.normalizePath('/test/path'), '/test/path');
    });

    test('ImportUtils exports are available', () {
      expect(
        ImportUtils.matchesBannedImport('package:dio', ['package:dio']),
        true,
      );
    });
  });
}
