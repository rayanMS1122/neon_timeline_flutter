# Roadmap after the 4.0 foundation

This file separates implemented code from future work. Items below are not
claimed as complete.

## Must complete before a public release

- Run formatter, analyzer, full tests, example tests, and publish dry-run with a
  real Flutter SDK.
- Add golden coverage for every new theme in light, dark, RTL, high-contrast,
  and large-text configurations.
- Benchmark 10, 100, 500, 1,000, and 5,000 entry engine cases.
- Validate Android, iOS, Web, Windows, macOS, and Linux builds.
- Add drag rollback and asynchronous failure tests through the neutral views.
- Review public naming and documentation for consistency.

## Implemented foundation modules

- Resource-capacity rules and overbooking analysis.
- Dependency graph, cycle detection, earliest starts, and critical-chain engine.

## Next platform modules

- Resource-row and dependency-connector view widgets.
- Recurrence rules and exceptions.
- Resizing handles and keyboard alternatives.
- Multi-selection and batch commands.
- Export adapters for image, print, JSON, CSV, and calendar formats.
- Paged and stream data-source adapters.
- Collaboration overlays without a backend dependency.
- Optional suggestion-provider interfaces.

## Explicit non-goals for the core

- Owning application persistence.
- Requiring a state-management package.
- Requiring Firebase, Supabase, or another backend.
- Injecting creator branding into applications using the package.
