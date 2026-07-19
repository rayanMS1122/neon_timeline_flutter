/// Classic multi-view timeline platform introduced in version 4.x.
///
/// Provides the foundational data model, controller, render pipeline, views,
/// and theme that all later versions build upon.
///
/// Import this if you want to use only the V4 API:
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v4.dart';
/// ```
library;

export 'src/v4/core/timeline_analytics.dart';
export 'src/v4/core/timeline_controller.dart';
export 'src/v4/core/timeline_data_source.dart';
export 'src/v4/core/timeline_day_layout.dart';
export 'src/v4/core/timeline_performance_config.dart';
export 'src/v4/core/timeline_planning.dart';
export 'src/v4/core/timeline_render_plan.dart';
export 'src/v4/core/timeline_render_plan_builder.dart';
export 'src/v4/diagnostics/timeline_diagnostics.dart';
export 'src/v4/extensions/timeline_plugin.dart';
export 'src/v4/interactions/timeline_command.dart';
export 'src/v4/localization/timeline_localization.dart';
export 'src/v4/models/timeline_entry.dart';
export 'src/v4/models/timeline_resource.dart';
export 'src/v4/models/timeline_types.dart';
export 'src/v4/theme/timeline_theme.dart';
export 'src/v4/views/agenda_view.dart';
export 'src/v4/views/calendar_day_view.dart';
export 'src/v4/views/dependency_timeline_view.dart';
export 'src/v4/views/planner_view.dart';
export 'src/v4/views/presentation_view.dart';
export 'src/v4/views/resource_timeline_view.dart';
export 'src/v4/views/roadmap_view.dart';
export 'src/v4/views/schedule_view.dart';
export 'src/v4/views/timeline_card.dart';
export 'src/v4/views/timeline_components.dart';
export 'src/v4/views/timeline_view.dart';
export 'src/v4/views/timeline_workspace.dart';
