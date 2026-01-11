// Example: Complexity limits - nesting depth demonstration

// Helper to avoid dead_code and literal_only_boolean_expressions warnings
bool _mockCondition() => true;

class NestingExample {
  void badNesting() {
    // VIOLATION: complexity_limits (nesting depth > 3)
    if (_mockCondition()) {
      // Level 1
      for (var i = 0; i < 1; i++) {
        // Level 2
        while (_mockCondition()) {
          // Level 3
          if (_mockCondition()) {
            // Level 4 - LINT: complexity_limits (nesting > 3)
            break;
          }
          break;
        }
      }
    }
  }

  void goodNesting() {
    // OK: Maximum 3 levels of nesting
    if (_mockCondition()) {
      // Level 1
      for (var i = 0; i < 10; i++) {
        // Level 2
        if (_mockCondition()) {
          // Level 3 - OK
          break;
        }
      }
    }
  }

  // Better approach: extract methods
  void refactoredNesting() {
    if (shouldProcess()) {
      processItems();
    }
  }

  bool shouldProcess() => true;

  void processItems() {
    for (var i = 0; i < 10; i++) {
      processItem(i);
    }
  }

  void processItem(int i) {
    // Handle individual item
  }
}
