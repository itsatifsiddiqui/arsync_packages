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
            title: 'Bad Request',
            message: errorMessage ??
                'The request was invalid. Please check your input and try again.',
            briefTitle: 'Bad Request',
            briefMessage: 'Invalid request',
            exceptionCode: 'dio_bad_request',
          );
        case 401:
          return ArsyncException(
            icon: Icons.lock_outline,
            title: 'Authentication Required',
            message: errorMessage ??
                'You need to be signed in to access this resource. Please sign in and try again.',
            briefTitle: 'Sign In Required',
            briefMessage: 'Authentication required',
            exceptionCode: 'dio_unauthorized',
          );
        case 403:
          return ArsyncException(
            icon: Icons.no_accounts,
            title: 'Access Denied',
            message: errorMessage ??
                'You don\'t have permission to access this resource.',
            briefTitle: 'Access Denied',
            briefMessage: 'Permission denied',
            exceptionCode: 'dio_forbidden',
          );
        case 404:
          return ArsyncException(
            icon: Icons.find_replace,
            title: 'Not Found',
            message: errorMessage ??
                'The requested resource could not be found. It may have been deleted or moved.',
            briefTitle: 'Not Found',
            briefMessage: 'Resource not found',
            exceptionCode: 'dio_not_found',
          );
        case 422:
          return ArsyncException(
            icon: Icons.input,
            title: 'Validation Error',
            message: errorMessage ??
                'The request could not be processed due to validation errors. Please check your input and try again.',
            briefTitle: 'Validation Error',
            briefMessage: 'Invalid data',
            exceptionCode: 'dio_unprocessable_entity',
          );
        case 429:
          return ArsyncException(
            icon: Icons.speed,
            title: 'Too Many Requests',
            message: errorMessage ??
                'You\'ve made too many requests in a short period. Please wait a moment and try again.',
            briefTitle: 'Rate Limited',
            briefMessage: 'Too many requests',
            exceptionCode: 'dio_too_many_requests',
          );
        default:
          return ArsyncException(
            icon: Icons.error_outline,
            title: 'Request Error',
            message: errorMessage ??
                'An error occurred with your request. Please try again or contact support.',
            briefTitle: 'Request Error',
            briefMessage: 'Request failed',
            exceptionCode: 'dio_client_error',
          );
      }
    }
    // Server errors (5xx)
    else if (statusCode >= 500 && statusCode < 600) {
      return ArsyncException(
        icon: Icons.cloud_off,
        title: 'Server Error',
        message: errorMessage ??
            'The server encountered an error processing your request. Please try again later.',
        briefTitle: 'Server Error',
        briefMessage: 'Server error',
        exceptionCode: 'dio_server_error',
      );
    }

    // Fallback for unknown status codes
    return ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Error',
      message: errorMessage ??
          'An unexpected error occurred. Please try again or contact support.',
      briefTitle: 'Error',
      briefMessage: 'Unexpected error',
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
