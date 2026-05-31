import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Supabase Auth errors.
///
/// Each value's [id] is the stable `exceptionCode` string used for this case.
enum SupabaseAuthCode implements ArsyncExceptionCode {
  invalidCredentials('supabase_auth_invalid_credentials'),
  userNotFound('supabase_auth_user_not_found'),
  emailNotConfirmed('supabase_auth_email_not_confirmed'),
  invalidToken('supabase_auth_invalid_token'),
  tokenExpired('supabase_auth_token_expired'),
  invalidEmail('supabase_auth_invalid_email'),
  weakPassword('supabase_auth_weak_password'),
  userAlreadyExists('supabase_auth_user_already_exists'),
  emailTaken('supabase_auth_email_taken'),
  invalidMfaType('supabase_auth_invalid_mfa_type'),
  mfaNotEnabled('supabase_auth_mfa_not_enabled'),
  invalidMfaCode('supabase_auth_invalid_mfa_code'),
  phoneAlreadyConfirmed('supabase_auth_phone_already_confirmed'),
  networkError('supabase_auth_network_error'),
  timeoutError('supabase_auth_timeout_error'),
  rateLimited('supabase_auth_rate_limited'),
  serverError('supabase_auth_server_error'),
  unknownError('supabase_auth_unknown_error'),
  ;

  const SupabaseAuthCode(this.id);

  @override
  final String id;
}
