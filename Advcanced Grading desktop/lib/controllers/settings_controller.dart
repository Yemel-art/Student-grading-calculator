// lib/controllers/settings_controller.dart
// ChangeNotifier controller for the Settings view.
// Manages grade boundaries and theme preference.

import 'package:flutter/foundation.dart';
import '../models/grade_boundary.dart';
import '../services/settings_service.dart';

/// Controller for the Settings view.
class SettingsController extends ChangeNotifier {
  final SettingsService _settings;

  List<GradeBoundary> _boundaries = [];
  bool _isDarkMode = false;

  SettingsController({required SettingsService settings})
      : _settings = settings {
    _load();
  }

  List<GradeBoundary> get boundaries => List.unmodifiable(_boundaries);
  bool get isDarkMode => _isDarkMode;

  /// Returns the current grade boundaries (mutable copy for editing).
  List<GradeBoundary> get editableBoundaries => List.from(_boundaries);

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _settings.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _settings.saveIsDarkMode(value);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Grade boundaries
  // ---------------------------------------------------------------------------

  /// Persists the [updated] boundaries list.
  Future<void> saveBoundaries(List<GradeBoundary> updated) async {
    _boundaries = List.from(updated)
      ..sort((a, b) => b.minScore.compareTo(a.minScore));
    await _settings.saveBoundaries(_boundaries);
    notifyListeners();
  }

  /// Resets to factory default boundaries.
  Future<void> resetToDefaults() async {
    await _settings.resetBoundaries();
    _boundaries = buildDefaultBoundaries();
    notifyListeners();
  }

  /// Updates a single boundary at [index].
  void updateBoundaryAt(int index, GradeBoundary updated) {
    if (index < 0 || index >= _boundaries.length) return;
    _boundaries[index] = updated;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _load() {
    _boundaries = _settings.loadBoundaries();
    _isDarkMode = _settings.loadIsDarkMode();
  }
}
