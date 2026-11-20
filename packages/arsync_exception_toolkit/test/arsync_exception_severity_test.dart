import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArsyncException severity defaults', () {
    test('constructor defaults to normal + warning', () {
      const ex = ArsyncException(
        icon: Icons.error,
        title: 't',
        message: 'm',
        briefTitle: 'bt',
        briefMessage: 'bm',
        exceptionCode: ArsyncCoreCode.generic,
      );
      expect(ex.severity, ArsyncErrorSeverity.normal);
      expect(ex.trackingSeverity, ArsyncTrackingSeverity.warning);
      expect(ex.isCritical, isFalse);
      expect(ex.isFieldError, isFalse);
    });

    test('tracking does not depend on severity', () {
      for (final severity in ArsyncErrorSeverity.values) {
        final ex = ArsyncException.generic(severity: severity);
        expect(ex.trackingSeverity, ArsyncTrackingSeverity.error);
      }
    });

    test('each factory has its own defaults', () {
      final cases = {
        'network': (
          ArsyncException.network(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.none,
        ),
        'timeout': (
          ArsyncException.timeout(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.none,
        ),
        'server': (
          ArsyncException.server(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.error,
        ),
        'authentication': (
          ArsyncException.authentication(),
          ArsyncErrorSeverity.critical,
          ArsyncTrackingSeverity.none,
        ),
        'ignored': (
          ArsyncException.ignored(),
          ArsyncErrorSeverity.ignored,
          ArsyncTrackingSeverity.none,
        ),
        'generic': (
          ArsyncException.generic(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.error,
        ),
        'permission': (
          ArsyncException.permission(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.warning,
        ),
        'notFound': (
          ArsyncException.notFound(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.warning,
        ),
        'format': (
          ArsyncException.format(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.warning,
        ),
        'unsupported': (
          ArsyncException.unsupported(),
          ArsyncErrorSeverity.normal,
          ArsyncTrackingSeverity.warning,
        ),
      };
      cases.forEach((name, value) {
        final (ex, severity, tracking) = value;
        expect(ex.severity, severity, reason: name);
        expect(ex.trackingSeverity, tracking, reason: name);
      });
      expect(ArsyncException.authentication().isCritical, isTrue);
    });

    test('explicit tracking wins over the default', () {
      expect(
        ArsyncException.generic(
          severity: ArsyncErrorSeverity.field,
          trackingSeverity: ArsyncTrackingSeverity.error,
        ).trackingSeverity,
        ArsyncTrackingSeverity.error,
      );
      expect(
        ArsyncException.ignored(
          trackingSeverity: ArsyncTrackingSeverity.warning,
        ).trackingSeverity,
        ArsyncTrackingSeverity.warning,
      );
      expect(
        ArsyncException.network(
          trackingSeverity: ArsyncTrackingSeverity.error,
        ).trackingSeverity,
        ArsyncTrackingSeverity.error,
      );
    });
  });

  group('ArsyncException.copyWith severity', () {
    test('keeps both when not given', () {
      final ex = ArsyncException.server();
      final copy = ex.copyWith(title: 'New');
      expect(copy.severity, ArsyncErrorSeverity.normal);
      expect(copy.trackingSeverity, ArsyncTrackingSeverity.error);
    });

    test('changes each one', () {
      final ex = ArsyncException.generic();
      expect(
        ex
            .copyWith(trackingSeverity: ArsyncTrackingSeverity.none)
            .trackingSeverity,
        ArsyncTrackingSeverity.none,
      );
      final field = ex.copyWith(
        severity: ArsyncErrorSeverity.field,
        trackingSeverity: ArsyncTrackingSeverity.error,
      );
      expect(field.severity, ArsyncErrorSeverity.field);
      expect(field.trackingSeverity, ArsyncTrackingSeverity.error);
      expect(field.isFieldError, isTrue);
    });

    test('changing only severity keeps the old tracking', () {
      final ex = ArsyncException.generic();
      final copy = ex.copyWith(severity: ArsyncErrorSeverity.critical);
      expect(copy.severity, ArsyncErrorSeverity.critical);
      expect(copy.trackingSeverity, ArsyncTrackingSeverity.error);
    });
  });

  group('ArsyncException == and hashCode', () {
    test('equal when severities match', () {
      final a = ArsyncException.generic();
      final b = ArsyncException.generic();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differ when severity differs', () {
      final a = ArsyncException.generic();
      final b = ArsyncException.generic(
        severity: ArsyncErrorSeverity.critical,
        trackingSeverity: ArsyncTrackingSeverity.warning,
      );
      expect(a, isNot(b));
      expect(a.hashCode, isNot(b.hashCode));
    });

    test('differ when tracking differs', () {
      final a = ArsyncException.generic();
      final b = ArsyncException.generic(
        trackingSeverity: ArsyncTrackingSeverity.none,
      );
      expect(a, isNot(b));
      expect(a.hashCode, isNot(b.hashCode));
    });

    test('compares the resolved tracking', () {
      final implicit = ArsyncException.generic();
      final explicit = ArsyncException.generic(
        trackingSeverity: ArsyncTrackingSeverity.error,
      );
      expect(implicit, explicit);
      expect(implicit.hashCode, explicit.hashCode);
    });
  });

  group('ArsyncExceptionToolkit severity', () {
    test('a modifier can change severity', () {
      final toolkit = ArsyncExceptionToolkit();
      toolkit.registerExceptionModifier(
        ArsyncCoreCode.format.id,
        (exception, originalException) =>
            exception.copyWith(severity: ArsyncErrorSeverity.field),
      );
      final ex = toolkit.handleException(const FormatException('bad'));
      expect(ex.exceptionCode, ArsyncCoreCode.format);
      expect(ex.severity, ArsyncErrorSeverity.field);
      expect(ex.trackingSeverity, ArsyncTrackingSeverity.warning);
    });

    test('an unknown exception is tracked as error', () {
      final ex = ArsyncExceptionToolkit().handleException(Exception('boom'));
      expect(ex.exceptionCode, ArsyncCoreCode.generic);
      expect(ex.trackingSeverity, ArsyncTrackingSeverity.error);
    });

    test('ignorable exceptions come back with severity ignored', () {
      final toolkit = ArsyncExceptionToolkit();
      final ex = toolkit.handleException(Exception('user cancelled'));
      expect(ex.severity, ArsyncErrorSeverity.ignored);
      expect(ex.trackingSeverity, ArsyncTrackingSeverity.none);
    });

    test('tr() keeps both severities', () {
      final ex = ArsyncException.authentication(
        trackingSeverity: ArsyncTrackingSeverity.error,
      );
      final localized = ex.tr((key) => 'x');
      expect(localized.severity, ArsyncErrorSeverity.critical);
      expect(localized.trackingSeverity, ArsyncTrackingSeverity.error);
    });

    test('shouldIgnore follows severity, not the code', () {
      final ignored = ArsyncException.generic(
        severity: ArsyncErrorSeverity.ignored,
      );
      expect(ignored.shouldIgnore, isTrue);
      expect(ignored.isIgnoredError, isTrue);
      expect(ArsyncException.generic().shouldIgnore, isFalse);
      expect(
        ArsyncException.ignored(
          severity: ArsyncErrorSeverity.normal,
        ).shouldIgnore,
        isFalse,
      );
    });

    test('ignore patterns can be added and removed on the default list', () {
      final toolkit = ArsyncExceptionToolkit();
      final error = Exception('user aborted');
      expect(toolkit.shouldIgnoreException(error), isFalse);

      toolkit.addIgnorableException('user aborted');
      expect(toolkit.handleException(error).shouldIgnore, isTrue);
      expect(
        toolkit.handleException(error, ignoreMatching: false).shouldIgnore,
        isFalse,
      );

      toolkit.removeIgnorableException('user aborted');
      expect(toolkit.shouldIgnoreException(error), isFalse);
    });
  });
}
