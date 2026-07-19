# 13.0 Workspace Design Refresh

This refresh replaces the first 13.0 compact visual pass while keeping the
package version at `13.0.0` and preserving all existing exports.

## Problems Addressed

- multiple red drag borders and status labels appeared at once;
- the delete target covered a large portion of the mobile viewport;
- the app-bar title was truncated by redundant actions;
- timeline markers consumed too much horizontal space;
- long compressed gaps repeated explanatory text;
- tinted cards made the schedule look visually noisy.

## New Direction

- indigo/slate workspace palette with neutral white or deep-navy surfaces;
- card accents on the top edge instead of a full-height leading stripe;
- 30-pixel dot markers while retaining accessible gesture targets;
- one compact drag status pill and a subtle target-range edge;
- centered fixed-size delete target with bounded visual text scaling;
- compact date navigation and consolidated mobile toolbar actions;
- shorter compressed gaps with their details moved to semantics.

## Compatibility

`UltimateStructuredTimelineConfig.advancedCompact()` activates the refreshed
layout. Existing balanced and comfortable configurations keep their previous
geometry and leading card accents. Host-owned persistence and callbacks are
unchanged.
