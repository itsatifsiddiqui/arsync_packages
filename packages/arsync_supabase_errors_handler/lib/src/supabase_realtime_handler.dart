import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';

import 'supabase_error_codes.dart';

/// Handler specifically for Supabase Realtime exceptions
class SupabaseRealtimeHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Supabase Realtime error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  SupabaseRealtimeHandler({
    this.customExceptions,
    int priority = 15,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    // Check regular exceptions with realtime-related messages
    final exceptionStr = exception.toString().toLowerCase();
    return exceptionStr.contains('realtime') ||
        exceptionStr.contains('subscription') ||
        exceptionStr.contains('channel') ||
        exceptionStr.contains('websocket');
  }

  @override
  ArsyncException handle(Object exception) {
    String code = SupabaseErrorCodes.unknownError;
    String message = 'A realtime error occurred';

    // For other exceptions, try to extract from the string representation
    final exceptionStr = exception.toString();
    code = _extractErrorCode(exception);
    message = exceptionStr;

    // Check if this error should be ignored
    if (SupabaseErrorCodes.isIgnorable(message)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Supabase Realtime: $code - $message',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Realtime: $code - $message',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Realtime: $code - $message',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.sync_problem,
      title: 'Realtime Error',
      message: message,
      briefTitle: 'Realtime Error',
      briefMessage: 'Realtime operation failed',
      exceptionCode: 'supabase_realtime_$code',
      originalException: exception,
      technicalDetails: 'Supabase Realtime: $code - $message',
    );
  }

  /// Extract an error code from the exception
  String _extractErrorCode(Object exception) {
    // For general exceptions, use the string representation
    return SupabaseErrorCodes.extractErrorCode(exception.toString());
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  SupabaseRealtimeHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return SupabaseRealtimeHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Supabase Realtime errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    SupabaseErrorCodes.connectionError: ArsyncException(
      icon: Icons.sync_disabled,
      title: 'Realtime Connection Error',
      message:
          'Unable to establish a connection to the realtime service. Please check your internet connection and try again.',
      briefTitle: 'Connection Error',
      briefMessage: 'Realtime connection failed',
      exceptionCode: 'supabase_realtime_connection_error',
    ),
    SupabaseErrorCodes.subscriptionError: ArsyncException(
      icon: Icons.notifications_off,
      title: 'Subscription Error',
      message:
          'There was an error with your realtime subscription. Please try resubscribing.',
      briefTitle: 'Subscription Error',
      briefMessage: 'Subscription failed',
      exceptionCode: 'supabase_realtime_subscription_error',
    ),
    SupabaseErrorCodes.channelError: ArsyncException(
      icon: Icons.podcasts_outlined,
      title: 'Channel Error',
      message:
          'There was an error with the realtime channel. The channel might not exist or you might not have permission.',
      briefTitle: 'Channel Error',
      briefMessage: 'Channel error occurred',
      exceptionCode: 'supabase_realtime_channel_error',
    ),
    SupabaseErrorCodes.tooManyConnections: ArsyncException(
      icon: Icons.group_off,
      title: 'Too Many Connections',
      message:
          'You\'ve reached the maximum number of realtime connections. Please close some connections and try again.',
      briefTitle: 'Too Many Connections',
      briefMessage: 'Connection limit reached',
      exceptionCode: 'supabase_realtime_too_many_connections',
    ),
    SupabaseErrorCodes.unauthorized: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Unauthorized Access',
      message: 'You don\'t have permission to access this realtime channel.',
      briefTitle: 'No Access',
      briefMessage: 'Realtime access denied',
      exceptionCode: 'supabase_realtime_unauthorized',
    ),
    SupabaseErrorCodes.networkError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Network Error',
      message:
          'Unable to connect to the realtime service. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'supabase_realtime_network_error',
    ),
    SupabaseErrorCodes.timeoutError: ArsyncException(
      icon: Icons.timer_off,
      title: 'Connection Timeout',
      message: 'The realtime connection timed out. Please try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Connection timed out',
      exceptionCode: 'supabase_realtime_timeout_error',
    ),
    SupabaseErrorCodes.rateLimited: ArsyncException(
      icon: Icons.speed,
      title: 'Too Many Requests',
      message:
          'You\'ve made too many realtime connection attempts. Please wait a few moments and try again.',
      briefTitle: 'Rate Limited',
      briefMessage: 'Too many requests',
      exceptionCode: 'supabase_realtime_rate_limited',
    ),
    SupabaseErrorCodes.serverError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Realtime Server Error',
      message:
          'The realtime server encountered an error. Please try again later.',
      briefTitle: 'Server Error',
      briefMessage: 'Realtime server error',
      exceptionCode: 'supabase_realtime_server_error',
    ),
    SupabaseErrorCodes.unknownError: ArsyncException(
      icon: Icons.help_outline,
      title: 'Realtime Error',
      message:
          'An unexpected realtime error occurred. Please try again or contact support.',
      briefTitle: 'Realtime Error',
      briefMessage: 'Realtime operation failed',
      exceptionCode: 'supabase_realtime_unknown_error',
    ),
  };
}
