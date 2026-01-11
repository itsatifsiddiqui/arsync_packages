import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/asset_safety.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AssetSafetyTest);
  });
}

@reflectiveTest
class AssetSafetyTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AssetSafety();
    super.setUp();
  }

  Future<void> test_good_noImageAsset() async {
    await assertNoDiagnostics(r'''
class MyClass {
  void doSomething() {}
}
''');
  }

  Future<void> test_good_constantAssetPath() async {
    await assertNoDiagnostics(r'''
class Image {
  static Image asset(String path) => Image();
}

const kLogoPath = 'assets/logo.png';

void main() {
  Image.asset(kLogoPath);
}
''');
  }
}
