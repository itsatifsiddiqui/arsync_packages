// ignore_for_file: depend_on_referenced_packages

import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:arsync_firebase_errors_handler/arsync_firebase_errors_handler.dart';
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart'
    show FirebaseFunctionsException;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    show FirebaseAuthException;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Error Handlers Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const FirebaseErrorsScreen(),
    );
  }
}

class FirebaseErrorsScreen extends StatefulWidget {
  const FirebaseErrorsScreen({super.key});

  @override
  State<FirebaseErrorsScreen> createState() => _FirebaseErrorsScreenState();
}

class _FirebaseErrorsScreenState extends State<FirebaseErrorsScreen> {
  // Create an exception toolkit with all Firebase handlers
  final exceptionToolkit = ArsyncExceptionToolkit(
    handlers: [FirebaseErrorsHandler()],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Error Handlers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Error Handler Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Auth Section
            _buildSectionHeader('Firebase Auth Errors'),
            _buildErrorButton(
              'Wrong Password',
              _simulateAuthWrongPasswordError,
              Colors.red.shade100,
            ),

            // Firestore Section
            _buildSectionHeader('Firestore Errors'),
            _buildErrorButton(
              'Permission Denied',
              _simulateFirestorePermissionError,
              Colors.orange.shade100,
            ),

            // Storage Section
            _buildSectionHeader('Firebase Storage Errors'),
            _buildErrorButton(
              'Object Not Found',
              _simulateStorageObjectNotFoundError,
              Colors.blue.shade100,
            ),

            // Functions Section
            _buildSectionHeader('Firebase Functions Errors'),
            _buildErrorButton(
              'Function Execution Failed',
              _simulateFunctionExecutionError,
              Colors.purple.shade100,
            ),

            // Core Section
            _buildSectionHeader('Firebase Core Errors'),
            _buildErrorButton(
              'Invalid API Key',
              _simulateInvalidApiKeyError,
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

  void _handleFirebaseError(Object error) {
    // Use the toolkit to process the error
    final exception = exceptionToolkit.handleException(error);

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
  void _simulateAuthWrongPasswordError() {
    try {
      // Simulate a wrong-password FirebaseAuthException
      throw FirebaseAuthException(
        code: 'wrong-password',
        message:
            'The password is invalid or the user does not have a password.',
      );
    } catch (error) {
      _handleFirebaseError(error);
    }
  }

  // ========== Simulated Firestore Error ==========
  void _simulateFirestorePermissionError() {
    try {
      // Simulate a permission-denied FirebaseException for Firestore
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions to access this document.',
      );
    } catch (error) {
      _handleFirebaseError(error);
    }
  }

  // ========== Simulated Storage Error ==========
  void _simulateStorageObjectNotFoundError() {
    try {
      // Simulate an object-not-found FirebaseException for Storage
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'object-not-found',
        message: 'No object exists at the desired reference.',
      );
    } catch (error) {
      _handleFirebaseError(error);
    }
  }

  // ========== Simulated Functions Error ==========
  void _simulateFunctionExecutionError() {
    try {
      // Simulate a FirebaseFunctionsException
      throw FirebaseFunctionsException(
        code: 'internal',
        message:
            'The function execution failed due to an internal server error.',
        details: {
          'function_name': 'processPayment',
          'error_details': 'Timeout while accessing external payment API',
        },
      );
    } catch (error) {
      _handleFirebaseError(error);
    }
  }

  // ========== Simulated Core Error ==========
  void _simulateInvalidApiKeyError() {
    try {
      // Simulate an invalid-api-key FirebaseException
      throw FirebaseException(
        plugin: 'core',
        code: 'invalid-api-key',
        message:
            'The provided API key is invalid. Please check your Firebase configuration.',
      );
    } catch (error) {
      _handleFirebaseError(error);
    }
  }
}
