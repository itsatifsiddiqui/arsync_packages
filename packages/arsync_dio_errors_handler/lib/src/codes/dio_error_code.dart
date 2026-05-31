import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

enum DioErrorCode implements ArsyncExceptionCode {
  // Connection-related errors
  connectionTimeout('dio_connection_timeout'),
  sendTimeout('dio_send_timeout'),
  receiveTimeout('dio_receive_timeout'),
  connectionError('dio_connection_error'),
  badCertificate('dio_bad_certificate'),
  cancel('dio_cancel'),

  // HTTP status code errors
  badRequest('dio_bad_request'),
  unauthorized('dio_unauthorized'),
  forbidden('dio_forbidden'),
  notFound('dio_not_found'),
  methodNotAllowed('dio_method_not_allowed'),
  requestTimeout('dio_request_timeout'),
  conflict('dio_conflict'),
  unprocessableEntity('dio_unprocessable_entity'),
  tooManyRequests('dio_too_many_requests'),
  internalServerError('dio_internal_server_error'),
  badGateway('dio_bad_gateway'),
  serviceUnavailable('dio_service_unavailable'),
  gatewayTimeout('dio_gateway_timeout'),
  unknown('dio_unknown'),

  // Response error handler defaults
  clientError('dio_client_error'),
  serverError('dio_server_error'),
  unknownStatus('dio_unknown_status'),
  ;

  const DioErrorCode(this.id);

  @override
  final String id;
}
