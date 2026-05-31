import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Supabase Realtime errors.
///
/// Each value's [id] equals the stable `exceptionCode` string used by the
/// Supabase Realtime handler.
enum SupabaseRealtimeCode implements ArsyncExceptionCode {
  connectionError('supabase_realtime_connection_error'),
  subscriptionError('supabase_realtime_subscription_error'),
  channelError('supabase_realtime_channel_error'),
  tooManyConnections('supabase_realtime_too_many_connections'),
  unauthorized('supabase_realtime_unauthorized'),
  networkError('supabase_realtime_network_error'),
  timeoutError('supabase_realtime_timeout_error'),
  rateLimited('supabase_realtime_rate_limited'),
  serverError('supabase_realtime_server_error'),
  unknownError('supabase_realtime_unknown_error'),
  ;

  const SupabaseRealtimeCode(this.id);

  @override
  final String id;
}
