import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import 'dio_error_handler.dart';
import 'response_error_handler.dart';
import 'error_extractor.dart';
import 'dio_errors_handler.dart';

/// Extension methods for ArsyncExceptionToolkit to work with Dio handlers
extension DioToolkitExtensions on ArsyncExceptionToolkit {
  /// Add a Dio error handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withDioErrorHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 20,
  }) {
    exceptionMapper.handlers.add(
      DioErrorHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Response error handler to the toolkit
  ///
  /// [errorExtractor] - Extractor for parsing error details from responses
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withResponseErrorHandler({
    ErrorExtractor? errorExtractor,
    Map<String, ArsyncException>? customExceptions,
    int priority = 21,
  }) {
    exceptionMapper.handlers.add(
      ResponseErrorHandler(
        errorExtractor: errorExtractor ?? DefaultErrorExtractor(),
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add all Dio handlers to the toolkit
  ///
  /// [responseErrorHandler] - Optional custom Response Error handler
  /// [dioErrorHandler] - Optional custom Dio Error handler
  /// [errorExtractor] - Optional error extractor for the response handler
  /// [priority] - Optional priority for the combined handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withAllDioHandlers({
    ResponseErrorHandler? responseErrorHandler,
    DioErrorHandler? dioErrorHandler,
    ErrorExtractor? errorExtractor,
    int priority = 25,
  }) {
    // If errorExtractor is provided but responseErrorHandler is not,
    // create a new ResponseErrorHandler with the provided extractor
    final ResponseErrorHandler responseHandler = responseErrorHandler ?? 
        (errorExtractor != null 
          ? ResponseErrorHandler(errorExtractor: errorExtractor)
          : ResponseErrorHandler(errorExtractor: DefaultErrorExtractor()));
    
    exceptionMapper.handlers.add(
      DioErrorsHandler(
        responseErrorHandler: responseHandler,
        dioErrorHandler: dioErrorHandler,
        priority: priority,
      ),
    );
    return this;
  }
}

/// Extension methods for ArsyncExceptionMapper to work with Dio handlers
extension DioMapperExtensions on List<ArsyncExceptionHandler> {
  /// Add a Dio error handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addDioErrorHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 20,
  }) {
    add(
      DioErrorHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Response error handler to the mapper
  ///
  /// [errorExtractor] - Extractor for parsing error details from responses
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addResponseErrorHandler({
    ErrorExtractor? errorExtractor,
    Map<String, ArsyncException>? customExceptions,
    int priority = 21,
  }) {
    add(
      ResponseErrorHandler(
        errorExtractor: errorExtractor ?? DefaultErrorExtractor(),
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add all Dio handlers to the mapper
  ///
  /// [responseErrorHandler] - Optional custom Response Error handler
  /// [dioErrorHandler] - Optional custom Dio Error handler
  /// [errorExtractor] - Optional error extractor for the response handler
  /// [priority] - Optional priority for the combined handler
  void addAllDioHandlers({
    ResponseErrorHandler? responseErrorHandler,
    DioErrorHandler? dioErrorHandler,
    ErrorExtractor? errorExtractor,
    int priority = 25,
  }) {
    // If errorExtractor is provided but responseErrorHandler is not,
    // create a new ResponseErrorHandler with the provided extractor
    final ResponseErrorHandler responseHandler = responseErrorHandler ?? 
        (errorExtractor != null 
          ? ResponseErrorHandler(errorExtractor: errorExtractor)
          : ResponseErrorHandler(errorExtractor: DefaultErrorExtractor()));
    
    add(
      DioErrorsHandler(
        responseErrorHandler: responseHandler,
        dioErrorHandler: dioErrorHandler,
        priority: priority,
      ),
    );
  }
}