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
      title: 'Connection Issue',
      message:
          'We\'re having trouble connecting right now. A network check might help.',
      briefTitle: 'Connection Issue',
      briefMessage: 'Network connection needed',
      exceptionCode: 'dio_connection_timeout',
    ),

    DioErrorCodes.sendTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Connection Slow',
      message:
          'The connection seems a bit slow right now. A stronger signal might help.',
      briefTitle: 'Slow Connection',
      briefMessage: 'Connection is slow',
      exceptionCode: 'dio_send_timeout',
    ),

    DioErrorCodes.receiveTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Taking Too Long',
      message:
          'We\'re having trouble getting a response. Please try again in a moment.',
      briefTitle: 'No Response',
      briefMessage: 'Taking too long',
      exceptionCode: 'dio_receive_timeout',
    ),

    DioErrorCodes.connectionError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Lost',
      message:
          'It looks like the network is offline. A connection check might help.',
      briefTitle: 'Offline',
      briefMessage: 'Connection needed',
      exceptionCode: 'dio_connection_error',
    ),

    DioErrorCodes.badCertificate: ArsyncException(
      icon: Icons.security,
      title: 'Security Check',
      message:
          'We\'ve detected a security issue with the connection. Please contact support.',
      briefTitle: 'Security Issue',
      briefMessage: 'Security check failed',
      exceptionCode: 'dio_bad_certificate',
    ),

    DioErrorCodes.cancel: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Request Stopped',
      message: 'This request was stopped.',
      briefTitle: 'Stopped',
      briefMessage: 'Request stopped',
      exceptionCode: 'dio_cancel',
    ),

    // HTTP status code errors
    DioErrorCodes.badRequest: ArsyncException(
      icon: Icons.error_outline,
      title: 'Something\'s Not Right',
      message:
          'There seems to be an issue with this request. Let\'s try again.',
      briefTitle: 'Try Again',
      briefMessage: 'Something\'s not right',
      exceptionCode: 'dio_bad_request',
    ),

    DioErrorCodes.unauthorized: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Sign In Needed',
      message: 'A sign in is needed to continue. The session may have expired.',
      briefTitle: 'Sign In',
      briefMessage: 'Sign in needed',
      exceptionCode: 'dio_unauthorized',
    ),

    DioErrorCodes.forbidden: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Access Needed',
      message: 'Access to this feature isn\'t currently available.',
      briefTitle: 'No Access',
      briefMessage: 'Access needed',
      exceptionCode: 'dio_forbidden',
    ),

    DioErrorCodes.notFound: ArsyncException(
      icon: Icons.find_replace,
      title: 'Not Available',
      message:
          'The requested item isn\'t available right now. It may have been moved or removed.',
      briefTitle: 'Not Found',
      briefMessage: 'Item not available',
      exceptionCode: 'dio_not_found',
    ),

    DioErrorCodes.methodNotAllowed: ArsyncException(
      icon: Icons.block,
      title: 'Action Unavailable',
      message: 'This action isn\'t available right now.',
      briefTitle: 'Unavailable',
      briefMessage: 'Action unavailable',
      exceptionCode: 'dio_method_not_allowed',
    ),

    DioErrorCodes.requestTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Request Timed Out',
      message: 'The request is taking longer than expected. Please try again.',
      briefTitle: 'Timed Out',
      briefMessage: 'Please try again',
      exceptionCode: 'dio_request_timeout',
    ),

    DioErrorCodes.conflict: ArsyncException(
      icon: Icons.sync_problem,
      title: 'Update Conflict',
      message: 'This information may have been updated. A refresh might help.',
      briefTitle: 'Conflict',
      briefMessage: 'Update conflict',
      exceptionCode: 'dio_conflict',
    ),

    DioErrorCodes.unprocessableEntity: ArsyncException(
      icon: Icons.input,
      title: 'Information Issue',
      message:
          'There seems to be an issue with the information provided. A review might help.',
      briefTitle: 'Review Info',
      briefMessage: 'Information issue',
      exceptionCode: 'dio_unprocessable_entity',
    ),

    DioErrorCodes.tooManyRequests: ArsyncException(
      icon: Icons.speed,
      title: 'Slow Down',
      message:
          'Too many requests in a short time. Please wait a moment before trying again.',
      briefTitle: 'Too Fast',
      briefMessage: 'Please wait a moment',
      exceptionCode: 'dio_too_many_requests',
    ),

    DioErrorCodes.internalServerError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Temporary Issue',
      message:
          'We\'re experiencing a temporary issue. We\'re working on it and should be resolved soon.',
      briefTitle: 'Temporary Issue',
      briefMessage: 'We\'re on it',
      exceptionCode: 'dio_internal_server_error',
    ),

    DioErrorCodes.badGateway: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Service Issue',
      message:
          'We\'re having some trouble with our service. Please try again in a moment.',
      briefTitle: 'Service Issue',
      briefMessage: 'Please try again soon',
      exceptionCode: 'dio_bad_gateway',
    ),

    DioErrorCodes.serviceUnavailable: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Service Unavailable',
      message:
          'This service is temporarily unavailable. We\'ll be back up shortly.',
      briefTitle: 'Unavailable',
      briefMessage: 'Service unavailable',
      exceptionCode: 'dio_service_unavailable',
    ),

    DioErrorCodes.gatewayTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Service Timeout',
      message:
          'Our service is taking longer than expected to respond. Please try again in a moment.',
      briefTitle: 'Timeout',
      briefMessage: 'Service timeout',
      exceptionCode: 'dio_gateway_timeout',
    ),

    DioErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Connection Issue',
      message:
          'Something unexpected happened with the connection. Please try again.',
      briefTitle: 'Connection Issue',
      briefMessage: 'Please try again',
      exceptionCode: 'dio_unknown',
    ),
  };
}
