import 'models.dart';

/// Projects arbitrary application data into stable timeline snapshots.
abstract class NeonPlannerEntryAdapter<T> {
  /// Creates an entry adapter.
  const NeonPlannerEntryAdapter();

  /// Returns a stable identity for [entry].
  Object idOf(T entry);

  /// Returns the inclusive start time.
  DateTime startOf(T entry);

  /// Returns the exclusive end time.
  DateTime endOf(T entry);

  /// Returns visual and semantic metadata.
  NeonPlannerEntryPresentation presentationOf(T entry);

  /// Builds an immutable snapshot.
  NeonPlannerEntrySnapshot<T> snapshotOf(T entry) {
    return NeonPlannerEntrySnapshot<T>(
      id: idOf(entry),
      data: entry,
      start: startOf(entry),
      end: endOf(entry),
      presentation: presentationOf(entry),
    );
  }
}
