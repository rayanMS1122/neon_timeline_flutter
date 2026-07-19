# Video behavior map — 6.0

The reference recording was used as an interaction specification, not as a
request to copy the complete Structured UI into the package.

| Observed planner behavior | Package 6.0 support |
| --- | --- |
| Vertical day timeline with start/end/duration | `TimelineDayPlan<T>` normalized entries |
| Free blocks between tasks | `TimelineDayGap<T>` with previous/next context |
| Tap a free block to create work | host renders a gap and uses its start/end in its own callback |
| Overlap/conflict indication | `TimelineDayConflict<T>` and per-entry conflict type |
| Current task and next countdown | `TimelineDayInsight<T>` |
| Long-press vertical move | `TimelineRescheduleSession<T>` |
| Five-minute snapping | `TimelineReschedulePolicy.snap` |
| Haptic only when snap value changes | compare consecutive `snapIndex` values |
| Floating new-time preview | render `TimelineReschedulePreview.start/end` in the host |
| Clamp inside day | reschedule bounds and `keepEntireEntryInBounds` |
| Drag-to-delete target | `resolveDrop(overDeleteTarget: true)` |
| Edge auto-scroll | `TimelineAutoScrollPolicy` |
| Week strip with activity dots | `TimelineWeekPlan<T>` plus `TimelineActivityIndex<T>` |
| Month date sheet with activity markers | `TimelineActivityIndex<T>` |
| Compact seven-day vertical lanes | `TimelineWeekLane<T>.layoutItems` and `anchorFraction` |
| Recurring task instances | `TimelineSeriesExpander<T>` |
| Move/delete one occurrence | occurrence override and deleted override handling |
| External calendar entries | `TimelineSeriesItemKind.external` and non-draggable mapping |
| Conflict push-forward action | `TimelineConflictSolver.pushForward` proposals |

Visual cards, gradients, navigation, sheets, localization strings, and app
branding remain application-owned.
