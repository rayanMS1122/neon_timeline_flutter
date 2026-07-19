# Release Report 14.0

## Release

- Package version: `14.0.0`
- Primary entrypoint: `timeline_v14.dart`
- Focused planner entrypoint: `structured_planner.dart`
- Compatibility: all v1-v13 exports retained

## Main additions

- Friendly icon-led workspace and navigation
- Seven semantic icon color tones
- Adaptive friendly task cards with visible drag affordance
- Guided drag feedback with live time ribbon
- Smart-snap and conflict communication using icon plus text
- Origin placeholder that remains safe under unbounded list height
- Bottom drag companion
- Light, dark, compact and sunrise-friendly theme presets
- Responsive desktop and mobile controls
- Public drag feedback and placeholder hooks in `UltimateStructuredTimeline<T>`

## Validation status

Static syntax, import, export and packaging checks passed. Flutter SDK validation remains required in an SDK-equipped environment; no unexecuted build or test is reported as successful.
