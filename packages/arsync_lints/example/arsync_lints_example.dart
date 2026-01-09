// This example project demonstrates the arsync_lints package.
// See the lib/ folder for example violations and correct usage.
//
// To use this package in your project:
// 1. Add arsync_lints to your dev_dependencies
// 2. Add custom_lint to your dev_dependencies
// 3. Enable custom_lint in your analysis_options.yaml
//
// Example analysis_options.yaml:
// ```yaml
// analyzer:
//   plugins:
//     - custom_lint
// ```
void main() {
  // ignore: avoid_print
  print('See lib/ folder for arsync_lints examples');
}
