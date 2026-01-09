## 0.0.7

- Fixes

## 0.0.6

- Remove `early_return_enforcement` rule (generated false positives in valid code patterns)
- Remove max 4 method parameters limit from `complexity_limits` rule

## 0.0.5

- Add ignore comment support.
- Increase max nesting depth from 3 to 5 levels in `complexity_limits` rule

## 0.0.4

- migrate from custom lint to analyzer plugin.

## 0.0.3

- Fix IDE integration (VS Code/Cursor) by constraining analyzer to `<9.0.0`
- Previous wide constraints pulled `_fe_analyzer_shared` requiring SDK 3.9, incompatible with IDE plugin runtime (max 3.8)

## 0.0.2

- Widen dependency version constraints for better compatibility

## 0.0.1

- Initial version.
