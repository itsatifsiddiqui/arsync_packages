// Example: BAD - file_class_match rule violation
// File name: wrong_name.dart
// Expected class name: WrongName

// VIOLATION: file_class_match
// Class name doesn't match file name
class IncorrectClassName {
  // LINT: file_class_match
}
