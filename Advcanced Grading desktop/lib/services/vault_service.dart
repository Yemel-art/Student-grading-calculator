// lib/services/vault_service.dart
// Handles local persistence of processed grading sessions using Hive.

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/vault_item.dart';

/// Service for reading and writing [VaultItem] entries to local storage.
class VaultService {
  static const String _boxName = HiveBoxes.vaultBox;

  /// Initialises Hive and opens the vault box.
  ///
  /// Must be called once before any vault operations (typically in main()).
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Box get _box => Hive.box(_boxName);

  /// Saves a [VaultItem] to the vault.
  ///
  /// Uses the item's [id] as the Hive key.
  Future<void> saveItem(VaultItem item) async {
    final encoded = jsonEncode(item.toMap());
    await _box.put(item.id, encoded);
  }

  /// Loads all saved [VaultItem] entries, sorted newest-first.
  List<VaultItem> loadAll() {
    final items = <VaultItem>[];

    for (final key in _box.keys) {
      try {
        final raw = _box.get(key) as String?;
        if (raw == null) continue;
        final decoded = jsonDecode(raw) as Map<dynamic, dynamic>;
        items.add(VaultItem.fromMap(decoded));
      } catch (_) {
        // Skip corrupted entries silently
      }
    }

    // Sort newest-first
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Retrieves a single [VaultItem] by [id].
  VaultItem? getItem(String id) {
    try {
      final raw = _box.get(id) as String?;
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<dynamic, dynamic>;
      return VaultItem.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Deletes a [VaultItem] by [id].
  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  /// Clears all vault entries.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Returns the number of saved items.
  int get count => _box.length;
}
