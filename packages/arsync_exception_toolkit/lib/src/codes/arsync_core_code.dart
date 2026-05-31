import '../arsync_exception_code.dart';

/// Typed codes for the core (general) exceptions produced by
/// `arsync_exception_toolkit`.
///
/// Each value's [id] is copied verbatim from the historical inline
/// `exceptionCode` literals in `ArsyncException`'s factories and in
/// `GeneralExceptionHandler`, so produced exceptions stay byte-identical.
enum ArsyncCoreCode implements ArsyncExceptionCode {
  network('network_error'),
  timeout('timeout_error'),
  generic('unknown_error'),
  permission('permission_error'),
  notFound('not_found_error'),
  authentication('auth_error'),
  server('server_error'),
  ignored('ignored_error'),
  format('format_error'),
  unsupported('unsupported_error'),
  assertion('assertion_error'),
  state('state_error'),
  type('type_error'),
  argument('argument_error'),
  concurrentModification('concurrent_modification_error'),
  noSuchMethodError('no_such_method_error'),
  range('range_error');

  const ArsyncCoreCode(this.id);

  @override
  final String id;
}
