# Neon Timeline Flutter — visual example catalog

The example app contains the complete maintained generation history from v4 to v16 plus the unified comparison dashboard.

## Responsive preview system

Every catalog card opens the real example inside a shared preview host:

| Mode | Logical size | Best for |
| --- | ---: | --- |
| Mobile | 390 × 844 | v7, v14, v16 |
| Tablet | 1024 × 768 | v6, v8–v12, v15 |
| Desktop | 1440 × 900 | Unified Hub, v4, v5, v13 |

The preview is scaled to the current window without changing the underlying layout constraints. Presentation mode removes the catalog chrome and leaves a clean capture surface.

## Run

```bash
cd example
flutter pub get
flutter run -d chrome
```

## Capture README images

Open a version, select its recommended viewport, enter presentation mode, and save the PNG using the canonical name in:

```text
../assets/screenshots/manifest.json
```

Each version has an isolated folder under `../assets/screenshots/`.

## Validate

```bash
cd ..
flutter analyze
flutter test
```
