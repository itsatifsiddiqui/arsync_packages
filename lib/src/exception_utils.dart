import 'dart:io';

import '../arsync_exception_toolkit.dart';

/// Utility functions for working with exceptions.
class ExceptionUtils {
  /// Detect if the exception is related to network connectivity.
  ///
  /// Returns true if the exception appears to be a network connectivity issue.
  static bool isNetworkConnectivityIssue(Object exception) {
    if (exception is SocketException) return true;

    final conditions = [
      'socketexception',
      'network',
      'connection',
      'connectivity',
      'internet',
      'timeout',
      'host lookup',
      'failed to connect',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }

  /// Detect if the exception is related to server issues.
  ///
  /// Returns true if the exception appears to be caused by server-side problems.
  static bool isServerIssue(Object exception) {
    final conditions = [
      'server error',
      'internal server',
      '500',
      '503',
      '502',
      'service unavailable',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }

  /// Detect if the exception is related to authentication.
  ///
  /// Returns true if the exception appears to be an authentication issue.
  static bool isAuthenticationIssue(Object exception) {
    final conditions = [
      'authentication',
      'auth',
      'unauthenticated',
      'unauthorized',
      'not authorized',
      'permission denied',
      'invalid token',
      '401',
      '403',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }

  /// Detect if the exception is a not found error.
  ///
  /// Returns true if the exception appears to be a not found issue.
  static bool isNotFoundIssue(Object exception) {
    final conditions = [
      'not found',
      'no such',
      'doesn\'t exist',
      'does not exist',
      '404',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }

  /// Get the most appropriate AppException based on the exception type.
  ///
  /// [exception] - The exception to analyze.
  /// [defaultMessage] - Optional default message if type cannot be determined.
  static ArsyncException getAppropriateAppException(
    Object exception, {
    String? defaultMessage,
  }) {
    // Check for specific exception types
    if (isNetworkConnectivityIssue(exception)) {
      return ArsyncException.network(originalException: exception);
    }

    if (isServerIssue(exception)) {
      return ArsyncException.server(originalException: exception);
    }

    if (isAuthenticationIssue(exception)) {
      return ArsyncException.authentication(originalException: exception);
    }

    if (isNotFoundIssue(exception)) {
      return ArsyncException.notFound(originalException: exception);
    }

    // Default to generic exception
    return ArsyncException.generic(
      message: defaultMessage ?? 'An unexpected error occurred.',
      originalException: exception,
    );
  }

  static bool isTimeoutIssue(Object exception) {
    final conditions = [
      'timeout',
      'timed out',
      'connection timed out',
      'request timed out',
      'timeout error',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }

  static bool isFormatIssue(Object exception) {
    final conditions = [
      'format',
      'parse',
      'syntax',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }

  static bool isUnsupportedIssue(Object exception) {
    final conditions = [
      'unsupported',
      'not supported',
      'not implemented',
    ];

    final message = exception.toString().toLowerCase();
    return conditions.any(message.contains);
  }
}
