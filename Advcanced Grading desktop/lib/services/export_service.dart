// lib/services/export_service.dart
// Handles exporting processed student records to CSV format for local storage.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/student_record.dart';

/// Result of an export operation.
class ExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;

  const ExportResult({required this.success, this.filePath, this.errorMessage});

  factory ExportResult.failure(String msg) =>
      ExportResult(success: false, errorMessage: msg);
}

/// Service responsible for exporting student data to local files.
class ExportService {
  /// Exports [records] to a CSV file named [fileName].
  ///
  /// Saves to the user's Documents directory on Windows.
  Future<ExportResult> exportToCsv(
    List<StudentRecord> records,
    String fileName,
  ) async {
    try {
      final directory = await _getExportDirectory();
      final safeFileName = _sanitizeFileName(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = path.join(
        directory.path,
        '${safeFileName}_$timestamp.csv',
      );

      final csvContent = _buildCsvContent(records);
      final file = File(outputPath);
      await file.writeAsString(csvContent);

      return ExportResult(success: true, filePath: outputPath);
    } catch (e) {
      return ExportResult.failure('Export failed: $e');
    }
  }

  /// Exports [records] to a specific [filePath] chosen by the user.
  Future<ExportResult> exportToPath(
    List<StudentRecord> records,
    String filePath,
  ) async {
    try {
      final csvContent = _buildCsvContent(records);
      final file = File(filePath);
      await file.writeAsString(csvContent);
      return ExportResult(success: true, filePath: filePath);
    } catch (e) {
      return ExportResult.failure('Export failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Builds a properly formatted CSV string from [records].
  String _buildCsvContent(List<StudentRecord> records) {
    final buffer = StringBuffer();

    // Header row
    buffer.writeln('Student Name,CA Score,Exam Score,Final Score,Grade,Status');

    // Data rows using forEach HOF
    records.forEach((record) {
      final name = _escapeCsv(record.formatStudentName());
      final status = record.hasWarning ? 'WARNING' : 'OK';
      buffer.writeln(
        '$name,${record.caScore},${record.examScore},'
        '${record.finalScore},${record.grade},$status',
      );
    });

    return buffer.toString();
  }

  /// Returns the best export directory for the current platform.
  Future<Directory> _getExportDirectory() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final exportDir = Directory(path.join(docs.path, 'StudentGradingCalculator'));
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      return exportDir;
    } catch (_) {
      // Fallback to temp directory
      return await getTemporaryDirectory();
    }
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
