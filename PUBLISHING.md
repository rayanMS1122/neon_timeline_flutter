# Publishing checklist

## 1. Verify ownership and naming

- Confirm that `neon_timeline_flutter` is available on pub.dev.
- If the name is occupied, change `name:` in `pubspec.yaml` and update every
  `package:neon_timeline_flutter/...` import in `example/` and `test/`.
- Replace or confirm the copyright holder in `LICENSE`.
- Add real `repository`, `issue_tracker`, and `homepage` fields to
  `pubspec.yaml` after the repository exists. Do not publish fake URLs.
- Keep the README screenshot gallery and the `screenshots:` entries in
  `pubspec.yaml` pointed at the same in-repo image files under `assets/`.

## 2. Validate locally

From the package root:

```bash
./tool/verify_release.sh
```

Inspect every file shown by the dry run. The package must not contain keys,
Firebase configuration, application secrets, build outputs, IDE caches, or
private application source.

## 3. Test a consuming app

Before publication, add the package to a separate Flutter app using a path
dependency:

```yaml
dependencies:
  neon_timeline_flutter:
    path: ../neon_timeline_flutter
```

Test Android, iOS, and web where relevant. Specifically verify:

- long-press drag and scroll interaction;
- slide actions in both text directions;
- reduced-motion behavior;
- dark and light themes;
- large text scaling;
- empty, one-item, overlap, and cross-midnight data;
- an asynchronous move callback that fails and retries.

## 4. Publish

Publishing requires a pub.dev account. A verified publisher is recommended for
an organization-owned package.

```bash
flutter pub publish
```

Old versions remain available after publication. Fixes require a new version,
so do not upload an untested build.

## 5. Release discipline

- Patch: bug fixes with compatible public API.
- Minor: backward-compatible features.
- Major: breaking API or behavior changes.
- Update `CHANGELOG.md` before every upload.
- Tag the matching repository commit after publication.

## Version 16 release gate

Before publishing 16.0.0, verify that `timeline_v16.dart`, the complete package
entrypoint, the v16 example, and every test under `test/v16/` compile on the
minimum supported Flutter version. Do not publish when the dry run reports
warnings about missing documentation, stale versions, unresolved dependencies,
or excluded source files.
