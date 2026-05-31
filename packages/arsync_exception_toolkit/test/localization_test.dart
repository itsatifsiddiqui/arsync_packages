import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArsyncException.tr (key lookup)', () {
    test('looks up <id>.<field> and falls back per field', () {
      final ex = ArsyncException.network();
      final id = ex.exceptionCode.id; // 'network_error'
      final translations = {
        '$id.message': 'Mensaje traducido',
        '$id.briefMessage': 'Sin internet',
      };

      final localized = ex.tr((key) => translations[key]);

      expect(localized.message, 'Mensaje traducido');
      expect(localized.briefMessage, 'Sin internet');
      expect(localized.title, ex.title); // missing key → English
      expect(localized.exceptionCode, ex.exceptionCode);
      expect(localized.icon, ex.icon);
    });

    test('all keys missing → unchanged English', () {
      final ex = ArsyncException.timeout();
      final localized = ex.tr((_) => null);
      expect(localized, ex);
    });

    test('dynamic raw codes look up under their runtime id', () {
      const code = RawArsyncExceptionCode('supabase_auth_some_runtime_code');
      final ex = ArsyncException.generic(exceptionCode: code);

      final localized = ex.tr((_) => null);
      expect(localized.message, ex.message);
      expect(localized.exceptionCode, code);
    });
  });

  group('ArsyncExceptionToolkit localize wiring', () {
    test('no localize param => built-in English (no behavior change)', () {
      final toolkit = ArsyncExceptionToolkit();
      final ex = toolkit.handleException(Exception('boom'));
      expect(ex.title, isNotEmpty);
    });

    test('injected lookup localizes handled exceptions', () {
      final toolkit = ArsyncExceptionToolkit(
        localize: (key) => key.endsWith('.message') ? 'Localizado' : null,
      );
      final ex = toolkit.handleException(Exception('boom'));
      expect(ex.message, 'Localizado');
    });
  });
}
