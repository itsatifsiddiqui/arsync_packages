import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dio_error_codes.dart';
import 'error_extractor.dart';

/// Handler specifically for API response errors from Dio
class ResponseErrorHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Error extractor to use for parsing error responses
  final ErrorExtractor _errorExtractor;

  /// Create a Response error handler
  ///
  /// [errorExtractor] - Extractor for parsing error details from responses
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  ResponseErrorHandler({
    required ErrorExtractor errorExtractor,
    this.customExceptions,
    int priority = 21, // Higher priority than basic DioErrorHandler
  })  : _priority = priority,
        _errorExtractor = errorExtractor;

  @override
  bool canHandle(Object exception) {
    if (exception is DioException &&
        exception.type == DioExceptionType.badResponse &&
        exception.response != null) {
      // Check if we have a response with data to extract errors from
      return true;
    }
    return false;
  }

  @override
  ArsyncException handle(Object exception) {
    final dioException = exception as DioException;
    final response = dioException.response!;
    final statusCode = response.statusCode ?? 0;

    // Extract error details from response
    final extractedError = _extractErrorFromResponse(response);
    final errorCode =
        extractedError.code ?? DioErrorCodes.fromStatusCode(statusCode);
    final errorMessage = extractedError.message;

    // Technical details with both the extracted error and the original message
    final technicalDetails = 'Dio Response Error: $statusCode\n'
        'URL: ${dioException.requestOptions.uri}\n'
        'Method: ${dioException.requestOptions.method}\n'
        'Error Code: $errorCode\n'
        'Error Message: $errorMessage\n'
        'Original Exception: ${dioException.message}';

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(errorCode)) {
      return customExceptions![errorCode]!.copyWith(
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Create a custom exception based on the status code and extracted error
    final httpCode = 'http_$statusCode';
    if (customExceptions != null && customExceptions!.containsKey(httpCode)) {
      return customExceptions![httpCode]!.copyWith(
        message: errorMessage ?? customExceptions![httpCode]!.message,
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Use default error exceptions based on status code categories
    // Check if we have a default handler for the status code
    final code = DioErrorCodes.fromStatusCode(statusCode);
    final defaultError =
        _getDefaultErrorForStatusCode(statusCode, errorMessage);

    return defaultError.copyWith(
      originalException: exception,
      technicalDetails: technicalDetails,
      exceptionCode: 'dio_response_$code',
    );
  }

  /// Extract structured error information from a response
  ExtractedError _extractErrorFromResponse(Response response) {
    try {
      return _errorExtractor.extractError(response);
    } catch (e) {
      // If error extraction fails, return a basic error
      return ExtractedError(
        message: 'Failed to parse error response',
      );
    }
  }

  /// Get a default error message based on the HTTP status code
  ArsyncException _getDefaultErrorForStatusCode(
      int statusCode, String? errorMessage) {
    // Client errors (4xx)
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 400:
          return ArsyncException(
            icon: Icons.error_outline,
            title: 'Something\'s Not Right',
            message: errorMessage ??
                'There seems to be an issue with this request. Let\'s try again.',
            briefTitle: 'Try Again',
            briefMessage: 'Something\'s not right',
            exceptionCode: 'dio_bad_request',
          );
        case 401:
          return ArsyncException(
            icon: Icons.lock_outline,
            title: 'Sign In Needed',
            message: errorMessage ??
                'A sign in is needed to continue. The session may have expired.',
            briefTitle: 'Sign In',
            briefMessage: 'Sign in needed',
            exceptionCode: 'dio_unauthorized',
          );
        case 403:
          return ArsyncException(
            icon: Icons.no_accounts,
            title: 'Access Needed',
            message: errorMessage ??
                'Access to this feature isn\'t currently available.',
            briefTitle: 'No Access',
            briefMessage: 'Access needed',
            exceptionCode: 'dio_forbidden',
          );
        case 404:
          return ArsyncException(
            icon: Icons.find_replace,
            title: 'Not Available',
            message: errorMessage ??
                'The requested item isn\'t available right now. It may have been moved or removed.',
            briefTitle: 'Not Found',
            briefMessage: 'Item not available',
            exceptionCode: 'dio_not_found',
          );
        case 422:
          return ArsyncException(
            icon: Icons.input,
            title: 'Information Issue',
            message: errorMessage ??
                'There seems to be an issue with the information provided. A review might help.',
            briefTitle: 'Review Info',
            briefMessage: 'Information issue',
            exceptionCode: 'dio_unprocessable_entity',
          );
        case 429:
          return ArsyncException(
            icon: Icons.speed,
            title: 'Slow Down',
            message: errorMessage ??
                'Too many requests in a short time. Please wait a moment before trying again.',
            briefTitle: 'Too Fast',
            briefMessage: 'Please wait a moment',
            exceptionCode: 'dio_too_many_requests',
          );
        default:
          return ArsyncException(
            icon: Icons.error_outline,
            title: 'Request Issue',
            message: errorMessage ??
                'An issue occurred with this request. Please try again or contact support.',
            briefTitle: 'Request Issue',
            briefMessage: 'Request failed',
            exceptionCode: 'dio_client_error',
          );
      }
    }
    // Server errors (5xx)
    else if (statusCode >= 500 && statusCode < 600) {
      return ArsyncException(
        icon: Icons.cloud_off,
        title: 'Temporary Issue',
        message: errorMessage ??
            'We\'re experiencing a temporary issue. We\'re working on it and should be resolved soon.',
        briefTitle: 'Temporary Issue',
        briefMessage: 'We\'re on it',
        exceptionCode: 'dio_server_error',
      );
    }

    // Fallback for unknown status codes
    return ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Issue',
      message: errorMessage ??
          'An unexpected issue occurred. Please try again or contact support.',
      briefTitle: 'Issue',
      briefMessage: 'Unexpected issue',
      exceptionCode: 'dio_unknown_status',
    );
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  ResponseErrorHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Create a new instance with the merged exceptions
    return ResponseErrorHandler(
      errorExtractor: _errorExtractor,
      customExceptions: {...?this.customExceptions, ...customExceptions},
      priority: priority,
    );
  }

  /// Create a new instance with a different error extractor
  ResponseErrorHandler withErrorExtractor(ErrorExtractor errorExtractor) {
    return ResponseErrorHandler(
      errorExtractor: errorExtractor,
      customExceptions: customExceptions,
      priority: priority,
    );
  }
}
