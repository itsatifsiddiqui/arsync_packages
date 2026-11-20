import 'package:arsync_dio_errors_handler/arsync_dio_errors_handler.dart';
import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final requestOptions = RequestOptions(path: '/test');

  DioException statusError(int statusCode) => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: requestOptions, statusCode: statusCode),
  );

  DioException typeError(DioExceptionType type) =>
      DioException(requestOptions: requestOptions, type: type);

  void expectSeverity(
    ArsyncExceptionHandler handler,
    Object error,
    ArsyncErrorSeverity severity,
    ArsyncTrackingSeverity trackingSeverity,
  ) {
    final exception = handler.handle(error);
    expect(exception.severity, severity);
    expect(exception.trackingSeverity, trackingSeverity);
  }

  group('critical errors', () {
    test('401 response is critical and not tracked', () {
      expectSeverity(
        DioErrorsHandler(),
        statusError(401),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.none,
      );
    });

    test('401 in DioErrorHandler is critical and not tracked', () {
      expectSeverity(
        DioErrorHandler(),
        statusError(401),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.none,
      );
    });

    test('409 in DioErrorHandler is critical', () {
      expectSeverity(
        DioErrorHandler(),
        statusError(409),
        ArsyncErrorSeverity.critical,
        ArsyncTrackingSeverity.warning,
      );
    });
  });

  group('tracking', () {
    test('500 response is tracked as error', () {
      expectSeverity(
        DioErrorsHandler(),
        statusError(500),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.error,
      );
    });

    test('connection timeout is not tracked', () {
      expectSeverity(
        DioErrorsHandler(),
        typeError(DioExceptionType.connectionTimeout),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.none,
      );
    });

    test('404 response is tracked as warning', () {
      expectSeverity(
        DioErrorsHandler(),
        statusError(404),
        ArsyncErrorSeverity.normal,
        ArsyncTrackingSeverity.warning,
      );
    });
  });

  test('cancelled request comes back ignored', () {
    final exception = DioErrorsHandler().handle(
      typeError(DioExceptionType.cancel),
    );
    expect(exception.exceptionCode, DioErrorCode.cancel);
    expect(exception.severity, ArsyncErrorSeverity.ignored);
    expect(exception.trackingSeverity, ArsyncTrackingSeverity.none);
  });

  test('customExceptions can override a cancel', () {
    final handler = DioErrorHandler(
      customExceptions: {
        DioErrorCodes.cancel: ArsyncException.generic(title: 'Stopped'),
      },
    );
    final exception = handler.handle(typeError(DioExceptionType.cancel));
    expect(exception.title, 'Stopped');
    expect(exception.severity, ArsyncErrorSeverity.normal);
  });
}
