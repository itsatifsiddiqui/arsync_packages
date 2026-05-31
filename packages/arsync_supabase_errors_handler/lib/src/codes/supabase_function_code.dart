import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Supabase Functions (Edge Functions) errors.
///
/// Each value's [id] equals the stable `exceptionCode` string used by the
/// Supabase Functions handler.
enum SupabaseFunctionCode implements ArsyncExceptionCode {
  functionNotFound('supabase_function_not_found'),
  executionFailed('supabase_function_execution_failed'),
  timeout('supabase_function_timeout'),
  invalidPayload('supabase_function_invalid_payload'),
  unauthorized('supabase_function_unauthorized'),
  networkError('supabase_function_network_error'),
  timeoutError('supabase_function_timeout_error'),
  rateLimited('supabase_function_rate_limited'),
  serverError('supabase_function_server_error'),
  unknownError('supabase_function_unknown_error'),
  ;

  const SupabaseFunctionCode(this.id);

  @override
  final String id;
}
