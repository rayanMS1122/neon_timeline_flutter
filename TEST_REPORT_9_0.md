# Test Report 9.0

## Added source tests

- Midnight entry clipping and segment classification
- Out-of-window segment rejection
- Hybrid free-time compression
- Narrow header layout
- Independent public state widget usage
- Production entry card at 200% text scaling

## Static validation executed in this environment

- Parsed every Dart source with a Dart tree-sitter grammar
- Resolved every relative import, export, and part URI
- Parsed root and example YAML
- Traversed public export graphs
- Checked duplicate public symbols
- Checked required 9.0 public component reachability
- Checked generic `const` type-variable patterns
- Checked package artifacts and stale lock files

Flutter and Dart SDK tools are not installed in this runtime. Therefore
`flutter analyze`, `flutter test`, platform builds, goldens, and integration
tests remain mandatory before release and are not reported as passed.
