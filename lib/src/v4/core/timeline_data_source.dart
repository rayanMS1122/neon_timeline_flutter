import 'package:flutter/foundation.dart';

import '../models/timeline_entry.dart';

/// Backend-independent source contract for future paged and live adapters.
abstract class TimelineDataSource<T> extends Listenable {
  List<TimelineEntry<T>> get entries;
  Object? get revision;
}

/// Mutable in-memory source suitable for local state and examples.
class ListTimelineDataSource<T> extends ChangeNotifier
    implements TimelineDataSource<T> {
  ListTimelineDataSource([Iterable<TimelineEntry<T>>? entries])
    : _entries = List<TimelineEntry<T>>.unmodifiable(
        entries ?? <TimelineEntry<T>>[],
      );

  List<TimelineEntry<T>> _entries;
  int _revision = 0;

  @override
  List<TimelineEntry<T>> get entries => _entries;

  @override
  Object get revision => _revision;

  void replaceAll(Iterable<TimelineEntry<T>> entries) {
    _entries = List<TimelineEntry<T>>.unmodifiable(entries);
    _revision++;
    notifyListeners();
  }
}
