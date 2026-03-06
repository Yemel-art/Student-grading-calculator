// lib/services/settings_service.dart
// Handles persistence of app settings (grade boundaries, theme) using Hive.

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/grade_boundary.dart';

/// Service for reading and writing application settings.
class SettingsService {
  static const String _boxName = HiveBoxes.settingsBox;
  static const String _boundariesKey = 'grade_boundaries';
  static const String _themeKey = 'is_dark_mode';

  /// Opens the settings Hive box (call during app initialisation).
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Box get _box => Hive.box(_boxName);

  // ---------------------------------------------------------------------------
  // Grade boundaries
  // ---------------------------------------------------------------------------

  /// Loads persisted grade boundaries, or returns defaults if none saved.
  List<GradeBoundary> loadBoundaries() {
    try {
      final raw = _box.get(_boundariesKey) as String?;
      if (raw == null) return buildDefaultBoundaries();

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => GradeBoundary.fromMap(e as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => b.minScore.compareTo(a.minScore));
    } catch (_) {
      return buildDefaultBoundaries();
    }
  }

  /// Persists [boundaries] to local storage.
  Future<void> saveBoundaries(List<GradeBoundary> boundaries) async {
    final encoded = jsonEncode(boundaries.map((b) => b.toMap()).toList());
    await _box.put(_boundariesKey, encoded);
  }

  /// Resets grade boundaries to factory defaults.
  Future<void> resetBoundaries() async {
    await _box.delete(_boundariesKey);
  }

  // ---------------------------------------------------------------------------
  // Theme preference
  // ---------------------------------------------------------------------------

  /// Returns whether dark mode is currently enabled.
  bool loadIsDarkMode() {
    return _box.get(_themeKey, defaultValue: false) as bool;
  }

  /// Persists the dark mode preference.
  Future<void> saveIsDarkMode(bool isDark) async {
    await _box.put(_themeKey, isDark);
  }
}
