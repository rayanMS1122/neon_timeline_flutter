# Changed Files 4.0 — Advanced Upgrade

Compared with the uploaded 4.0 foundation baseline commit `99be3552984a2f131f810e8e6e6a9c458c1fcd20`.

- Changed paths: 46
- Added: 12
- Modified: 34
- Deleted: 0
- Insertions: 6554
- Deletions: 590

This report describes only the advanced upgrade performed on top of the uploaded
4.0 foundation. It does not repeat the older 3.4.3-to-4.0 foundation diff.

## Added (12)

- `ADVANCED_UI_4_0.md`
- `lib/src/v4/core/timeline_analytics.dart`
- `lib/src/v4/core/timeline_day_layout.dart`
- `lib/src/v4/localization/timeline_localization.dart`
- `lib/src/v4/models/timeline_resource.dart`
- `lib/src/v4/views/calendar_day_view.dart`
- `lib/src/v4/views/dependency_timeline_view.dart`
- `lib/src/v4/views/resource_timeline_view.dart`
- `lib/src/v4/views/timeline_components.dart`
- `lib/src/v4/views/timeline_workspace.dart`
- `test/timeline_advanced_engine_v4_test.dart`
- `test/timeline_advanced_views_v4_test.dart`

## Modified (34)

- `.github/workflows/ci.yml`
- `API_CHANGES_4_0.md`
- `ARCHITECTURE_4_0.md`
- `CHANGED_FILES_4_0.md`
- `CHANGELOG.md`
- `MIGRATION_4_0.md`
- `PERFORMANCE_4_0.md`
- `README.md`
- `RELEASE_REPORT_4_0.md`
- `STATIC_VALIDATION_4_0.json`
- `TEST_REPORT_4_0.md`
- `benchmark/timeline_engine_benchmark.dart`
- `example/lib/main.dart`
- `example/lib/screens/v4_platform_showcase.dart`
- `example/test/widget_test.dart`
- `lib/src/v4/core/timeline_controller.dart`
- `lib/src/v4/core/timeline_performance_config.dart`
- `lib/src/v4/core/timeline_planning.dart`
- `lib/src/v4/core/timeline_render_plan.dart`
- `lib/src/v4/core/timeline_render_plan_builder.dart`
- `lib/src/v4/interactions/timeline_command.dart`
- `lib/src/v4/models/timeline_entry.dart`
- `lib/src/v4/models/timeline_types.dart`
- `lib/src/v4/theme/timeline_theme.dart`
- `lib/src/v4/views/agenda_view.dart`
- `lib/src/v4/views/schedule_view.dart`
- `lib/src/v4/views/timeline_card.dart`
- `lib/src/v4/views/timeline_view.dart`
- `lib/timeline_core.dart`
- `lib/timeline_views.dart`
- `test/timeline_infrastructure_v4_test.dart`
- `test/timeline_planning_v4_test.dart`
- `tool/verify_release.ps1`
- `tool/verify_release.sh`
