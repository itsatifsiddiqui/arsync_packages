// Shared Dio provider for dependency injection across repositories
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

/// Dio provider - shared dependency for all repositories
final dioProvider = Provider.autoDispose<Dio>((ref) {
  ref.keepAlive();
  return Dio();
});
