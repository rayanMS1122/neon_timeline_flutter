#!/usr/bin/env bash
set -euo pipefail

for command in flutter dart; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Required command is unavailable: $command" >&2
    exit 127
  fi
done

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git ls-files | grep -E '(^|/)(build|\.dart_tool)/|\.iml$'; then
    echo 'Tracked generated build, .dart_tool, or IDE artifacts are present.' >&2
    exit 1
  fi
elif find . -type f \( \
  -path './build/*' -o \
  -path './example/build/*' -o \
  -path '*/.dart_tool/*' -o \
  -name '*.iml' \
\) -print -quit | grep -q .; then
  echo 'Generated build, .dart_tool, or IDE artifacts are present in the release tree.' >&2
  exit 1
fi

flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed \
  lib test benchmark tool example/lib example/test
flutter analyze
flutter test --coverage
dart run benchmark/timeline_engine_benchmark.dart
dart run benchmark/structured_planner_benchmark.dart
dart run benchmark/advanced_structured_timeline_benchmark.dart
dart run benchmark/v16_planner_viewport_benchmark.dart
flutter pub publish --dry-run

pushd example >/dev/null
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build web --release
popd >/dev/null

echo 'Release checks completed. Serve example/build/web with a static HTTP server before Lighthouse.'
