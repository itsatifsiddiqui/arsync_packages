import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/prefer_to_include_sliver_in_name.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferToIncludeSliverInNameTest);
  });
}

@reflectiveTest
class PreferToIncludeSliverInNameTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferToIncludeSliverInName();
    super.setUp();
  }

  Future<void> test_good_sliverInClassName() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

class SliverMyCustomList extends Widget {
  Widget build(dynamic context) {
    return SliverToBoxAdapter(child: Text('Hello'));
  }
}
''');
  }

  Future<void> test_good_sliverInConstructorName() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

class MyCustomList extends Widget {
  const MyCustomList.sliver();

  Widget build(dynamic context) {
    return SliverToBoxAdapter(child: Text('Hello'));
  }
}
''');
  }

  Future<void> test_good_nonSliverWidget() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container();
}

class MyWidget extends Widget {
  Widget build(dynamic context) {
    return Container();
  }
}
''');
  }

  Future<void> test_bad_returnsSliverWithoutSliverInName() async {
    await assertDiagnostics(
      r'''
// Mock types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

class MyCustomList extends Widget {
  Widget build(dynamic context) {
    return SliverToBoxAdapter(child: Text('Hello'));
  }
}
''',
      [lint(235, 128)],
    );
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: prefer_to_include_sliver_in_name

// Mock types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

class MyCustomList extends Widget {
  Widget build(dynamic context) {
    return SliverToBoxAdapter(child: Text('Hello'));
  }
}
''');
  }
}
