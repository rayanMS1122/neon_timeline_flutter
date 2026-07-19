/// Neon Timeline Flutter — complete timeline and planner platform.
///
/// This is the all-in-one import. It re-exports every version of the API,
/// from the legacy Neon 3.x API through V16 (compact mobile-first planner).
///
/// ## Choose your version import
///
/// If you only need a specific version, use the versioned entrypoint instead
/// of this file — it compiles faster and gives you a focused API surface:
///
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v16.dart'; // V16 + all previous
/// import 'package:neon_timeline_flutter/timeline_v15.dart'; // V15 + all previous
/// import 'package:neon_timeline_flutter/timeline_v14.dart'; // V14 + all previous
/// import 'package:neon_timeline_flutter/timeline_v13.dart'; // V13 + all previous
/// import 'package:neon_timeline_flutter/timeline_v12.dart'; // V12 + all previous
/// import 'package:neon_timeline_flutter/timeline_v11.dart'; // V11 + all previous
/// import 'package:neon_timeline_flutter/timeline_v10.dart'; // V10 + all previous
/// import 'package:neon_timeline_flutter/timeline_v9.dart';  // V9  + all previous
/// import 'package:neon_timeline_flutter/timeline_v8.dart';  // V8  + all previous
/// import 'package:neon_timeline_flutter/timeline_v7.dart';  // V7  + all previous
/// import 'package:neon_timeline_flutter/timeline_v6.dart';  // V6  + all previous
/// import 'package:neon_timeline_flutter/timeline_v5.dart';  // V5  + all previous
/// import 'package:neon_timeline_flutter/timeline_v4.dart';  // V4  only
/// ```
///
/// ## Import everything (this file)
/// ```dart
/// import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
/// ```
library;

// Legacy Neon 3.x API (NeonTimeline, NeonTimelineItem, etc.)
export 'neon_legacy.dart';

// V16 cascades all the way down to V4
export 'timeline_v16.dart';
