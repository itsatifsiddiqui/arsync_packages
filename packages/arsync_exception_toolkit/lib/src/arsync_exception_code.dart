/// Typed identity for a known exception code.
///
/// Each package declares `enum`s that `implements ArsyncExceptionCode`.
abstract interface class ArsyncExceptionCode {
  /// Stable string identifier (equal to the historical `exceptionCode`).
  String get id;
}

/// Escape hatch for runtime-built error codes whose `id` is composed at
/// runtime (e.g. `'firebase_auth_$code'`) and therefore cannot be an `enum`
/// value. Equality is id-based so two instances with the same `id` are equal.
final class RawArsyncExceptionCode implements ArsyncExceptionCode {
  @override
  final String id;

  const RawArsyncExceptionCode(this.id);

  @override
  bool operator ==(Object other) =>
      other is RawArsyncExceptionCode && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RawArsyncExceptionCode($id)';
}
