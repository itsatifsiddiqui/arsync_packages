import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:arsync_firebase_errors_handler/arsync_firebase_errors_handler.dart';
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final handler = FirebaseErrorsHandler();

  void expectSeverity(
    Object error,
    ArsyncErrorSeverity severity,
    ArsyncTrackingSeverity trackingSeverity,
  ) {
    final exception = handler.handle(error);
    expect(exception.severity, severity);
    expect(exception.trackingSeverity, trackingSeverity);
  }

  FirebaseAuthException authError(String code) =>
      FirebaseAuthException(code: code);

  FirebaseException pluginError(String plugin, String code) =>
      FirebaseException(plugin: plugin, code: code);

  group('critical errors', () {
    test('user-disabled', () {
      expectSeverity(
        authError('user-disabled'),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.warning,
      );
    });

    test('account-exists-with-different-credential', () {
      expectSeverity(
        authError('account-exists-with-different-credential'),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.warning,
      );
    });

    test('requires-recent-login', () {
      expectSeverity(
        authError('requires-recent-login'),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.none,
      );
    });

    test('firestore unauthenticated', () {
      expectSeverity(
        pluginError('cloud_firestore', 'unauthenticated'),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.warning,
      );
    });

    test('functions unauthenticated', () {
      expectSeverity(
        FirebaseFunctionsException(message: 'no user', code: 'unauthenticated'),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.warning,
      );
    });

    test('storage unauthenticated', () {
      expectSeverity(
        pluginError('firebase_storage', 'unauthenticated'),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.warning,
      );
    });
  });

  group('tracking', () {
    test('firestore permission-denied is tracked as error', () {
      expectSeverity(
        pluginError('cloud_firestore', 'permission-denied'),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.error,
      );
    });

    test('wrong-password is not tracked', () {
      expectSeverity(
        authError('wrong-password'),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.none,
      );
    });

    test('too-many-requests is tracked as warning', () {
      expectSeverity(
        authError('too-many-requests'),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.warning,
      );
    });
  });

  test('cancelled sign-in comes back ignored', () {
    final exception = handler.handle(authError('popup-closed-by-user'));
    expect(exception.exceptionCode, FirebaseAuthCode.popupClosedByUser);
    expect(exception.severity, ArsyncErrorSeverity.ignored);
    expect(exception.trackingSeverity, ArsyncTrackingSeverity.none);
  });

  test('customExceptions can override a cancel', () {
    final custom = FirebaseAuthHandler(
      customExceptions: {
        'popup-closed-by-user': ArsyncException.generic(title: 'Closed'),
      },
    );
    final exception = custom.handle(authError('popup-closed-by-user'));
    expect(exception.title, 'Closed');
    expect(exception.severity, ArsyncErrorSeverity.normal);
  });
}
