import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';

/// Custom exception handler for API-related exceptions
class ApiExceptionHandler implements ArsyncExceptionHandler {
  @override
  bool canHandle(Object exception) {
    final message = exception.toString().toLowerCase();
    return message.contains('api') ||
        message.contains('http') ||
        message.contains('endpoint');
  }

  @override
  ArsyncException handle(Object exception) {
    final message = exception.toString().toLowerCase();

    // Handle different types of API errors
    if (message.contains('401') || message.contains('unauthorized')) {
      return ArsyncException(
        icon: Icons.lock_outline,
        title: 'API Authentication Error',
        message: 'Your session has expired. Please sign in again to continue.',
        briefTitle: 'Session Expired',
        briefMessage: 'Please sign in again',
        exceptionCode: 'api_auth_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (message.contains('404') || message.contains('not found')) {
      return ArsyncException(
        icon: Icons.travel_explore,
        title: 'API Resource Not Found',
        message: 'The requested resource could not be found on the server.',
        briefTitle: 'Not Found',
        briefMessage: 'Resource not found',
        exceptionCode: 'api_not_found',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (message.contains('429') || message.contains('too many')) {
      return ArsyncException(
        icon: Icons.speed,
        title: 'Rate Limit Exceeded',
        message: 'You\'ve made too many requests. Please try again later.',
        briefTitle: 'Too Many Requests',
        briefMessage: 'Rate limit exceeded',
        exceptionCode: 'api_rate_limit',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    // Default API error
    return ArsyncException(
      icon: Icons.public_off,
      title: 'API Error',
      message: 'An error occurred while communicating with the server.',
      briefTitle: 'API Error',
      briefMessage: 'Server communication error',
      exceptionCode: 'api_error',
      originalException: exception,
      technicalDetails: exception.toString(),
    );
  }

  @override
  int get priority => 10; // Higher priority than general handler
}

/// Custom handler for payment-related exceptions
class PaymentExceptionHandler implements ArsyncExceptionHandler {
  @override
  bool canHandle(Object exception) {
    final message = exception.toString().toLowerCase();
    return message.contains('payment') ||
        message.contains('card') ||
        message.contains('transaction');
  }

  @override
  ArsyncException handle(Object exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('declined')) {
      return ArsyncException(
        icon: Icons.credit_card_off,
        title: 'Payment Declined',
        message:
            'Your payment was declined. Please check your card details or try another payment method.',
        briefTitle: 'Payment Failed',
        briefMessage: 'Card declined',
        exceptionCode: 'payment_declined',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (message.contains('expired')) {
      return ArsyncException(
        icon: Icons.credit_card_off,
        title: 'Card Expired',
        message: 'Your card has expired. Please update your payment details.',
        briefTitle: 'Card Expired',
        briefMessage: 'Please update card',
        exceptionCode: 'payment_card_expired',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    // Default payment error
    return ArsyncException(
      icon: Icons.payment,
      title: 'Payment Error',
      message:
          'There was an issue processing your payment. Please try again or use a different payment method.',
      briefTitle: 'Payment Failed',
      briefMessage: 'Payment processing error',
      exceptionCode: 'payment_error',
      originalException: exception,
      technicalDetails: exception.toString(),
    );
  }

  @override
  int get priority => 15; // Even higher priority for payment issues
}

class AdvancedExampleScreen extends StatefulWidget {
  const AdvancedExampleScreen({super.key});

  @override
  State<AdvancedExampleScreen> createState() => _AdvancedExampleScreenState();
}

class _AdvancedExampleScreenState extends State<AdvancedExampleScreen> {
  late ArsyncExceptionToolkit toolkit;
  ArsyncException? lastException;
  bool showTechnicalDetails = false;

  @override
  void initState() {
    super.initState();

    // Set up the toolkit with custom handlers and ignorable exceptions
    toolkit = ArsyncExceptionToolkit(
      handlers: [ApiExceptionHandler(), PaymentExceptionHandler()],
      ignorableExceptions: ['user cancelled', 'operation aborted'],
    );

    // Register an exception modifier to customize authentication errors
    toolkit.registerExceptionModifier('auth_error', (
      exception,
      originalException,
    ) {
      // Modify authentication errors to suggest specific actions
      return exception.copyWith(
        title: 'Sign-in Required',
        message: 'Your session has expired. Please sign in again to continue.',
        briefMessage: 'Session expired, please sign in',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Exception Handling',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This example demonstrates custom exception handlers, modifiers, and display strategies.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            const Text(
              'Custom Handlers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Handlers for API and payment-related exceptions are registered.',
            ),
            const SizedBox(height: 16),

            _buildCustomHandlerButtons(),

            const SizedBox(height: 24),
            const Text(
              'Exception Modifiers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Authentication errors are modified to show session expiry information.',
            ),
            const SizedBox(height: 16),

            _buildModifierButtons(),

            const SizedBox(height: 24),
            const Text(
              'Ignorable Exceptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Some exceptions like user cancellations are treated as ignorable.',
            ),
            const SizedBox(height: 16),

            _buildIgnorableButtons(),

            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Show Technical Details'),
              subtitle: const Text(
                'Display developer information in exception views',
              ),
              value: showTechnicalDetails,
              onChanged: (value) {
                setState(() {
                  showTechnicalDetails = value;
                });
              },
            ),

            if (lastException != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              _buildLastExceptionCard(),
            ],
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHandlerButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: _simulateApiError,
          child: const Text('API Error'),
        ),
        ElevatedButton(
          onPressed: _simulateApiRateLimitError,
          child: const Text('API Rate Limit'),
        ),
        ElevatedButton(
          onPressed: _simulatePaymentDeclinedError,
          child: const Text('Payment Declined'),
        ),
      ],
    );
  }

  Widget _buildModifierButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: _simulateAuthError,
          child: const Text('Auth Error (Modified)'),
        ),
      ],
    );
  }

  Widget _buildIgnorableButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: _simulateUserCancelled,
          child: const Text('User Cancelled'),
        ),
        ElevatedButton(
          onPressed: _simulateOperationAborted,
          child: const Text('Operation Aborted'),
        ),
      ],
    );
  }

  Widget _buildLastExceptionCard() {
    // Choose color based on exception type
    Color cardColor = Colors.red.shade50;
    Color iconColor = Colors.red;

    if (lastException!.isNotFoundError) {
      cardColor = Colors.amber.shade50;
      iconColor = Colors.amber.shade700;
    } else if (lastException!.shouldIgnore) {
      cardColor = Colors.grey.shade50;
      iconColor = Colors.grey;
    } else if (lastException!.isAuthError) {
      cardColor = Colors.orange.shade50;
      iconColor = Colors.orange;
    } else if (lastException!.exceptionCode?.contains('payment') == true) {
      cardColor = Colors.purple.shade50;
      iconColor = Colors.purple;
    } else if (lastException!.exceptionCode?.contains('api') == true) {
      cardColor = Colors.blue.shade50;
      iconColor = Colors.blue;
    }

    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lastException!.icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lastException!.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(lastException!.message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code: ${lastException!.exceptionCode ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    if (lastException!.shouldIgnore)
                      Text(
                        'This exception is ignored',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            OutlinedButton.icon(
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Dialog'),
              onPressed: () => _showDialog(lastException!),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.notifications_outlined, size: 16),
              label: const Text('Snackbar'),
              onPressed: () => _showSnackbar(lastException!),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.announcement_outlined, size: 16),
              label: const Text('Banner'),
              onPressed: () => _showBanner(lastException!),
            ),

            if (showTechnicalDetails &&
                lastException!.technicalDetails != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Technical Details:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lastException!.technicalDetails!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Handle exceptions and update UI
  void _handleException(Object exception) {
    // Convert the raw exception to an ArsyncException
    final arsyncException = toolkit.handleException(exception);

    // Update the UI to show the new exception
    setState(() {
      lastException = arsyncException;
    });

    // Choose appropriate display method based on exception type
    if (arsyncException.shouldIgnore) {
      // Don't display ignored exceptions
      return;
    } else if (arsyncException.exceptionCode?.contains('payment') == true) {
      // Show payment errors in a dialog
      _showDialog(arsyncException);
    } else if (arsyncException.isAuthError) {
      // Show auth errors in a banner
      _showBanner(arsyncException);
    } else {
      // Show other errors in a snackbar
      _showSnackbar(arsyncException);
    }
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
                  if (showTechnicalDetails &&
                      exception.technicalDetails != null) ...[
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

  // Show exception as a banner
  void _showBanner(ArsyncException exception) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exception.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(exception.message),
          ],
        ),
        leading: Icon(exception.icon, color: Colors.red),
        backgroundColor: Colors.orange[50],
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Dismiss'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              _showDialog(exception);
            },
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  // Simulate various exceptions

  void _simulateApiError() {
    try {
      throw Exception('API error: Failed to fetch data from endpoint');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateApiRateLimitError() {
    try {
      throw Exception('API error: 429 Too Many Requests - Rate limit exceeded');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulatePaymentDeclinedError() {
    try {
      throw Exception('Payment error: Transaction declined by issuing bank');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateAuthError() {
    try {
      throw Exception('Authentication failed: Token expired');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateUserCancelled() {
    try {
      throw Exception('User cancelled the operation');
    } catch (e) {
      _handleException(e);
    }
  }

  void _simulateOperationAborted() {
    try {
      throw Exception('Operation aborted: User initiated cancellation');
    } catch (e) {
      _handleException(e);
    }
  }
}
