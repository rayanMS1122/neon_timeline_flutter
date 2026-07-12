#!/usr/bin/env bash
set -euo pipefail

flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test

pushd example >/dev/null
flutter clean
flutter pub get
flutter build web --release
popd >/dev/null

echo "Release checks completed. Serve example/build/web with a static HTTP server before Lighthouse."
