# Migration to 12.0

12.0 requires Dart 3.12+ and Flutter 3.44+. This enables multi-view semantic
announcements, typed scroll cache extents and precision-preserving color APIs.
Upgrade the Flutter toolchain before resolving the package.

No legacy entrypoint was removed. Existing 11.x construction remains valid:

```dart
config: const StructuredTimelineV11Config.production(),
```

That path preserves the header-free 11.x presentation. To opt into the 12.x
responsive header and production interaction tokens, change only the config:

```dart
config: const UltimateStructuredTimelineConfig.production(),
```

Prefer `timeline_v12.dart` for focused imports. `structured_planner.dart` and
the main package entrypoint now include 12.x. Existing `entryBuilder` remains;
new code can use `ultimateEntryBuilder` for unified details.

Run the full validation commands listed in `RELEASE_REPORT_12_0.md` before
publishing.
