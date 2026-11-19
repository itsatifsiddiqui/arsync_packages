import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:arsync_supabase_errors_handler/arsync_supabase_errors_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';

void main() {
  final handler = SupabaseErrorsHandler();

  void expectSeverity(
    Object error,
    ArsyncErrorSeverity severity,
    ArsyncTrackingSeverity trackingSeverity,
  ) {
    final exception = handler.handle(error);
    expect(exception.severity, severity);
    expect(exception.trackingSeverity, trackingSeverity);
  }

  test('expired session is critical and not tracked', () {
    expectSeverity(
      AuthException('JWT expired'),
      ArsyncErrorSeverity.critical,
      ArsyncTrackingSeverity.none,
    );
  });

  group('tracking', () {
    test('not-null violation is tracked as error', () {
      expectSeverity(
        PostgrestException(message: 'null value in column', code: '23502'),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.error,
      );
    });

    test('wrong login is not tracked', () {
      expectSeverity(
        AuthException('Invalid login credentials'),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.none,
      );
    });

    test('duplicate entry is tracked as warning', () {
      expectSeverity(
        PostgrestException(message: 'duplicate value', code: '23505'),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.warning,
      );
    });
  });

  test('cancelled sign-in stays ignored', () {
    expectSeverity(
      AuthException('User cancelled the sign in'),
      ArsyncErrorSeverity.ignored,
      ArsyncTrackingSeverity.none,
    );
  });
}
