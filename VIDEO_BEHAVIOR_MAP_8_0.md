# Video behavior map 8.0

The supplied Structured planner recording was treated as an interaction reference, not as permission to copy application-owned screens.

| Observed behavior | Package implementation |
| --- | --- |
| Compact day/week selector above the timeline | Remains application-owned; the 8.0 example demonstrates a reusable header and controller integration. |
| Current/next task banner | Existing `TimelineDayInsight<T>` and Structured insight builder. |
| Warm time rail and task cards | 7.x Structured renderer retained and exposed through the 8.x advanced wrapper. |
| Long-press card lift | Existing long-press drag session retained. |
| Five-minute time badge while dragging | `TimelineReschedulePolicy.snap`, default five minutes. |
| Card follows pointer while the old position fades | Drag feedback and placeholder builders. |
| Delete target at the bottom | Optional delete-target builder and drop disposition. |
| Move constrained to the selected day | Day-bound `TimelineDateRange` policy. |
| Empty day with add action | Empty and gap insertion callbacks. |
| Locked external calendar item | `draggable: false` blocks move and resize. |
| Comfortable direct manipulation | 8.0 adds start/end resize handles, keyboard semantic actions, controlled navigation and safe async mutation state. |

The application continues to own its date header, task sheets, state management, persistence and branding.
