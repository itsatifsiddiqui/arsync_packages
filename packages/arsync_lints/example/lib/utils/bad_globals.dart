// Example: BAD - Global variables that violate global_variable_restriction

// VIOLATION: global_variable_restriction
// Public top-level variable not in constants.dart, not k-prefixed, not private
String apiUrl = 'https://api.example.com';
int retryCount = 3;
bool isDebugMode = true;
List<String> allowedHosts = ['example.com'];
Map<String, dynamic> config = {};

// More violations
Duration timeout = const Duration(seconds: 30);
double borderRadius = 8.0;

// OK: Private variables are allowed
// ignore: unused_element
final _privateCache = <String, dynamic>{};
// ignore: unused_element
const _internalFlag = true;
