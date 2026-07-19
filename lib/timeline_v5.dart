/// Command palette, board, matrix, focus, scenario and recurrence APIs (version 5.x).
///
/// Builds on top of the V4 foundation and adds query, recurrence, and new views.
///
/// Import this if you want to use only the V5 API (includes V4):
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v5.dart';
/// ```
library;

// V5-specific core
export 'src/v5/core/timeline_query.dart';
export 'src/v5/core/timeline_recurrence.dart';
export 'src/v5/core/timeline_scenario.dart';
export 'src/v5/core/timeline_temporal_index.dart';

// V5-specific views
export 'src/v5/views/timeline_board_view.dart';
export 'src/v5/views/timeline_command_palette.dart';
export 'src/v5/views/timeline_focus_view.dart';
export 'src/v5/views/timeline_matrix_view.dart';
export 'src/v5/views/timeline_overview_strip.dart';
export 'src/v5/views/timeline_scenario_compare_view.dart';

// All V4 APIs are included
export 'timeline_v4.dart';
