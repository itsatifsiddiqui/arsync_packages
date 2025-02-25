import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import 'dio_error_handler.dart';
import 'response_error_handler.dart';
import 'error_extractor.dart';

/// A combined handler for all Dio-related exceptions
///
/// This handler delegates to specific Dio handlers based on the exception type.
/// It first tries the response error handler for detailed API responses,
/// and falls back to the general Dio error handler for other errors.
class DioErrorsHandler implements ArsyncExceptionHandler {
  final ResponseErrorHandler _responseErrorHandler;
  final DioErrorHandler _dioErrorHandler;
  
  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a combined Dio errors handler
  ///
  /// [responseErrorHandler] - Optional custom Response Error handler
  /// [dioErrorHandler] - Optional custom Dio Error handler
  /// [priority] - Priority level for this handler (higher = higher priority)
  DioErrorsHandler({
    ResponseErrorHandler? responseErrorHandler,
    DioErrorHandler? dioErrorHandler,
    int priority = 25,
  }) : _responseErrorHandler = responseErrorHandler ?? 
             ResponseErrorHandler(errorExtractor: DefaultErrorExtractor()),
       _dioErrorHandler = dioErrorHandler ?? DioErrorHandler(),
       _priority = priority;

  @override
  bool canHandle(Object exception) {
    return _responseErrorHandler.canHandle(exception) ||
           _dioErrorHandler.canHandle(exception);
  }

  @override
  ArsyncException handle(Object exception) {
    // First try the response error handler for API response errors
    if (_responseErrorHandler.canHandle(exception)) {
      return _responseErrorHandler.handle(exception);
    }
    
    // Fall back to the general Dio error handler
    if (_dioErrorHandler.canHandle(exception)) {
      return _dioErrorHandler.handle(exception);
    }
    
    // This shouldn't happen if canHandle was checked first
    return ArsyncException.generic(
      title: 'Network Error',
      message: 'An unexpected network error occurred',
      originalException: exception,
    );
  }

  @override
  int get priority => _priority;

  /// Get the response error handler
  ResponseErrorHandler get responseErrorHandler => _responseErrorHandler;
  
  /// Get the Dio error handler
  DioErrorHandler get dioErrorHandler => _dioErrorHandler;

  /// Create a new instance with customized handlers
  DioErrorsHandler copyWith({
    ResponseErrorHandler? responseErrorHandler,
    DioErrorHandler? dioErrorHandler,
    int? priority,
  }) {
    return DioErrorsHandler(
      responseErrorHandler: responseErrorHandler ?? _responseErrorHandler,
      dioErrorHandler: dioErrorHandler ?? _dioErrorHandler,
      priority: priority ?? _priority,
    );
  }
  
  /// Create a new instance with a custom error extractor
  DioErrorsHandler withErrorExtractor(ErrorExtractor errorExtractor) {
    return copyWith(
      responseErrorHandler: _responseErrorHandler.withErrorExtractor(errorExtractor),
    );
  }
}