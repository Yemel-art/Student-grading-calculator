// lib/controllers/home_controller.dart
// ChangeNotifier controller for the Home view.
// Manages import state, processing pipeline, and preview data.

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student_record.dart';
import '../models/grade_boundary.dart';
import '../models/vault_item.dart';
import '../services/file_parser_service.dart';
import '../services/export_service.dart';
import '../services/vault_service.dart';
import '../core/processing_utils.dart';

/// Processing phases for the loading progress indicator.
enum ProcessingPhase {
  idle,
  selecting,
  reading,
  detecting,
  processing,
  complete,
  error,
}

/// Controller for the Home view — handles import, processing, and export.
class HomeController extends ChangeNotifier {
  final FileParserService _parser;
  final ExportService _exporter;
  final VaultService _vault;

  // ---------------------------------------------------------------------------
  // State fields
  // ---------------------------------------------------------------------------

  ProcessingPhase _phase = ProcessingPhase.idle;
  double _progress = 0.0;
  String _progressMessage = '';
  String? _errorMessage;

  List<StudentRecord> _allRecords = [];
  List<StudentRecord> _filteredRecords = [];
  String _searchQuery = '';
  String _currentFileName = '';

  String _detectedNameCol = '';
  String _detectedCaCol = '';
  String _detectedExamCol = '';
  List<String> _parseWarnings = [];

  List<GradeBoundary> _boundaries = [];

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  HomeController({
    required FileParserService parser,
    required ExportService exporter,
    required VaultService vault,
    required List<GradeBoundary> boundaries,
  })  : _parser = parser,
        _exporter = exporter,
        _vault = vault,
        _boundaries = boundaries;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  ProcessingPhase get phase => _phase;
  double get progress => _progress;
  String get progressMessage => _progressMessage;
  String? get errorMessage => _errorMessage;
  List<StudentRecord> get records => _filteredRecords;
  List<StudentRecord> get allRecords => _allRecords;
  String get searchQuery => _searchQuery;
  String get currentFileName => _currentFileName;
  String get detectedNameCol => _detectedNameCol;
  String get detectedCaCol => _detectedCaCol;
  String get detectedExamCol => _detectedExamCol;
  List<String> get parseWarnings => _parseWarnings;
  bool get hasData => _allRecords.isNotEmpty;
  bool get isProcessing =>
      _phase == ProcessingPhase.reading ||
      _phase == ProcessingPhase.detecting ||
      _phase == ProcessingPhase.processing;

  int get totalStudents => _allRecords.length;
  int get warningCount => _allRecords.where((r) => r.hasWarning).length;

  // ---------------------------------------------------------------------------
  // Public actions
  // ---------------------------------------------------------------------------

  /// Updates the list of grade boundaries (called when settings change).
  void updateBoundaries(List<GradeBoundary> boundaries) {
    _boundaries = boundaries;
    if (_allRecords.isNotEmpty) {
      // Recalculate grades with new boundaries
      _allRecords = assignGrades(_allRecords, _boundaries);
      _applySearch();
      notifyListeners();
    }
  }

  /// Opens a file picker and imports the selected file.
  Future<void> importFile() async {
    _setPhase(ProcessingPhase.selecting, 'Opening file picker…');

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        dialogTitle: 'Select Student Grade Sheet',
      );

      if (result == null || result.files.isEmpty) {
        _setPhase(ProcessingPhase.idle, '');
        return;
      }

      final file = result.files.first;
      final filePath = file.path;
      if (filePath == null) {
        _setError('Could not access the selected file path.');
        return;
      }

