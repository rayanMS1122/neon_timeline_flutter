# Release report — 15.0.1

## Purpose

Restore v15 Flutter compilation after the 15.0.0 theme model omitted its
instance-field declarations and the planner initialized a generic drag state in
an invalid const expression.

## Scope

This is a narrow compilation hotfix. It preserves the v15 Ultra public API,
visual design, controller model, sliders, drag presentation, geometry modules,
and all legacy exports.

## Validation summary

- Package version: `15.0.1`
- Dart files parsed: 267
- Syntax problem files: 0
- Missing relative imports/exports/parts: 0
- Theme getters from supplied compiler log without fields: 0
- Generic v15 const invocations using `T`: 0
- Patch generated from the exact released 15.0.0 archive
- Patch application compared against the 15.0.1 work tree
- ZIP integrity checked

## Limitation

The environment does not contain Flutter or Dart executables, so no successful
Flutter analyzer, test, Chrome run, or release web build is claimed here.
