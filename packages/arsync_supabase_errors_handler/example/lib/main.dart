// ignore_for_file: depend_on_referenced_packages

import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:arsync_supabase_errors_handler/arsync_supabase_errors_handler.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Error Handlers Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SupabaseErrorsScreen(),
    );
  }
}

class SupabaseErrorsScreen extends StatefulWidget {
  const SupabaseErrorsScreen({super.key});

  @override
  State<SupabaseErrorsScreen> createState() => _SupabaseErrorsScreenState();
}

class _SupabaseErrorsScreenState extends State<SupabaseErrorsScreen> {
  // Create an exception toolkit with all Supabase handlers
  final toolkit = ArsyncExceptionToolkit(handlers: [SupabaseErrorsHandler()]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Error Handlers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Supabase Error Handler Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Auth Section
            _buildSectionHeader('Supabase Auth Errors'),
            _buildErrorButton(
              'Invalid Credentials',
              _simulateAuthInvalidCredentialsError,
              Colors.red.shade100,
            ),

            // Database Section
            _buildSectionHeader('Supabase Database Errors'),
            _buildErrorButton(
              'Unique Violation',
              _simulateDatabaseUniqueViolationError,
              Colors.orange.shade100,
            ),

            // Storage Section
            _buildSectionHeader('Supabase Storage Errors'),
            _buildErrorButton(
              'Object Not Found',
              _simulateStorageObjectNotFoundError,
              Colors.blue.shade100,
            ),

            // Functions Section
            _buildSectionHeader('Supabase Functions Errors'),
            _buildErrorButton(
              'Function Execution Failed',
              _simulateFunctionExecutionError,
              Colors.purple.shade100,
            ),

            // Realtime Section
            _buildSectionHeader('Supabase Realtime Errors'),
            _buildErrorButton(
              'Channel Error',
              _simulateRealtimeChannelError,
              Colors.green.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildErrorButton(String label, VoidCallback onPressed, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(label),
      ),
    );
  }

  void _handleSupabaseError(Object error) {
    // Use the toolkit to process the error
    final exception = toolkit.handleException(error);

    // Show error dialog with detailed information
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(exception.icon, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(child: Text(exception.title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exception.message),
                const SizedBox(height: 16),
                const Text(
                  'Technical Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exception.technicalDetails ??
                        'No technical details available',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Exception Code: ${exception.exceptionCode ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // ========== Simulated Auth Error ==========
  void _simulateAuthInvalidCredentialsError() {
    try {
      // Simulate an invalid credentials AuthException
      throw AuthException('Invalid login credentials');
    } catch (error) {
      _handleSupabaseError(error);
    }
  }

  // ========== Simulated Database Error ==========
  void _simulateDatabaseUniqueViolationError() {
    try {
      // Simulate a unique violation PostgrestException
      throw PostgrestException(
        code: '23505', // Unique violation code
        message:
            'duplicate key value violates unique constraint "users_email_key"',
        details: 'Key (email)=(user@example.com) already exists.',
        hint: 'Try using a different email address.',
      );
    } catch (error) {
      _handleSupabaseError(error);
    }
  }

  // ========== Simulated Storage Error ==========
  void _simulateStorageObjectNotFoundError() {
    try {
      // Simulate a StorageException for object not found
      throw StorageException(
        'The object "profile.jpg" was not found in bucket "avatars"',
        statusCode: '404',
      );
    } catch (error) {
      _handleSupabaseError(error);
    }
  }

  // ========== Simulated Functions Error ==========
  void _simulateFunctionExecutionError() {
    try {
      // Simulate a FunctionException
      throw FunctionException(
        details: 'Edge function failed during execution',
        status: 500,
      );
    } catch (error) {
      _handleSupabaseError(error);
    }
  }

  // ========== Simulated Realtime Error ==========
  void _simulateRealtimeChannelError() {
    try {
      // Simulate a Realtime channel error
      throw Exception(
        'Realtime channel error: Channel "rooms:123" join failed due to insufficient permissions',
      );
    } catch (error) {
      _handleSupabaseError(error);
    }
  }
}
