/// Compact mobile-first planner and stable drag/resize APIs for 16.x.
library;

export 'src/v16/api/controller.dart';
export 'src/v16/api/entry_adapter.dart';
export 'src/v16/api/models.dart';
export 'src/v16/api/timeline_config.dart';
export 'src/v16/domain/time_scale.dart';
export 'src/v16/interaction/snap/snap_engine.dart';
export 'src/v16/theme/timeline_theme.dart';
export 'src/v16/widgets/controls/snap_slider.dart';
export 'src/v16/widgets/controls/time_range_slider.dart';
export 'src/v16/widgets/controls/zoom_slider.dart';
export 'src/v16/widgets/day_timeline_view.dart';
export 'src/v16/widgets/timeline.dart';

// Preserve every public 1.x-15.x API from the focused latest entrypoint.
export 'timeline_v15.dart';
