import 'package:flutter/foundation.dart';

enum TimelinePluginCapability {
  layout,
  renderer,
  action,
  marker,
  dataSource,
  exporter,
  diagnostics,
  suggestion,
}

/// Versioned extension point. The registry is host-owned, never global.
abstract interface class TimelinePlugin {
  String get id;
  String get version;
  Set<TimelinePluginCapability> get capabilities;
}

class TimelinePluginRegistry extends ChangeNotifier {
  final Map<String, TimelinePlugin> _plugins = <String, TimelinePlugin>{};

  List<TimelinePlugin> get plugins =>
      List<TimelinePlugin>.unmodifiable(_plugins.values);

  TimelinePlugin? operator [](String id) => _plugins[id];

  Iterable<TimelinePlugin> supporting(TimelinePluginCapability capability) {
    return _plugins.values.where(
      (plugin) => plugin.capabilities.contains(capability),
    );
  }

  void register(TimelinePlugin plugin, {bool replace = false}) {
    if (_plugins.containsKey(plugin.id) && !replace) {
      throw StateError('Timeline plugin "${plugin.id}" is already registered.');
    }
    _plugins[plugin.id] = plugin;
    notifyListeners();
  }

  bool unregister(String id) {
    final removed = _plugins.remove(id) != null;
    if (removed) notifyListeners();
    return removed;
  }

  void clear() {
    if (_plugins.isEmpty) return;
    _plugins.clear();
    notifyListeners();
  }
}
