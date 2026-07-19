$ErrorActionPreference = "Stop"

foreach ($command in @("flutter", "dart")) {
  if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
    throw "Required command is unavailable: $command"
  }
}

$insideGit = Get-Command git -ErrorAction SilentlyContinue
if ($insideGit) {
  git rev-parse --is-inside-work-tree *> $null
}
if ($insideGit -and $LASTEXITCODE -eq 0) {
  $trackedGenerated = git ls-files | Where-Object {
    $_ -match '(^|/)(build|\.dart_tool)/' -or $_ -like '*.iml'
  } | Select-Object -First 1
  if ($trackedGenerated) {
    throw "Tracked generated build, .dart_tool, or IDE artifact is present: $trackedGenerated"
  }
}
else {
  $generated = Get-ChildItem -Recurse -Force -File | Where-Object {
    $_.FullName -match '[\\/](build|\.dart_tool)[\\/]' -or $_.Name -like '*.iml'
  } | Select-Object -First 1
  if ($generated) {
    throw "Generated build, .dart_tool, or IDE artifact is present: $($generated.FullName)"
  }
}

flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test benchmark tool example/lib example/test
flutter analyze
flutter test --coverage
dart run benchmark/timeline_engine_benchmark.dart
dart run benchmark/structured_planner_benchmark.dart
dart run benchmark/advanced_structured_timeline_benchmark.dart
dart run benchmark/v16_planner_viewport_benchmark.dart
flutter pub publish --dry-run

Push-Location example
try {
  flutter clean
  flutter pub get
  flutter analyze
  flutter test
  flutter build apk --release
  flutter build web --release
}
finally {
  Pop-Location
}

Write-Host "Release checks completed. Serve example/build/web with a static HTTP server before Lighthouse."
