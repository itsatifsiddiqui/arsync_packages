import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dio_error_codes.dart';

/// Handler specifically for Dio exceptions
class DioErrorHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Dio error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  DioErrorHandler({
    this.customExceptions,
    int priority = 20,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    return exception is DioException;
  }

  @override
  ArsyncException handle(Object exception) {
    final dioException = exception as DioException;
    final dioErrorType = dioException.type;

    // Convert DioErrorType to a string code
    final code = _getErrorCode(dioErrorType, dioException);

    // Handle ignorable exceptions
    if (DioErrorCodes.isIgnorable(code)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Dio: $code - ${dioException.message}',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Dio: $code - ${dioException.message}',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Dio: $code - ${dioException.message}',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.error_outline,
      title: 'Network Error',
      message: dioException.message ?? 'An unexpected network error occurred',
      briefTitle: 'Network Error',
      briefMessage: 'Network operation failed',
      exceptionCode: 'dio_$code',
      originalException: exception,
      technicalDetails: 'Dio: $code - ${dioException.message}',
    );
  }

  /// Get the error code based on the DioErrorType and status code
  String _getErrorCode(DioExceptionType errorType, DioException exception) {
    // First check for specific HTTP status codes in the response
    if (errorType == DioExceptionType.badResponse &&
        exception.response != null) {
      final statusCode = exception.response!.statusCode;

      // Return specific HTTP status code strings for common codes
      switch (statusCode) {
        case 400:
          return DioErrorCodes.badRequest;
        case 401:
          return DioErrorCodes.unauthorized;
        case 403:
          return DioErrorCodes.forbidden;
        case 404:
          return DioErrorCodes.notFound;
        case 405:
          return DioErrorCodes.methodNotAllowed;
        case 408:
          return DioErrorCodes.requestTimeout;
        case 409:
          return DioErrorCodes.conflict;
        case 422:
          return DioErrorCodes.unprocessableEntity;
        case 429:
          return DioErrorCodes.tooManyRequests;
        case 500:
          return DioErrorCodes.internalServerError;
        case 502:
          return DioErrorCodes.badGateway;
        case 503:
          return DioErrorCodes.serviceUnavailable;
        case 504:
          return DioErrorCodes.gatewayTimeout;
        default:
          // For other status codes, use the status code value
          return 'http_$statusCode';
      }
    }

    // If no status code is available, use the DioErrorType
    switch (errorType) {
      case DioExceptionType.connectionTimeout:
        return DioErrorCodes.connectionTimeout;
      case DioExceptionType.sendTimeout:
        return DioErrorCodes.sendTimeout;
      case DioExceptionType.receiveTimeout:
        return DioErrorCodes.receiveTimeout;
      case DioExceptionType.badCertificate:
        return DioErrorCodes.badCertificate;
      case DioExceptionType.connectionError:
        return DioErrorCodes.connectionError;
      case DioExceptionType.cancel:
        return DioErrorCodes.cancel;
      case DioExceptionType.unknown:
        return DioErrorCodes.unknown;
      default:
        return DioErrorCodes.unknown;
    }
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  DioErrorHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return DioErrorHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Dio errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    // Connection-related errors
    DioErrorCodes.connectionTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Connection Timeout',
      message:
          'The connection to the server timed out. Please check your internet connection and try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Connection timed out',
      exceptionCode: 'dio_connection_timeout',
    ),

    DioErrorCodes.sendTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Send Timeout',
      message:
          'The request took too long to send. Please check your internet connection and try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Request timed out',
      exceptionCode: 'dio_send_timeout',
    ),

    DioErrorCodes.receiveTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Receive Timeout',
      message: 'The server took too long to respond. Please try again later.',
      briefTitle: 'Timeout',
      briefMessage: 'Response timed out',
      exceptionCode: 'dio_receive_timeout',
    ),

    DioErrorCodes.connectionError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to the server. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Connection failed',
      exceptionCode: 'dio_connection_error',
    ),

    DioErrorCodes.badCertificate: ArsyncException(
      icon: Icons.security,
      title: 'Security Error',
      message:
          'There was a problem with the server\'s security certificate. Please contact support.',
      briefTitle: 'Security Error',
      briefMessage: 'Certificate error',
      exceptionCode: 'dio_bad_certificate',
    ),

    DioErrorCodes.cancel: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Request Cancelled',
      message: 'The request was cancelled.',
      briefTitle: 'Cancelled',
      briefMessage: 'Request cancelled',
      exceptionCode: 'dio_cancel',
    ),

    // HTTP status code errors
    DioErrorCodes.badRequest: ArsyncException(
      icon: Icons.error_outline,
      title: 'Bad Request',
      message:
          'The request was invalid. Please check your input and try again.',
      briefTitle: 'Bad Request',
      briefMessage: 'Invalid request',
      exceptionCode: 'dio_bad_request',
    ),

    DioErrorCodes.unauthorized: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Authentication Required',
      message:
          'You need to be signed in to access this resource. Please sign in and try again.',
      briefTitle: 'Sign In Required',
      briefMessage: 'Authentication required',
      exceptionCode: 'dio_unauthorized',
    ),

    DioErrorCodes.forbidden: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Access Denied',
      message: 'You don\'t have permission to access this resource.',
      briefTitle: 'Access Denied',
      briefMessage: 'Permission denied',
      exceptionCode: 'dio_forbidden',
    ),

    DioErrorCodes.notFound: ArsyncException(
      icon: Icons.find_replace,
      title: 'Not Found',
      message:
          'The requested resource could not be found. It may have been deleted or moved.',
      briefTitle: 'Not Found',
      briefMessage: 'Resource not found',
      exceptionCode: 'dio_not_found',
    ),

    DioErrorCodes.methodNotAllowed: ArsyncException(
      icon: Icons.block,
      title: 'Method Not Allowed',
      message: 'The request method is not supported for this resource.',
      briefTitle: 'Method Not Allowed',
      briefMessage: 'Method not allowed',
      exceptionCode: 'dio_method_not_allowed',
    ),

    DioErrorCodes.requestTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Request Timeout',
      message:
          'The server timed out waiting for the request. Please try again later.',
      briefTitle: 'Timeout',
      briefMessage: 'Request timed out',
      exceptionCode: 'dio_request_timeout',
    ),

    DioErrorCodes.conflict: ArsyncException(
      icon: Icons.sync_problem,
      title: 'Resource Conflict',
      message:
          'The request could not be completed due to a conflict with the current state of the resource.',
      briefTitle: 'Conflict',
      briefMessage: 'Resource conflict',
      exceptionCode: 'dio_conflict',
    ),

    DioErrorCodes.unprocessableEntity: ArsyncException(
      icon: Icons.input,
      title: 'Validation Error',
      message:
          'The request could not be processed due to validation errors. Please check your input and try again.',
      briefTitle: 'Validation Error',
      briefMessage: 'Invalid data',
      exceptionCode: 'dio_unprocessable_entity',
    ),

    DioErrorCodes.tooManyRequests: ArsyncException(
      icon: Icons.speed,
      title: 'Too Many Requests',
      message:
          'You\'ve made too many requests in a short period. Please wait a moment and try again.',
      briefTitle: 'Rate Limited',
      briefMessage: 'Too many requests',
      exceptionCode: 'dio_too_many_requests',
    ),

    DioErrorCodes.internalServerError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Server Error',
      message:
          'The server encountered an internal error. Please try again later or contact support if the problem persists.',
      briefTitle: 'Server Error',
      briefMessage: 'Internal server error',
      exceptionCode: 'dio_internal_server_error',
    ),

    DioErrorCodes.badGateway: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Bad Gateway',
      message:
          'The server received an invalid response from an upstream server. Please try again later.',
      briefTitle: 'Server Error',
      briefMessage: 'Bad gateway',
      exceptionCode: 'dio_bad_gateway',
    ),

    DioErrorCodes.serviceUnavailable: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Service Unavailable',
      message:
          'The service is temporarily unavailable. Please try again later.',
      briefTitle: 'Service Down',
      briefMessage: 'Service unavailable',
      exceptionCode: 'dio_service_unavailable',
    ),

    DioErrorCodes.gatewayTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Gateway Timeout',
      message:
          'The server did not receive a timely response from an upstream server. Please try again later.',
      briefTitle: 'Timeout',
      briefMessage: 'Gateway timeout',
      exceptionCode: 'dio_gateway_timeout',
    ),

    DioErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Network Error',
      message:
          'An unexpected network error occurred. Please try again or contact support if the problem persists.',
      briefTitle: 'Network Error',
      briefMessage: 'Unknown error',
      exceptionCode: 'dio_unknown',
    ),
  };
}
