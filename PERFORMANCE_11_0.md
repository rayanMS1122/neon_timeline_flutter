# Performance 11.0

The new live drag session reuses one magnetic reschedule engine and replaces
candidate data only when the host revision changes. Snap hysteresis avoids
repeated UI state changes around the same target. Slot ranking materializes no
widgets and is suitable for isolates or background planning logic.

No numeric benchmark claims are made until `dart run benchmark/...` and Flutter
profile/release measurements are run on real hardware.
