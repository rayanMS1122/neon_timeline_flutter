# Changed files 8.0

- Changed paths: **37**
- Insertions: **5313**
- Deletions: **223**

## Diff inventory

- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/CHANGELOG.md` — +13 / -0
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/README.md` — +29 / -3
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/example/lib/main.dart` — +4 / -5
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/example/pubspec.yaml` — +2 / -2
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/lib/neon_timeline_flutter.dart` — +1 / -1
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/lib/src/v7/models/structured_timeline_details.dart` — +39 / -0
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/lib/src/v7/models/structured_timeline_style.dart` — +8 / -0
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/lib/src/v7/widgets/structured_timeline_view.dart` — +355 / -207
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/lib/structured_planner.dart` — +1 / -1
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/pubspec.yaml` — +4 / -4
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/tool/verify_release.ps1` — +1 / -0
- `/mnt/data/v8_work/{neon_timeline_flutter_7_0_0 => neon_timeline_flutter_8_0_0}/tool/verify_release.sh` — +1 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/ADVANCED_STRUCTURED_TIMELINE_8_0.md}` — +56 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/API_CHANGES_8_0.md}` — +40 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/ARCHITECTURE_8_0.md}` — +29 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/MIGRATION_8_0.md}` — +24 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/PERFORMANCE_8_0.md}` — +22 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/RELEASE_REPORT_8_0.md}` — +24 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/TESTING_8_0_CHECKLIST.md}` — +12 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/TEST_REPORT_8_0.md}` — +22 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/VERSION_GALLERY_8_0.md}` — +16 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/VIDEO_BEHAVIOR_MAP_8_0.md}` — +19 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/benchmark/advanced_structured_timeline_benchmark.dart}` — +93 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/example/lib/screens/v8/v8_advanced_structured_showcase.dart}` — +782 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/example/lib/screens/version_gallery.dart}` — +645 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/core/structured_timeline_controller.dart}` — +222 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/core/timeline_mutation_coordinator.dart}` — +137 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/core/timeline_resize.dart}` — +239 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/core/timeline_slot_suggestions.dart}` — +158 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/core/timeline_viewport_index.dart}` — +122 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/models/advanced_structured_timeline_details.dart}` — +122 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/models/structured_timeline_layout.dart}` — +228 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/widgets/advanced_structured_timeline.dart}` — +1246 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/src/v8/widgets/advanced_structured_timeline_planner.dart}` — +246 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/lib/timeline_v8.dart}` — +13 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/test/advanced_structured_timeline_test.dart}` — +100 / -0
- `/{dev/null => mnt/data/v8_work/neon_timeline_flutter_8_0_0/test/timeline_v8_core_test.dart}` — +238 / -0
