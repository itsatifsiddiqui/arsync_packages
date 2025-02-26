import 'dart:async';
import 'dart:io';

import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';

/// A basic example demonstrating how to use the Arsync Exception Toolkit.
/// This example shows:
/// 1. Creating a toolkit instance
/// 2. Handling different types of exceptions
/// 3. Displaying exceptions to users
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arsync Exception Toolkit - Basic Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // home: const AdvancedExampleScreen(),
      home: const BasicExampleScreen(),
    );
  }
}

class BasicExampleScreen extends StatefulWidget {
  const BasicExampleScreen({super.key});

  @override
  State<BasicExampleScreen> createState() => _BasicExampleScreenState();
}

class _BasicExampleScreenState extends State<BasicExampleScreen> {
  // Create an instance of the exception toolkit
  final exceptionToolkit = ArsyncExceptionToolkit();

  // Track the last exception for display
  ArsyncException? lastException;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exception Toolkit Basics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the buttons below to simulate different types of exceptions and see how they are handled.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            _buildExceptionButtons(),

            const SizedBox(height: 32),

            if (lastException != null) _buildLastExceptionCard(),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildExceptionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: _simulateNetworkException,
          child: const Text('Network Exception'),
        ),
        ElevatedButton(
          onPressed: _simulateTimeoutException,
          child: const Text('Timeout Exception'),
        ),
        ElevatedButton(
          onPressed: _simulateAuthException,
          child: const Text('Auth Exception'),
        ),
        ElevatedButton(
          onPressed: _simulateFormatException,
          child: const Text('Format Exception'),
        ),
        ElevatedButton(
          onPressed: _simulateServerException,
          child: const Text('Server Exception'),
        ),
      ],
    );
  }

  Widget _buildLastExceptionCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Exception',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(lastException!.icon, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lastException!.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(lastException!.message),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code: ${lastException!.exceptionCode ?? 'N/A'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_outlined, size: 18),
                    label: const Text('Show Snackbar'),
                    onPressed: () => _showSnackbar(lastException!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Show Dialog'),
                    onPressed: () => _showDialog(lastException!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Handle exceptions and update UI
  void _handleException(Object exception) {
    // Convert the raw exception to an ArsyncException
    final arsyncException = exceptionToolkit.handleException(exception);

    // Update the UI to show the new exception
    setState(() {
      lastException = arsyncException;
    });

    // Show a snackbar for immediate feedback
    _showSnackbar(arsyncException);
  }

  // Show exception as a snackbar
  void _showSnackbar(ArsyncException exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(exception.icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(exception.briefMessage)),
          ],
        ),
        backgroundColor: Colors.red[700],
        action: SnackBarAction(
          label: 'Details',
          textColor: Colors.white,
          onPressed: () => _showDialog(exception),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show exception as a dialog
  void _showDialog(ArsyncException exception) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(exception.icon, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(exception.title)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exception.message),
                  if (exception.technicalDetails != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Technical Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exception.technicalDetails!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Simulate different types of exceptions

  void _simulateNetworkException() {
    try {
      throw SocketException('Failed to connect to api.example.com');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateTimeoutException() {
    try {
      throw TimeoutException('The operation timed out after 30 seconds');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateAuthException() {
    try {
      throw Exception('Authentication failed: Invalid credentials provided');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateFormatException() {
    try {
      throw FormatException(
        'Invalid format: Expected JSON object but got invalid input',
      );
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateServerException() {
    try {
      throw Exception('Server error: Internal server error (500)');
    } catch (e) {
      _handleException(e);
    }
  }
}
