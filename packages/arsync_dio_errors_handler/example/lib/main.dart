// ignore_for_file: depend_on_referenced_packages

import 'package:arsync_dio_errors_handler/arsync_dio_errors_handler.dart';
import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Error Handlers Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DioErrorsScreen(),
    );
  }
}

class DioErrorsScreen extends StatefulWidget {
  const DioErrorsScreen({super.key});

  @override
  State<DioErrorsScreen> createState() => _DioErrorsScreenState();
}

class _DioErrorsScreenState extends State<DioErrorsScreen> {
  // Create an exception toolkit with the Dio error handler
  final toolkit = ArsyncExceptionToolkit(handlers: [DioErrorsHandler()]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dio Error Handlers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dio Error Handler Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Connection Errors
            _buildSectionHeader('Connection Errors'),
            _buildErrorButton(
              'Connection Timeout',
              _simulateConnectionTimeoutError,
              Colors.red.shade100,
            ),
            // Server Response Errors
            _buildSectionHeader('Server Response Errors'),
            _buildErrorButton(
              '404 Not Found',
              _simulate404NotFoundError,
              Colors.orange.shade100,
            ),
            _buildErrorButton(
              '401 Unauthorized',
              _simulate401UnauthorizedError,
              Colors.orange.shade100,
            ),
            _buildErrorButton(
              '500 Server Error',
              _simulate500ServerError,
              Colors.orange.shade100,
            ),

            // Request Format Errors
            _buildSectionHeader('Request Format Errors'),
            _buildErrorButton(
              'Bad Request Format',
              _simulateBadRequestError,
              Colors.blue.shade100,
            ),

            // Response Parsing Errors
            _buildSectionHeader('Response Parsing Errors'),
            _buildErrorButton(
              'JSON Parse Error',
              _simulateJsonParseError,
              Colors.purple.shade100,
            ),

            // Cancel Errors
            _buildSectionHeader('Other Errors'),
            _buildErrorButton(
              'Request Cancelled',
              _simulateRequestCancelledError,
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

  void _handleDioError(Object error) {
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

  // ========== Simulated Connection Errors ==========
  void _simulateConnectionTimeoutError() {
    try {
      // Simulate a connection timeout error
      throw DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: 'https://api.example.com/users'),
        message: 'Connection timeout',
      );
    } catch (error) {
      _handleDioError(error);
    }
  }

  // ========== Simulated Server Response Errors ==========
  void _simulate404NotFoundError() {
    try {
      // Simulate a 404 Not Found error
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(
          path: 'https://api.example.com/users/999',
        ),
        response: Response(
          statusCode: 404,
          statusMessage: 'Not Found',
          requestOptions: RequestOptions(
            path: 'https://api.example.com/users/999',
          ),
          data: {'message': 'User with ID 999 not found'},
        ),
      );
    } catch (error) {
      _handleDioError(error);
    }
  }

  void _simulate401UnauthorizedError() {
    try {
      // Simulate a 401 Unauthorized error
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: 'https://api.example.com/profile'),
        response: Response(
          statusCode: 401,
          statusMessage: 'Unauthorized',
          requestOptions: RequestOptions(
            path: 'https://api.example.com/profile',
          ),
          data: {'message': 'Invalid or expired token'},
        ),
      );
    } catch (error) {
      _handleDioError(error);
    }
  }

  void _simulate500ServerError() {
    try {
      // Simulate a 500 Server Error
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: 'https://api.example.com/process'),
        response: Response(
          statusCode: 500,
          statusMessage: 'Internal Server Error',
          requestOptions: RequestOptions(
            path: 'https://api.example.com/process',
          ),
          data: {'message': 'An unexpected error occurred on the server'},
        ),
      );
    } catch (error) {
      _handleDioError(error);
    }
  }

  // ========== Simulated Request Format Errors ==========
  void _simulateBadRequestError() {
    try {
      // Simulate a 400 Bad Request error
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(
          path: 'https://api.example.com/users',
          method: 'POST',
        ),
        response: Response(
          statusCode: 400,
          statusMessage: 'Bad Request',
          requestOptions: RequestOptions(
            path: 'https://api.example.com/users',
            method: 'POST',
          ),
          data: {
            'message': 'Invalid request format',
            'errors': {
              'email': 'Invalid email format',
              'age': 'Age must be a number',
            },
          },
        ),
      );
    } catch (error) {
      _handleDioError(error);
    }
  }

  // ========== Simulated Response Parsing Errors ==========
  void _simulateJsonParseError() {
    try {
      // Simulate a JSON parse error
      throw DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: 'https://api.example.com/data'),
        error: FormatException('Unexpected character at position 34'),
        message: 'Failed to parse response as JSON',
      );
    } catch (error) {
      _handleDioError(error);
    }
  }

  // ========== Other Errors ==========
  void _simulateRequestCancelledError() {
    try {
      // Simulate a cancelled request
      throw DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(
          path: 'https://api.example.com/download',
        ),
        message: 'Request cancelled',
      );
    } catch (error) {
      _handleDioError(error);
    }
  }
}
