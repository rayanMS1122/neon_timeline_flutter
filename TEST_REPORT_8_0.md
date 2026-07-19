# Test report 8.0

## Added automated coverage

- controller navigation, selection, nudge, zoom and invalidation;
- end-edge resize snapping;
- conflict-blocked resize;
- viewport interval slicing;
- ranked free-slot suggestions;
- duplicate async mutation rejection;
- advanced widget selection and resize handles;
- controller-driven jump and zoom behavior.

## Mandatory release run

```bash
./tool/verify_release.sh
```

The script formats sources, analyzes package and example, runs tests and all three benchmarks, builds Android/Web examples and performs `flutter pub publish --dry-run`.

Flutter and Dart were not present in the artifact-generation environment, so these runtime checks are not falsely reported as passed.

## Static generation-environment result

The final tree contains 166 Dart files and 35 root test files. The custom static pass found no missing relative imports, delimiter failures, YAML errors, generated build artifacts, duplicate public type exports or missing 8.x symbols from `structured_planner.dart`.
