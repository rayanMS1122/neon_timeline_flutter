# Performance 10.0

The main architectural correction is coordinate-based dragging. It avoids repeatedly pretending that every rendered pixel has the same time density. The coordinate map is built once per widget build and queried with binary search during drag. Conflict queries continue through the temporal index.

10.0 also supports a 16 ms edge-scroll loop in the delight preset, while battery-saver mode uses 32 ms. No performance numbers are claimed because Flutter benchmarks were not executable in the current environment. Run `dart run benchmark/timeline_engine_benchmark.dart` and the release verification script on a Flutter machine before publication.
