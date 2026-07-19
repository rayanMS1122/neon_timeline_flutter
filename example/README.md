# Neon Timeline Flutter example gallery

This application is the visual catalog for every maintained package generation from v4 through v16. It is designed for both interactive API verification and clean README screenshots.

## What changed

Every showcase opens inside a shared preview shell with:

- Mobile, Tablet, and Desktop logical viewports.
- Automatic fit-to-window scaling, so large workspaces are not clipped.
- Presentation mode for clean screenshots.
- A consistent dark preview stage and device frame.
- Version-specific accent colors and searchable catalog cards.
- Mouse, touch, trackpad, and stylus scrolling support.

The underlying examples remain real interactive widgets. The preview shell only controls the viewport and framing.

## Run

```bash
flutter pub get
flutter run
```

For web screenshots:

```bash
flutter run -d chrome
```

## Screenshot assets

Use the folder structure in `../assets/screenshots/`. Every version has its own folder, recommended viewport, and canonical PNG file name. The machine-readable list is stored in `../assets/screenshots/manifest.json`.

See `../SCREENSHOT_GUIDE.md` for the complete capture workflow.

## Validate

From the package root:

```bash
flutter analyze
flutter test
```
