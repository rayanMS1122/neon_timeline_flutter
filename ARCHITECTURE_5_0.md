# Architecture 5.0

## Goals

5.0 adds product-grade planning primitives without coupling the package to an
application database, state-management framework, backend, or AI provider.

## Layers

### Temporal index

`TimelineTemporalIndex<T>` sorts intervals once and stores a monotonic prefix of
maximum end values. Range queries can skip entries that cannot intersect the
requested window.

### Query engine

`TimelineQuery<T>` combines:

- date-window filtering;
- text search;
- status facets;
- resource facets;
- host predicates;
- stable sorting.

The result carries counts and duration metrics so a host does not need a second
full scan for basic filters.

### Recurrence engine

`TimelineRecurrenceRule` expands daily, weekly, and monthly rules only for the
window requested by the host. It does not store generated entries and does not
force a calendar library.

### Scenario engine

`TimelineScenarioEngine` compares immutable entry sets and reports additions,
removals, movement, resizing, status, resource, content, and availability
changes.

### UI layer

The new views are independent surfaces:

- Focus: current and next work;
- Board: lifecycle or host-defined groups;
- Matrix: resources against time;
- Overview: compressed interactive minimap;
- Scenario: visual change review;
- Command palette: keyboard-friendly product navigation.

## Compatibility

The 4.x core and legacy Neon layer are still exported. New 5.x APIs are
additive and share the same `TimelineEntry<T>`, theme tokens, controller, render
plan, analytics, and resource models.
