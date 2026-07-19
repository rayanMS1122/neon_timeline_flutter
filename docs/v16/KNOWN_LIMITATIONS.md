# Known limitations

- Flutter compilation, analyzer, widget tests, coverage, and web build could not be executed in the delivery environment because the Flutter SDK was absent.
- Golden baselines are not included; trustworthy goldens depend on the target Flutter version, renderer, platform, fonts, and text scale.
- The package models one selected day at a time. Cross-midnight entries are included when they intersect the selected day, but host applications remain responsible for their domain semantics.
- Default package copy is German/neutral. Production localization should provide builders or wrap feedback in the application's localization layer.
- Conflict detection is interval based. Resource capacity, travel time, dependencies, availability, and team rules remain host policy.
- Compact overlap presentation communicates lanes and counts but does not turn the overview into a full horizontal calendar grid. Use the proportional editor for geometry-heavy scheduling.
- Smart fit uses generated row count as a deterministic overview heuristic. Set `fit` explicitly when the host layout has unusual constraints.
- Pinch and trackpad zoom remain features for future proportional-editor work; custom zoom controls are already exported.
