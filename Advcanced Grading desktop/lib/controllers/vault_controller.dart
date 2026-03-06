// lib/controllers/vault_controller.dart
// ChangeNotifier controller for the Vault view.

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/vault_item.dart';
import '../services/vault_service.dart';
import '../services/export_service.dart';
import '../core/processing_utils.dart';

/// Controller for the Vault view.
class VaultController extends ChangeNotifier {
  final VaultService _vault;
  final ExportService _exporter;

  List<VaultItem> _items = [];
  String _searchQuery = '';

  VaultController({
    required VaultService vault,
    required ExportService exporter,
  })  : _vault = vault,
        _exporter = exporter;

  List<VaultItem> get items => _items;
  String get searchQuery => _searchQuery;
  bool get isEmpty => _items.isEmpty;

  /// Loads all vault items from local storage.
  void loadItems() {
    _items = _vault.loadAll();
    notifyListeners();
  }

  /// Updates the search query and refreshes the UI.
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Deletes a vault item by [id].
  Future<void> deleteItem(String id) async {
    await _vault.deleteItem(id);
    loadItems();
  }

  /// Exports a vault item's records to a CSV file.
  Future<String?> exportItem(VaultItem item) async {
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export ${item.fileName}',
      fileName: '${item.fileName}_export.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (savePath == null) return null;
    final result = await _exporter.exportToPath(item.records, savePath);
    return result.success ? result.filePath : null;
  }

  /// Searches records within a [VaultItem] by name.
  List<dynamic> searchRecords(VaultItem item, String query) {
    return filterByName(item.records, query);
  }

  /// Refreshes vault items (call after saves from HomeController).
  void refresh() => loadItems();
}
