import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Firebase Authentication exceptions.
///
/// Each value holds the stable `id` string that equals the original
/// hardcoded `exceptionCode` literal verbatim.
enum FirebaseAuthCode implements ArsyncExceptionCode {
  userNotFound('firebase_auth_user_not_found'),
  wrongPassword('firebase_auth_wrong_password'),
  emailAlreadyInUse('firebase_auth_email_already_in_use'),
  invalidEmail('firebase_auth_invalid_email'),
  weakPassword('firebase_auth_weak_password'),
  invalidVerificationCode('firebase_auth_invalid_verification_code'),
  invalidVerificationId('firebase_auth_invalid_verification_id'),
  operationNotAllowed('firebase_auth_operation_not_allowed'),
  userDisabled('firebase_auth_user_disabled'),
  providerAlreadyLinked('firebase_auth_provider_already_linked'),
  invalidCredential('firebase_auth_invalid_credential'),
  credentialAlreadyInUse('firebase_auth_credential_already_in_use'),
  accountExistsWithDifferentCredential(
      'firebase_auth_account_exists_with_different_credential'),
  tooManyRequests('firebase_auth_too_many_requests'),
  requiresRecentLogin('firebase_auth_requires_recent_login'),
  networkRequestFailed('firebase_auth_network_request_failed'),
  timeout('firebase_auth_timeout'),
  internalError('firebase_auth_internal_error'),
  unknown('firebase_auth_unknown'),
  ;

  const FirebaseAuthCode(this.id);

  @override
  final String id;
}
