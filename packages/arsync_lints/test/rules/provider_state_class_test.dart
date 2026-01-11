import 'package:arsync_lints/src/rules/provider_state_class.dart';
import 'package:test/test.dart';

void main() {
  group('ProviderStateClass', () {
    test('isPrimitiveOrBuiltinType returns true for primitives', () {
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('int'), true);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('String'), true);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('bool'), true);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('List'), true);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('Map'), true);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('AsyncValue'), true);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('Result'), true);
    });

    test('isPrimitiveOrBuiltinType returns false for custom types', () {
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('AuthState'), false);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('UserData'), false);
      expect(ProviderStateClass.isPrimitiveOrBuiltinType('MyClass'), false);
    });

    test('rule has correct name', () {
      final rule = ProviderStateClass();
      expect(rule.name, 'provider_state_class');
    });

    test('rule has two diagnostic codes', () {
      final rule = ProviderStateClass();
      expect(rule.diagnosticCodes.length, 2);
    });
  });
}
