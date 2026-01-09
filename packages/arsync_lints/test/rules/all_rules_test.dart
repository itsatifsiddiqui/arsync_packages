import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'complexity_limits_test.dart' as complexity_limits;
import 'presentation_layer_isolation_test.dart' as presentation_layer_isolation;
import 'print_ban_test.dart' as print_ban;
import 'provider_declaration_syntax_test.dart' as provider_declaration_syntax;

void main() {
  defineReflectiveSuite(() {
    complexity_limits.main();
    presentation_layer_isolation.main();
    print_ban.main();
    provider_declaration_syntax.main();
  });
}
