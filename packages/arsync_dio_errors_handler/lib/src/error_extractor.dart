import 'dart:convert';

import 'package:dio/dio.dart';

/// Extracted error information from a response
class ExtractedError {
  /// Error code from the response
  final String? code;
  
  /// Error message from the response
  final String? message;
  
  /// Optional additional error details
  final Map<String, dynamic>? details;

  /// Create an extracted error
  ExtractedError({
    this.code,
    this.message,
    this.details,
  });

  @override
  String toString() {
    return 'ExtractedError(code: $code, message: $message, details: $details)';
  }
}

/// Abstract class for extracting error information from responses
abstract class ErrorExtractor {
  /// Extract error information from a response
  ExtractedError extractError(Response response);
}

/// Default JSON error extractor that follows common REST API patterns
///
/// This extractor supports the following common JSON error response formats:
/// 
/// Format 1: 
/// ```json
/// {
///   "error": {
///     "code": "SOME_ERROR_CODE",
///     "message": "Error message"
///   }
/// }
/// ```
/// 
/// Format 2: 
/// ```json
/// {
///   "code": "SOME_ERROR_CODE",
///   "message": "Error message",
///   "details": { ... }
/// }
/// ```
/// 
/// Format 3: 
/// ```json
/// {
///   "error": "Error message"
/// }
/// ```
/// 
/// Format 4: 
/// ```json
/// {
///   "message": "Error message"
/// }
/// ```
class DefaultErrorExtractor implements ErrorExtractor {
  /// Key for the error object in the response
  final String errorKey;
  
  /// Key for the error code in the response
  final String codeKey;
  
  /// Key for the error message in the response
  final String messageKey;
  
  /// Key for the error details in the response
  final String detailsKey;
  
  /// Boolean indicating whether to also check at the root level
  final bool checkRootLevel;

  /// Create a default error extractor
  ///
  /// [errorKey] - The key for the error object (e.g., "error")
  /// [codeKey] - The key for the error code (e.g., "code")
  /// [messageKey] - The key for the error message (e.g., "message")
  /// [detailsKey] - The key for the error details (e.g., "details")
  /// [checkRootLevel] - If true, also check for error information at the root level
  DefaultErrorExtractor({
    this.errorKey = 'error',
    this.codeKey = 'code',
    this.messageKey = 'message',
    this.detailsKey = 'details',
    this.checkRootLevel = true,
  });

  @override
  ExtractedError extractError(Response response) {
    // Make sure we have response data to work with
    if (response.data == null) {
      return ExtractedError(
        message: 'No response data available',
      );
    }

    // If response data is a string, try to parse it as JSON
    dynamic data = response.data;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        // If it's not valid JSON, use the string as the error message
        return ExtractedError(
          message: data,
        );
      }
    }

    // Data should be a Map at this point
    if (data is! Map) {
      return ExtractedError(
        message: 'Unexpected response format',
      );
    }

    // Convert to Map<String, dynamic> for easier access
    final Map<String, dynamic> errorData = Map<String, dynamic>.from(data);

    // Check for error format inside an error object
    if (errorData.containsKey(errorKey)) {
      final dynamic errorValue = errorData[errorKey];
      
      // Handle case where error is a string
      if (errorValue is String) {
        return ExtractedError(
          message: errorValue,
        );
      }
      
      // Handle case where error is an object
      if (errorValue is Map) {
        final Map<String, dynamic> errorObj = Map<String, dynamic>.from(errorValue);
        
        return ExtractedError(
          code: errorObj[codeKey]?.toString(),
          message: errorObj[messageKey]?.toString(),
          details: errorObj[detailsKey] is Map ? Map<String, dynamic>.from(errorObj[detailsKey]) : null,
        );
      }
    }

    // Check at root level if enabled
    if (checkRootLevel) {
      String? code, message;
      Map<String, dynamic>? details;
      
      if (errorData.containsKey(codeKey)) {
        code = errorData[codeKey]?.toString();
      }
      
      if (errorData.containsKey(messageKey)) {
        message = errorData[messageKey]?.toString();
      }
      
      if (errorData.containsKey(detailsKey) && errorData[detailsKey] is Map) {
        details = Map<String, dynamic>.from(errorData[detailsKey]);
      }
      
      if (code != null || message != null || details != null) {
        return ExtractedError(
          code: code,
          message: message,
          details: details,
        );
      }
    }

    // Fallback to using the status message from the response
    return ExtractedError(
      message: response.statusMessage,
    );
  }
}

