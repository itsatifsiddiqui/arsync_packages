// Example: file_class_match rule demonstration
// File name: file_class_match_example.dart
// Expected class name: FileClassMatchExample

// OK: Class name matches file name
class FileClassMatchExample {
  void doSomething() {}
}

// This would be a violation if it were the primary class:
// class WrongName {} // LINT: file_class_match
