# Video Behavior Map 7.0

The supplied Structured application video was treated as the interaction
reference for 7.0.

| Observed behavior | 7.0 package implementation |
| --- | --- |
| Compact time labels on the left | Start and end time rail |
| Rounded alarm marker | Default marker capsule |
| Soft rose task cards | Structured light style and entry color tint |
| Current task banner | Current insight banner with remaining duration |
| Next task spacing | Gap rows and next insight |
| Insert task in free time | `onInsert` callback with exact gap |
| Long press lifts a task | Overlay-based lifted drag preview |
| Time badge follows movement | Snapped drag time badge |
| Five-minute movement steps | Default `TimelineReschedulePolicy.snap` |
| Haptic feedback while moving | One selection haptic per changed snap index |
| Timeline scrolls near screen edges | Continuous drag-only auto-scroll using `TimelineAutoScrollPolicy` |
| Task remains inside the day | Complete-entry day-bound clamping |
| Locked calendar entry | `draggable: false` and external marker |
| Completion circle | Async `onComplete` action |
| Reordered timeline after drop | Host persistence callback followed by rebuild |

The package intentionally does not copy the application's date page, bottom
navigation, task sheet, Cubit, repository, or database.
