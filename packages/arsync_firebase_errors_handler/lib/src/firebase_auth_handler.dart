import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    show FirebaseAuthException;
import 'package:flutter/material.dart';

import 'firebase_error_codes.dart';

/// Handler specifically for Firebase Authentication exceptions
class FirebaseAuthHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Firebase Auth error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  FirebaseAuthHandler({
    this.customExceptions,
    int priority = 20,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    return exception is FirebaseAuthException;
  }

  @override
  ArsyncException handle(Object exception) {
    final authException = exception as FirebaseAuthException;
    final code = authException.code;

    // Handle ignorable exceptions
    if (FirebaseErrorCodes.isIgnorable(code)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Firebase Auth: $code - ${authException.message}',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Firebase Auth: $code - ${authException.message}',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Firebase Auth: $code - ${authException.message}',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.error_outline,
      title: 'Authentication Error',
      message: authException.message ??
          'An unexpected authentication error occurred',
      briefTitle: 'Auth Error',
      briefMessage: 'Authentication failed',
      exceptionCode: 'firebase_auth_$code',
      originalException: exception,
      technicalDetails: 'Firebase Auth: $code - ${authException.message}',
    );
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  FirebaseAuthHandler withCustomExceptions(
    Map<String, ArsyncException> customExceptions,
  ) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return FirebaseAuthHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Firebase Auth errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    FirebaseErrorCodes.userNotFound: ArsyncException(
      icon: Icons.person_off_outlined,
      title: 'Account Not Found',
      message:
          'We couldn\'t find an account with these credentials. Please check your email or create a new account.',
      briefTitle: 'Not Found',
      briefMessage: 'Account not found',
      exceptionCode: 'firebase_auth_user_not_found',
    ),
    FirebaseErrorCodes.wrongPassword: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Incorrect Password',
      message:
          'The password you entered is incorrect. You can reset your password if you\'ve forgotten it.',
      briefTitle: 'Wrong Password',
      briefMessage: 'Wrong password',
      exceptionCode: 'firebase_auth_wrong_password',
    ),
    FirebaseErrorCodes.emailAlreadyInUse: ArsyncException(
      icon: Icons.email,
      title: 'Email Already Registered',
      message:
          'An account with this email already exists. Please try signing in or use a different email address.',
      briefTitle: 'Email Taken',
      briefMessage: 'Email already registered',
      exceptionCode: 'firebase_auth_email_already_in_use',
    ),
    FirebaseErrorCodes.invalidEmail: ArsyncException(
      icon: Icons.alternate_email,
      title: 'Invalid Email',
      message: 'Please enter a valid email address.',
      briefTitle: 'Invalid Email',
      briefMessage: 'Invalid email format',
      exceptionCode: 'firebase_auth_invalid_email',
    ),
    FirebaseErrorCodes.weakPassword: ArsyncException(
      icon: Icons.security,
      title: 'Weak Password',
      message:
          'Please choose a stronger password. Use at least 8 characters with a mix of letters, numbers, and symbols.',
      briefTitle: 'Weak Password',
      briefMessage: 'Password too weak',
      exceptionCode: 'firebase_auth_weak_password',
    ),
    FirebaseErrorCodes.invalidVerificationCode: ArsyncException(
      icon: Icons.qr_code,
      title: 'Invalid Code',
      message:
          'The verification code you entered is incorrect. Please check and try again.',
      briefTitle: 'Invalid Code',
      briefMessage: 'Wrong verification code',
      exceptionCode: 'firebase_auth_invalid_verification_code',
    ),
    FirebaseErrorCodes.invalidVerificationId: ArsyncException(
      icon: Icons.qr_code_2,
      title: 'Verification Expired',
      message:
          'Your verification session has expired. Please request a new verification code.',
      briefTitle: 'Expired',
      briefMessage: 'Verification expired',
      exceptionCode: 'firebase_auth_invalid_verification_id',
    ),
    FirebaseErrorCodes.operationNotAllowed: ArsyncException(
      icon: Icons.block,
      title: 'Operation Not Allowed',
      message:
          'This sign-in method is not enabled. Please contact support if you think this is a mistake.',
      briefTitle: 'Not Allowed',
      briefMessage: 'Operation not permitted',
      exceptionCode: 'firebase_auth_operation_not_allowed',
    ),
    FirebaseErrorCodes.userDisabled: ArsyncException(
      icon: Icons.person_off,
      title: 'Account Suspended',
      message:
          'Your account has been suspended. Please contact support for assistance.',
      briefTitle: 'Account Suspended',
      briefMessage: 'Account suspended',
      exceptionCode: 'firebase_auth_user_disabled',
    ),
    FirebaseErrorCodes.providerAlreadyLinked: ArsyncException(
      icon: Icons.link,
      title: 'Account Already Linked',
      message:
          'This authentication method is already connected to your account.',
      briefTitle: 'Already Linked',
      briefMessage: 'Already linked',
      exceptionCode: 'firebase_auth_provider_already_linked',
    ),
    FirebaseErrorCodes.invalidCredential: ArsyncException(
      icon: Icons.lock_open,
      title: 'Invalid Login Details',
      message:
          'The login details you provided are incorrect. Please try again.',
      briefTitle: 'Invalid Credentials',
      briefMessage: 'Invalid credentials',
      exceptionCode: 'firebase_auth_invalid_credential',
    ),
    FirebaseErrorCodes.credentialAlreadyInUse: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Credential In Use',
      message: 'These login credentials are already linked to another account.',
      briefTitle: 'Credentials Taken',
      briefMessage: 'Credentials already in use',
      exceptionCode: 'firebase_auth_credential_already_in_use',
    ),
    FirebaseErrorCodes.accountExistsWithDifferentCredential: ArsyncException(
      icon: Icons.account_circle,
      title: 'Account Exists',
      message:
          'An account already exists with this email. Try signing in with a different method.',
      briefTitle: 'Try Different Sign-in',
      briefMessage: 'Account exists with different credential',
      exceptionCode: 'firebase_auth_account_exists_with_different_credential',
    ),
    FirebaseErrorCodes.tooManyRequests: ArsyncException(
      icon: Icons.schedule,
      title: 'Too Many Attempts',
      message:
          'Access temporarily blocked due to many failed attempts. Please try again later.',
      briefTitle: 'Too Many Attempts',
      briefMessage: 'Access temporarily blocked',
      exceptionCode: 'firebase_auth_too_many_requests',
    ),
    FirebaseErrorCodes.requiresRecentLogin: ArsyncException(
      icon: Icons.login,
      title: 'Re-authentication Needed',
      message:
          'For security reasons, please sign in again to continue with this sensitive operation.',
      briefTitle: 'Sign In Again',
      briefMessage: 'Please sign in again',
      exceptionCode: 'firebase_auth_requires_recent_login',
    ),
    FirebaseErrorCodes.networkRequestFailed: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to our servers. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'firebase_auth_network_request_failed',
    ),
    FirebaseErrorCodes.timeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Connection Timeout',
      message:
          'The request took too long to complete. Please check your connection and try again.',
      briefTitle: 'Request Timeout',
      briefMessage: 'Request timeout',
      exceptionCode: 'firebase_auth_timeout',
    ),
    FirebaseErrorCodes.internalError: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'System Error',
      message:
          'Something went wrong on our end. We\'re working to fix it. Please try again later.',
      briefTitle: 'System Error',
      briefMessage: 'System error',
      exceptionCode: 'firebase_auth_internal_error',
    ),
    FirebaseErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Error',
      message:
          'An unexpected error occurred. Please try again or contact support if the problem persists.',
      briefTitle: 'Unknown Error',
      briefMessage: 'Unknown error',
      exceptionCode: 'firebase_auth_unknown',
    ),
  };
}
