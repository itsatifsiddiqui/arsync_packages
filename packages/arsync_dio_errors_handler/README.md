# Arsync Dio Errors Handler

A specialized package for handling Dio HTTP client errors with the [Arsync Exception Toolkit](https://pub.dev/packages/arsync_exception_toolkit).

[![pub package](https://img.shields.io/pub/v/arsync_dio_errors_handler.svg)](https://pub.dev/packages/arsync_dio_errors_handler)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- ✨ **Specialized Dio Error Handling**: Human-friendly error messages for all Dio error types
- 🧠 **Smart Response Parsing**: Extract detailed error messages from API responses
- 🛠️ **Flexible API Error Format Support**: Customizable error extractors for different API response formats
- 🚀 **Easy Integration**: Simple extensions to add Dio handling to your exception toolkit
- 🌐 **Built-in Support for Common Frameworks**: Pre-configured extractors for Laravel, Django, and more

## Installation

```yaml
dependencies:
  arsync_exception_toolkit: latest_version
  arsync_dio_errors_handler: latest_version
  dio: latest_version  # Required for Dio
```

## Basic Usage

### 1. Add Dio handlers to your toolkit

```dart
// Create a toolkit with all Dio handlers
final toolkit = ArsyncExceptionToolkit()
  .withAllDioHandlers();

// Or add specific handlers
final toolkit = ArsyncExceptionToolkit()
  .withDioErrorHandler()
  .withResponseErrorHandler(
    errorExtractor: DefaultErrorExtractor(),
  );
```

### 2. Use in try-catch blocks

```dart
try {
  // Dio operation that might fail
  final response = await dio.get('https://api.example.com/data');
} catch (e) {
  // The toolkit will automatically detect Dio errors
  final exception = toolkit.handleException(e);
  
  // User-friendly error information is available
  print(exception.title); // "Connection Error"
  print(exception.message); // "Unable to connect to the server..."
  
  // Show the error to the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(exception.briefMessage)),
  );
}
```

## Advanced Features

### Customizing Error Messages

You can customize the error messages for specific error codes:

```dart
// Create a toolkit with custom Dio error messages
final toolkit = ArsyncExceptionToolkit()
  .withDioErrorHandler(
    customExceptions: {
      DioErrorCodes.connectionError: ArsyncException(
        icon: Icons.wifi_off,
        title: 'No Internet Connection',
        message: 'Please check your internet connection and try again.',
        briefTitle: 'No Connection',
        briefMessage: 'Network unavailable',
        exceptionCode: 'dio_connection_error',
      ),
    },
  );
```

### Using Custom API Error Formats

For APIs with custom error formats, you can create a custom error extractor:

```dart
// Define a custom error extractor for your API
class MyApiErrorExtractor implements ErrorExtractor {
  @override
  ExtractedError extractError(Response response) {
    final data = response.data;
    if (data is Map) {
      return ExtractedError(
        code: data['errorCode']?.toString(),
        message: data['userMessage'] ?? data['devMessage'],
        details: data['details'] is Map ? Map<String, dynamic>.from(data['details']) : null,
      );
    }
    return ExtractedError(message: response.statusMessage);
  }
}

// Use the custom extractor with the toolkit
final toolkit = ArsyncExceptionToolkit()
  .withAllDioHandlers(
    errorExtractor: MyApiErrorExtractor(),
  );
```

### Using Built-in Extractors for Common Frameworks

The package includes pre-configured extractors for common frameworks:

```dart
// For Laravel APIs
final toolkit = ArsyncExceptionToolkit()
  .withResponseErrorHandler(
    errorExtractor: LaravelErrorExtractor(),
  );

// For Django Rest Framework APIs
final toolkit = ArsyncExceptionToolkit()
  .withResponseErrorHandler(
    errorExtractor: DjangoErrorExtractor(),
  );
```

### Using a Completely Custom Extractor Function

For more complex scenarios, you can use a function-based extractor:

```dart
final toolkit = ArsyncExceptionToolkit()
  .withResponseErrorHandler(
    errorExtractor: CustomErrorExtractor(
      extractorFunction: (response) {
        // Custom logic to extract error information
        final data = response.data;
        // Process the data however you need
        return ExtractedError(
          code: 'custom_error',
          message: 'Custom error message',
        );
      },
    ),
  );
```

## Handler Classes

The package includes these specialized handlers:

1. **DioErrorHandler**: Handles basic Dio errors (network, timeout, etc.)
2. **ResponseErrorHandler**: Handles API response errors with structured data
3. **DioErrorsHandler**: A combined handler that uses both of the above

## Error Extractors

The package includes these error extractors:

1. **DefaultErrorExtractor**: Handles common JSON error formats
2. **LaravelErrorExtractor**: Handles Laravel validation error responses
3. **DjangoErrorExtractor**: Handles Django Rest Framework error responses
4. **CustomErrorExtractor**: Create your own extractor with a custom function

## Author

**Atif Siddiqui**
- Email: itsatifsiddiqui@gmail.com
- GitHub: [itsatifsiddiqui](https://github.com/itsatifsiddiqui)
- LinkedIn: [Atif Siddiqui](https://www.linkedin.com/in/atif-siddiqui-213a2217b/)

## About Arsync Solutions

[Arsync Solutions](https://arsyncsolutions.com), We build Flutter apps for iOS, Android, and the web.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue.