/// Constants for Dio error codes
class DioErrorCodes {
  // Dio error types
  /// Connection timeout error
  static const String connectionTimeout = 'connection_timeout';
  /// Send timeout error
  static const String sendTimeout = 'send_timeout';
  /// Receive timeout error
  static const String receiveTimeout = 'receive_timeout';
  /// Bad certificate error
  static const String badCertificate = 'bad_certificate';
  /// Connection error
  static const String connectionError = 'connection_error';
  /// Bad response error
  static const String badResponse = 'bad_response';
  /// Cancel error
  static const String cancel = 'cancel';
  /// Unknown error
  static const String unknown = 'unknown';

  // HTTP status codes
  /// Bad request error
  static const String badRequest = 'bad_request'; // 400
  /// Unauthorized error
  static const String unauthorized = 'unauthorized'; // 401
  /// Payment required error
  static const String paymentRequired = 'payment_required'; // 402
  /// Forbidden error
  static const String forbidden = 'forbidden'; // 403
  /// Not found error
  static const String notFound = 'not_found'; // 404
  /// Method not allowed error
  static const String methodNotAllowed = 'method_not_allowed'; // 405
  /// Not acceptable error
  static const String notAcceptable = 'not_acceptable'; // 406
  /// Proxy authentication required error
  static const String proxyAuthenticationRequired = 'proxy_authentication_required'; // 407
  /// Request timeout error
  static const String requestTimeout = 'request_timeout'; // 408
  /// Conflict error
  static const String conflict = 'conflict'; // 409
  /// Gone error
  static const String gone = 'gone'; // 410
  /// Length required error
  static const String lengthRequired = 'length_required'; // 411
  /// Precondition failed error
  static const String preconditionFailed = 'precondition_failed'; // 412
  /// Request entity too large error
  static const String requestEntityTooLarge = 'request_entity_too_large'; // 413
  /// Request URI too long error
  static const String requestUriTooLong = 'request_uri_too_long'; // 414
  /// Unsupported media type error
  static const String unsupportedMediaType = 'unsupported_media_type'; // 415
  /// Requested range not satisfiable error
  static const String requestedRangeNotSatisfiable = 'requested_range_not_satisfiable'; // 416
  /// Expectation failed error
  static const String expectationFailed = 'expectation_failed'; // 417
  /// Im a teapot error
  static const String imATeapot = 'im_a_teapot'; // 418
  /// Misdirected request error
  static const String misdirectedRequest = 'misdirected_request'; // 421
  /// Unprocessable entity error
  static const String unprocessableEntity = 'unprocessable_entity'; // 422
  /// Locked error
  static const String locked = 'locked'; // 423
  /// Failed dependency error
  static const String failedDependency = 'failed_dependency'; // 424
  /// Too early error
  static const String tooEarly = 'too_early'; // 425
  /// Upgrade required error
  static const String upgradeRequired = 'upgrade_required'; // 426
  /// Precondition required error
  static const String preconditionRequired = 'precondition_required'; // 428
  /// Too many requests error
  static const String tooManyRequests = 'too_many_requests'; // 429
  /// Request header fields too large error
  static const String requestHeaderFieldsTooLarge = 'request_header_fields_too_large'; // 431
  /// Unavailable for legal reasons error
  static const String unavailableForLegalReasons = 'unavailable_for_legal_reasons'; // 451

  /// 5xx Server Error
  /// Internal server error
  static const String internalServerError = 'internal_server_error'; // 500
  /// Not implemented error
  static const String notImplemented = 'not_implemented'; // 501
  /// Bad gateway error
  static const String badGateway = 'bad_gateway'; // 502
  /// Service unavailable error
  static const String serviceUnavailable = 'service_unavailable'; // 503
  /// Gateway timeout error
  static const String gatewayTimeout = 'gateway_timeout'; // 504
  /// HTTP version not supported error
  static const String httpVersionNotSupported = 'http_version_not_supported'; // 505
  /// Variant also negotiates error
  static const String variantAlsoNegotiates = 'variant_also_negotiates'; // 506
  /// Insufficient storage error
  static const String insufficientStorage = 'insufficient_storage'; // 507
  /// Loop detected error
  static const String loopDetected = 'loop_detected'; // 508
  /// Not extended error
  static const String notExtended = 'not_extended'; // 510
  /// Network authentication required error
  static const String networkAuthenticationRequired = 'network_authentication_required'; // 511

  /// Ignorable Exceptions
  static const List<String> ignorableErrorCodes = [
    cancel,
  ];

  /// Check if the given error code is ignorable
  static bool isIgnorable(String code) {
    return ignorableErrorCodes.contains(code);
  }

  /// Map HTTP status code to error code string
  static String fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return badRequest;
      case 401:
        return unauthorized;
      case 402:
        return paymentRequired;
      case 403:
        return forbidden;
      case 404:
        return notFound;
      case 405:
        return methodNotAllowed;
      case 406:
        return notAcceptable;
      case 407:
        return proxyAuthenticationRequired;
      case 408:
        return requestTimeout;
      case 409:
        return conflict;
      case 410:
        return gone;
      case 411:
        return lengthRequired;
      case 412:
        return preconditionFailed;
      case 413:
        return requestEntityTooLarge;
      case 414:
        return requestUriTooLong;
      case 415:
        return unsupportedMediaType;
      case 416:
        return requestedRangeNotSatisfiable;
      case 417:
        return expectationFailed;
      case 418:
        return imATeapot;
      case 421:
        return misdirectedRequest;
      case 422:
        return unprocessableEntity;
      case 423:
        return locked;
      case 424:
        return failedDependency;
      case 425:
        return tooEarly;
      case 426:
        return upgradeRequired;
      case 428:
        return preconditionRequired;
      case 429:
        return tooManyRequests;
      case 431:
        return requestHeaderFieldsTooLarge;
      case 451:
        return unavailableForLegalReasons;
      case 500:
        return internalServerError;
      case 501:
        return notImplemented;
      case 502:
        return badGateway;
      case 503:
        return serviceUnavailable;
      case 504:
        return gatewayTimeout;
      case 505:
        return httpVersionNotSupported;
      case 506:
        return variantAlsoNegotiates;
      case 507:
        return insufficientStorage;
      case 508:
        return loopDetected;
      case 510:
        return notExtended;
      case 511:
        return networkAuthenticationRequired;
      default:
        return 'http_$statusCode';
    }
  }
}