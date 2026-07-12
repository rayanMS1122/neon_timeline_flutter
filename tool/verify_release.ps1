$ErrorActionPreference = "Stop"

flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test

Push-Location example
try {
  flutter clean
  flutter pub get
  flutter build web --release
}
finally {
  Pop-Location
}

Write-Host "Release checks completed. Serve example/build/web with a static HTTP server before Lighthouse."
