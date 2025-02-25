import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import '../arsync_supabase_errors_handler.dart';

/// Handler specifically for Supabase Authentication exceptions
class SupabaseAuthHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Supabase Auth error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  SupabaseAuthHandler({
    this.customExceptions,
    int priority = 20,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    if (exception is AuthException) {
      return true;
    }

    // Check if the message contains auth-related keywords
    final message = exception.toString().toLowerCase();
    final conditions = [
      message.contains('auth'),
      message.contains('login'),
      message.contains('sign'),
      message.contains('password'),
      message.contains('user'),
      message.contains('token'),
      message.contains('session'),
      message.contains('jwt'),
      message.contains('authentication'),
      message.contains('auth/'),
      message.contains('unauthorized'),
      message.contains('jwt')
    ];

    return conditions.contains(true);
  }

  @override
  ArsyncException handle(Object exception) {
    String code = SupabaseErrorCodes.unknownError;
    String message = 'An authentication error occurred';

    // Extract error details depending on exception type
    if (exception is AuthException) {
      code = _extractErrorCode(exception);
      message = exception.message;
    } else {
      // For other exceptions, try to extract from the string representation
      final exceptionStr = exception.toString();
      code = _extractErrorCode(exception);
      message = exceptionStr;
    }

    // Check if this error should be ignored
    if (SupabaseErrorCodes.isIgnorable(message)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Supabase Auth: $code - $message',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Auth: $code - $message',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Auth: $code - $message',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.error_outline,
      title: 'Authentication Error',
      message: message,
      briefTitle: 'Auth Error',
      briefMessage: 'Authentication failed',
      exceptionCode: 'supabase_auth_$code',
      originalException: exception,
      technicalDetails: 'Supabase Auth: $code - $message',
    );
  }

  /// Extract an error code from the exception
  String _extractErrorCode(Object exception) {
    if (exception is AuthException) {
      // Try to extract a meaningful code from the message
      return SupabaseErrorCodes.extractErrorCode(exception.message);
    } else {
      // For general exceptions, use the string representation
      return SupabaseErrorCodes.extractErrorCode(exception.toString());
    }
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  SupabaseAuthHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return SupabaseAuthHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Supabase Auth errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    SupabaseErrorCodes.invalidCredentials: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Invalid Credentials',
      message:
          'The email or password you entered is incorrect. Please try again.',
      briefTitle: 'Sign In Failed',
      briefMessage: 'Invalid email or password',
      exceptionCode: 'supabase_auth_invalid_credentials',
    ),
    SupabaseErrorCodes.userNotFound: ArsyncException(
      icon: Icons.person_off_outlined,
      title: 'Account Not Found',
      message:
          'We couldn\'t find an account with these credentials. Please check your email or create a new account.',
      briefTitle: 'Not Found',
      briefMessage: 'Account not found',
      exceptionCode: 'supabase_auth_user_not_found',
    ),
    SupabaseErrorCodes.emailNotConfirmed: ArsyncException(
      icon: Icons.mark_email_unread_outlined,
      title: 'Email Not Verified',
      message:
          'Please verify your email address before signing in. Check your inbox for a verification link.',
      briefTitle: 'Verify Email',
      briefMessage: 'Email not verified',
      exceptionCode: 'supabase_auth_email_not_confirmed',
    ),
    SupabaseErrorCodes.invalidToken: ArsyncException(
      icon: Icons.token,
      title: 'Invalid Token',
      message: 'Your authentication token is invalid. Please sign in again.',
      briefTitle: 'Invalid Token',
      briefMessage: 'Authentication token invalid',
      exceptionCode: 'supabase_auth_invalid_token',
    ),
    SupabaseErrorCodes.tokenExpired: ArsyncException(
      icon: Icons.timelapse,
      title: 'Session Expired',
      message: 'Your session has expired. Please sign in again to continue.',
      briefTitle: 'Session Expired',
      briefMessage: 'Please sign in again',
      exceptionCode: 'supabase_auth_token_expired',
    ),
    SupabaseErrorCodes.invalidEmail: ArsyncException(
      icon: Icons.alternate_email,
      title: 'Invalid Email',
      message: 'Please enter a valid email address.',
      briefTitle: 'Invalid Email',
      briefMessage: 'Invalid email format',
      exceptionCode: 'supabase_auth_invalid_email',
    ),
    SupabaseErrorCodes.weakPassword: ArsyncException(
      icon: Icons.password,
      title: 'Weak Password',
      message:
          'Please choose a stronger password. Use at least 8 characters with a mix of letters, numbers, and symbols.',
      briefTitle: 'Weak Password',
      briefMessage: 'Password too weak',
      exceptionCode: 'supabase_auth_weak_password',
    ),
    SupabaseErrorCodes.userAlreadyExists: ArsyncException(
      icon: Icons.person_add_disabled,
      title: 'User Already Exists',
      message:
          'An account with this email already exists. Please try signing in instead.',
      briefTitle: 'Account Exists',
      briefMessage: 'User already exists',
      exceptionCode: 'supabase_auth_user_already_exists',
    ),
    SupabaseErrorCodes.emailTaken: ArsyncException(
      icon: Icons.email,
      title: 'Email Already Registered',
      message:
          'This email address is already registered. Please use a different email or try signing in.',
      briefTitle: 'Email Taken',
      briefMessage: 'Email already registered',
      exceptionCode: 'supabase_auth_email_taken',
    ),
    SupabaseErrorCodes.invalidMfaType: ArsyncException(
      icon: Icons.security,
      title: 'Invalid MFA Type',
      message:
          'The multi-factor authentication type you selected is not supported.',
      briefTitle: 'Invalid MFA',
      briefMessage: 'Unsupported MFA type',
      exceptionCode: 'supabase_auth_invalid_mfa_type',
    ),
    SupabaseErrorCodes.mfaNotEnabled: ArsyncException(
      icon: Icons.security,
      title: 'MFA Not Enabled',
      message: 'Multi-factor authentication is not enabled for your account.',
      briefTitle: 'MFA Not Enabled',
      briefMessage: 'MFA not enabled',
      exceptionCode: 'supabase_auth_mfa_not_enabled',
    ),
    SupabaseErrorCodes.invalidMfaCode: ArsyncException(
      icon: Icons.pin,
      title: 'Invalid MFA Code',
      message:
          'The multi-factor authentication code you entered is incorrect. Please try again.',
      briefTitle: 'Invalid Code',
      briefMessage: 'Incorrect MFA code',
      exceptionCode: 'supabase_auth_invalid_mfa_code',
    ),
    SupabaseErrorCodes.phoneAlreadyConfirmed: ArsyncException(
      icon: Icons.phone_android,
      title: 'Phone Already Confirmed',
      message:
          'This phone number has already been confirmed for another account.',
      briefTitle: 'Phone In Use',
      briefMessage: 'Phone number already confirmed',
      exceptionCode: 'supabase_auth_phone_already_confirmed',
    ),
    SupabaseErrorCodes.networkError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to the authentication service. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'supabase_auth_network_error',
    ),
    SupabaseErrorCodes.timeoutError: ArsyncException(
      icon: Icons.timer_off,
      title: 'Connection Timeout',
      message:
          'The authentication request timed out. Please check your connection and try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Request timed out',
      exceptionCode: 'supabase_auth_timeout_error',
    ),
    SupabaseErrorCodes.rateLimited: ArsyncException(
      icon: Icons.speed,
      title: 'Too Many Attempts',
      message:
          'You\'ve made too many authentication attempts. Please wait a few moments and try again.',
      briefTitle: 'Rate Limited',
      briefMessage: 'Too many attempts',
      exceptionCode: 'supabase_auth_rate_limited',
    ),
    SupabaseErrorCodes.serverError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Server Error',
      message:
          'The authentication server encountered an error. Please try again later.',
      briefTitle: 'Server Error',
      briefMessage: 'Authentication server error',
      exceptionCode: 'supabase_auth_server_error',
    ),
    SupabaseErrorCodes.unknownError: ArsyncException(
      icon: Icons.help_outline,
      title: 'Authentication Error',
      message:
          'An unexpected authentication error occurred. Please try again or contact support.',
      briefTitle: 'Auth Error',
      briefMessage: 'Authentication failed',
      exceptionCode: 'supabase_auth_unknown_error',
    ),
  };
}