      _currentFileName = file.name;
      await _processFile(filePath, file.extension ?? 'csv');
    } catch (e) {
      _setError('Import failed: $e');
    }
  }

  /// Imports a CSV from a URL-exported Google Sheets CSV link.
  Future<void> importFromUrl(String url) async {
    // For demo purposes we show how this hook works.
    // In production, use http package to fetch the CSV data.
    _setError(
      'Google Sheets import: fetch the sheet as CSV and pass the content '
      'to importFromCsvString().',
    );
  }

  /// Imports directly from a CSV string (e.g. pasted or fetched from network).
  Future<void> importFromCsvString(String content, String sourceName) async {
    _setPhase(ProcessingPhase.processing, 'Parsing content…');
    _setProgress(0.3, 'Detecting columns…');

    final result = _parser.parseCsvString(content, _boundaries,
        sourceName: sourceName);

    _handleParseResult(result, sourceName);
  }

  /// Filters the displayed records by student name.
  void search(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  /// Saves the current records to the Vault.
  Future<void> saveToVault() async {
    if (_allRecords.isEmpty) return;

    final item = VaultItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: _currentFileName.isEmpty ? 'Imported Sheet' : _currentFileName,
      createdAt: DateTime.now(),
      records: List.unmodifiable(_allRecords),
    );

    await _vault.saveItem(item);
    notifyListeners();
  }

  /// Exports the current records to a CSV file.
  Future<String?> exportToCsv() async {
    if (_allRecords.isEmpty) return null;

    final baseName = _currentFileName.isEmpty
        ? 'grades_export'
        : _currentFileName.replaceAll(RegExp(r'\.[^.]+$'), '');

    final result = await _exporter.exportToCsv(_allRecords, baseName);
    return result.success ? result.filePath : null;
  }

  /// Exports to a user-chosen path.
  Future<String?> exportToChosenPath() async {
    if (_allRecords.isEmpty) return null;

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Grades As',
      fileName: 'grades_export.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (savePath == null) return null;

    final result = await _exporter.exportToPath(_allRecords, savePath);
    return result.success ? result.filePath : null;
  }

  /// Clears the current session data.
  void clearData() {
    _allRecords = [];
    _filteredRecords = [];
    _currentFileName = '';
    _parseWarnings = [];
    _detectedCaCol = '';
    _detectedExamCol = '';
    _setPhase(ProcessingPhase.idle, '');
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _processFile(String filePath, String extension) async {
    _setPhase(ProcessingPhase.reading, 'Reading file…');
    _setProgress(0.1, 'Loading $extension file…');

    await Future.delayed(const Duration(milliseconds: 100)); // let UI refresh

    _setProgress(0.4, 'Detecting columns…');
    _setPhase(ProcessingPhase.detecting, 'Detecting columns…');

    await Future.delayed(const Duration(milliseconds: 100));

    ParseResult result;
    if (extension.toLowerCase() == 'csv') {
      result = await _parser.parseCsv(filePath, _boundaries);
    } else {
      result = await _parser.parseExcel(filePath, _boundaries);
    }

    _setProgress(0.8, 'Calculating grades…');
    _setPhase(ProcessingPhase.processing, 'Calculating grades…');

    await Future.delayed(const Duration(milliseconds: 100));

    _handleParseResult(result, _currentFileName);
  }

  void _handleParseResult(ParseResult result, String sourceName) {
    if (!result.success) {
      _setError(result.errorMessage ?? 'Unknown parse error');
      return;
    }

    _allRecords = result.records;
    _parseWarnings = result.warnings;
    _detectedCaCol = result.detectedCaColumn;
    _detectedExamCol = result.detectedExamColumn;
    _detectedNameCol = result.detectedNameColumn;

    _applySearch();
    _setProgress(1.0, 'Done!');
    _setPhase(ProcessingPhase.complete, 'Processing complete');
    notifyListeners();
  }

  void _applySearch() {
    _filteredRecords = filterByName(_allRecords, _searchQuery);
  }

  void _setPhase(ProcessingPhase phase, String message) {
    _phase = phase;
    _progressMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _setProgress(double value, String message) {
    _progress = value;
    _progressMessage = message;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _phase = ProcessingPhase.error;
    notifyListeners();
  }
}
