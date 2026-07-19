# Governance

## Ownership

The creator and lead maintainer controls the official package identity, release
keys, pub.dev publication, protected branches, and official documentation.

## Changes

- Public API changes require tests and migration notes.
- Breaking removals require a documented replacement and deprecation period.
- Performance claims require reproducible release/profile measurements.
- New dependencies require a written reason and platform-impact review.
- No contributor may publish an official release without explicit maintainer
  approval.

## Compatibility

The legacy Neon API remains supported until a future major release documents a
specific removal. New neutral APIs must not silently alter existing UI defaults.

## Security

Security reports follow `SECURITY.md`. Sensitive reports must not be disclosed
in public issues before coordination with the maintainer.
