## 0.0.5

- Add `early_return_enforcement` lint rule to encourage early return pattern
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
