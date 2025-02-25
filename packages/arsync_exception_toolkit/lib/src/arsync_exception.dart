// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

/// Represents a standardized application exception with user-friendly information.
///
/// This class converts raw exceptions into a format that can be displayed to users,
/// with both detailed and brief versions of the error information.
class ArsyncException {
  /// Icon representing the exception type
  final IconData icon;

  /// Full title of the exception
  final String title;

  /// Detailed exception message
  final String message;

  /// Short title for brief notifications
  final String briefTitle;

  /// Short message for brief notifications
  final String briefMessage;

  /// Optional exception code for identifying specific exceptions
  final String? exceptionCode;

  /// Original exception that caused this AppException
  final Object? originalException;

  /// Optional technical details (for debugging)
  final String? technicalDetails;

  /// Create an app exception with required and optional information
  const ArsyncException({
    required this.icon,
    required this.title,
    required this.message,
    required this.briefTitle,
    required this.briefMessage,
    this.exceptionCode,
    this.originalException,
    this.technicalDetails,
  });

  /// Creates a copy of the exception with modified fields
  ArsyncException copyWith({
    IconData? icon,
    String? title,
    String? message,
    String? briefTitle,
    String? briefMessage,
    String? exceptionCode,
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      message: message ?? this.message,
      briefTitle: briefTitle ?? this.briefTitle,
      briefMessage: briefMessage ?? this.briefMessage,
      exceptionCode: exceptionCode ?? this.exceptionCode,
      originalException: originalException ?? this.originalException,
      technicalDetails: technicalDetails ?? this.technicalDetails,
    );
  }

  /// Create a network exception
  factory ArsyncException.network({
    IconData icon = Icons.wifi_off,
    String title = 'Network Error',
    String message =
        'Unable to connect to the network. Please check your internet connection and try again.',
    String briefTitle = 'Network Error',
    String briefMessage = 'No internet connection',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'network_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a timeout exception
  factory ArsyncException.timeout({
    IconData icon = Icons.timer_off,
    String title = 'Timeout Error',
    String message =
        'The operation took too long to complete. Please try again later.',
    String briefTitle = 'Timeout',
    String briefMessage = 'Operation timed out',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'timeout_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a generic exception
  factory ArsyncException.generic({
    IconData icon = Icons.error_outline,
    String title = 'Unexpected Error',
    String message = 'An unexpected error occurred.',
    String briefTitle = 'Error',
    String briefMessage = 'Something went wrong',
    String? exceptionCode,
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: exceptionCode ?? 'unknown_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a permission exception
  factory ArsyncException.permission({
    IconData icon = Icons.no_accounts,
    String title = 'Permission Denied',
    String message = 'The application doesn\'t have the required permissions.',
    String briefTitle = 'Permission Error',
    String briefMessage = 'Permission required',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'permission_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a not found exception
  factory ArsyncException.notFound({
    IconData icon = Icons.find_replace,
    String title = 'Not Found',
    String message = 'The requested resource could not be found.',
    String briefTitle = 'Not Found',
    String briefMessage = 'Resource not found',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'not_found_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create an authentication exception
  factory ArsyncException.authentication({
    IconData icon = Icons.lock_outline,
    String title = 'Authentication Error',
    String message =
        'There was a problem with your authentication. Please sign in again.',
    String briefTitle = 'Auth Error',
    String briefMessage = 'Authentication failed',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'auth_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a server exception
  factory ArsyncException.server({
    IconData icon = Icons.cloud_off,
    String title = 'Server Error',
    String message = 'The server encountered an error. Please try again later.',
    String briefTitle = 'Server Error',
    String briefMessage = 'Server error occurred',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'server_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a cancelled operation exception
  factory ArsyncException.ignored({
    IconData icon = Icons.cancel_outlined,
    String title = 'Operation Ignored',
    String message = 'The operation was ignored.',
    String briefTitle = 'Ignored',
    String briefMessage = 'Operation ignored',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'ignored_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create a format exception
  factory ArsyncException.format({
    IconData icon = Icons.data_object,
    String title = 'Format Error',
    String message = 'The data format is invalid or could not be processed.',
    String briefTitle = 'Format Error',
    String briefMessage = 'Invalid data format',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'format_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  /// Create an unsupported operation exception
  factory ArsyncException.unsupported({
    IconData icon = Icons.block,
    String title = 'Unsupported Operation',
    String message = 'This operation is not supported.',
    String briefTitle = 'Unsupported',
    String briefMessage = 'Operation not supported',
    Object? originalException,
    String? technicalDetails,
  }) {
    return ArsyncException(
      icon: icon,
      title: title,
      message: message,
      briefTitle: briefTitle,
      briefMessage: briefMessage,
      exceptionCode: 'unsupported_error',
      originalException: originalException,
      technicalDetails: technicalDetails ?? originalException?.toString(),
    );
  }

  @override
  String toString() {
    return 'ArsyncException(icon: $icon, title: $title, message: $message, briefTitle: $briefTitle, briefMessage: $briefMessage, exceptionCode: $exceptionCode, originalException: $originalException, technicalDetails: $technicalDetails)';
  }

  @override
  bool operator ==(covariant ArsyncException other) {
    if (identical(this, other)) return true;

    return other.icon == icon &&
        other.title == title &&
        other.message == message &&
        other.briefTitle == briefTitle &&
        other.briefMessage == briefMessage &&
        other.exceptionCode == exceptionCode &&
        other.originalException == originalException &&
        other.technicalDetails == technicalDetails;
  }

  @override
  int get hashCode {
    return icon.hashCode ^
        title.hashCode ^
        message.hashCode ^
        briefTitle.hashCode ^
        briefMessage.hashCode ^
        exceptionCode.hashCode ^
        originalException.hashCode ^
        technicalDetails.hashCode;
  }

  bool get isNetworkError => exceptionCode == 'network_error';

  bool get isTimeoutError => exceptionCode == 'timeout_error';

  bool get isGenericError => exceptionCode == 'unknown_error';

  bool get isPermissionError => exceptionCode == 'permission_error';

  bool get isNotFoundError => exceptionCode == 'not_found_error';

  bool get isAuthError => exceptionCode == 'auth_error';

  bool get isServerError => exceptionCode == 'server_error';

  bool get isIgnoredError => exceptionCode == 'ignored_error';

  // Alias for isIgnoredError
  bool get shouldIgnore => isIgnoredError;
}
