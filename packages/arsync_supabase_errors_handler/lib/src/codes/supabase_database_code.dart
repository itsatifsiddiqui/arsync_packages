import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Supabase Database (PostgreSQL) errors.
///
/// Each value's [id] is the stable `exceptionCode` string used for this case.
enum SupabaseDatabaseCode implements ArsyncExceptionCode {
  uniqueViolation('supabase_db_unique_violation'),
  foreignKeyViolation('supabase_db_foreign_key_violation'),
  checkViolation('supabase_db_check_violation'),
  notNullViolation('supabase_db_not_null_violation'),
  tableNotFound('supabase_db_table_not_found'),
  columnNotFound('supabase_db_column_not_found'),
  insufficientPrivilege('supabase_db_insufficient_privilege'),
  syntaxError('supabase_db_syntax_error'),
  invalidParameter('supabase_db_invalid_parameter'),
  dataException('supabase_db_data_exception'),
  connectionFailure('supabase_db_connection_failure'),
  networkError('supabase_db_network_error'),
  timeoutError('supabase_db_timeout_error'),
  serverError('supabase_db_server_error'),
  unknownError('supabase_db_unknown_error'),
  ;

  const SupabaseDatabaseCode(this.id);

  @override
  final String id;
}