/// Custom error extractor for working with complex, nested, or non-standard API responses
///
/// This extractor allows for customizing the error extraction logic via a callback function.
class CustomErrorExtractor implements ErrorExtractor {
  /// Function to extract error details from a response
  final ExtractedError Function(Response response) extractorFunction;

  /// Create a custom error extractor
  ///
  /// [extractorFunction] - Custom function for extracting error details
  CustomErrorExtractor({
    required this.extractorFunction,
  });

  @override
  ExtractedError extractError(Response response) {
    return extractorFunction(response);
  }
}

/// Laravel API error extractor
///
/// Handles common Laravel validation error responses that follow this format:
/// ```json
/// {
///   "message": "The given data was invalid.",
///   "errors": {
///     "field1": ["Error message 1", "Error message 2"],
///     "field2": ["Error message"]
///   }
/// }
/// ```
class LaravelErrorExtractor implements ErrorExtractor {
  @override
  ExtractedError extractError(Response response) {
    if (response.data == null) {
      return ExtractedError(
        message: 'No response data available',
      );
    }

    dynamic data = response.data;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        return ExtractedError(
          message: data,
        );
      }
    }

    if (data is! Map) {
      return ExtractedError(
        message: 'Unexpected response format',
      );
    }

    final Map<String, dynamic> errorData = Map<String, dynamic>.from(data);
    
    // Get the message
    final String? message = errorData['message']?.toString();
    
    // Handle Laravel validation errors
    if (errorData.containsKey('errors') && errorData['errors'] is Map) {
      final Map<String, dynamic> errors = Map<String, dynamic>.from(errorData['errors']);
      
      // Compose a message from the validation errors
      if (errors.isNotEmpty) {
        // Get the first error message from each field
        final List<String> errorMessages = [];
        
        errors.forEach((field, fieldErrors) {
          if (fieldErrors is List && fieldErrors.isNotEmpty) {
            errorMessages.add('${field.toUpperCase()}: ${fieldErrors.first}');
          } else if (fieldErrors is String) {
            errorMessages.add('${field.toUpperCase()}: $fieldErrors');
          }
        });
        
        // If we have validation error messages, use them
        if (errorMessages.isNotEmpty) {
          return ExtractedError(
            code: 'validation_error',
            message: errorMessages.join('\n'),
            details: errors,
          );
        }
      }
    }
    
    // Fallback to the general message
    return ExtractedError(
      message: message ?? response.statusMessage,
    );
  }
}

/// Django Rest Framework error extractor
///
/// Handles common DRF validation error responses that follow formats like:
/// ```json
/// {
///   "detail": "Error message"
/// }
/// ```
/// or
/// ```json
/// {
///   "field1": ["Error message 1", "Error message 2"],
///   "field2": ["Error message"]
/// }
/// ```
/// or
/// ```json
/// {
///   "non_field_errors": ["Error message"]
/// }
/// ```
class DjangoErrorExtractor implements ErrorExtractor {
  @override
  ExtractedError extractError(Response response) {
    if (response.data == null) {
      return ExtractedError(
        message: 'No response data available',
      );
    }

    dynamic data = response.data;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        return ExtractedError(
          message: data,
        );
      }
    }

    if (data is! Map) {
      return ExtractedError(
        message: 'Unexpected response format',
      );
    }

    final Map<String, dynamic> errorData = Map<String, dynamic>.from(data);
    
    // Check for DRF's 'detail' field
    if (errorData.containsKey('detail')) {
      return ExtractedError(
        message: errorData['detail']?.toString(),
      );
    }
    
    // Check for 'non_field_errors'
    if (errorData.containsKey('non_field_errors') && errorData['non_field_errors'] is List) {
      final List errors = errorData['non_field_errors'];
      if (errors.isNotEmpty) {
        return ExtractedError(
          message: errors.join('\n'),
          details: errorData,
        );
      }
    }
    
    // Check if the response is a validation error with field-specific errors
    final List<String> errorMessages = [];
    
    // Try to parse field errors
    errorData.forEach((field, fieldErrors) {
      if (fieldErrors is List && fieldErrors.isNotEmpty) {
        errorMessages.add('${field.toUpperCase()}: ${fieldErrors.join(', ')}');
      } else if (fieldErrors is String) {
        errorMessages.add('${field.toUpperCase()}: $fieldErrors');
      }
    });
    
    if (errorMessages.isNotEmpty) {
      return ExtractedError(
        code: 'validation_error',
        message: errorMessages.join('\n'),
        details: errorData,
      );
    }
    
    // Fallback to status message
    return ExtractedError(
      message: response.statusMessage,
    );
  }
}