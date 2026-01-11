// Example: Asset safety rule demonstrations

import '../utils/images.dart';

class AssetExample {}

// Mock classes for example
class Image {
  Image.asset(String path);
}

class AssetImage {
  AssetImage(String path);
}

class BadAssetExample {
  void build() {
    // VIOLATION: asset_safety
    // Using string literals instead of Images constants
    Image.asset('assets/images/logo.png'); // LINT: asset_safety
    AssetImage('assets/icons/icon.png'); // LINT: asset_safety
  }
}

class GoodAssetExample {
  void build() {
    // OK: Using Images constants
    Image.asset(Images.logo);
    AssetImage(Images.icon);
  }
}
