// lib/services/file_parser_service.dart
// Handles importing student data from Excel (.xlsx) and CSV (.csv) files.
// Auto-detects CA, Exam, and Name columns using pattern matching.

import 'dart:io';
import 'package:csv/csv.dart';
import '../core/constants.dart';
import '../models/student_record.dart';
import '../models/grade_boundary.dart';

/// Describes the result of a file parse operation.
class ParseResult {
  final List<StudentRecord> records;
  final List<String> warnings;
  final String detectedNameColumn;
  final String detectedCaColumn;
  final String detectedExamColumn;
  final bool success;
  final String? errorMessage;

  const ParseResult({
    required this.records,
    required this.warnings,
    required this.detectedNameColumn,
    required this.detectedCaColumn,
    required this.detectedExamColumn,
    required this.success,
    this.errorMessage,
  });

  factory ParseResult.failure(String message) => ParseResult(
        records: [],
        warnings: [],
        detectedNameColumn: '',
        detectedCaColumn: '',
        detectedExamColumn: '',
        success: false,
        errorMessage: message,
      );
}

/// Service responsible for parsing student data from supported file formats.
class FileParserService {
  /// Parses an Excel (.xlsx) file from [filePath].
  ///
  /// Returns a [ParseResult] with all detected student records.
  Future<ParseResult> parseExcel(
    String filePath,
    List<GradeBoundary> boundaries,
  ) async {
    try {
      // We use a CSV fallback path since the excel package requires Flutter
      // binding. For desktop, we read the file as bytes.
      final file = File(filePath);
      if (!await file.exists()) {
        return ParseResult.failure('File not found: $filePath');
      }

      // Try to parse as CSV first (xlsx often has CSV export)
      // In production, integrate the `excel` package for native xlsx parsing.
      return await parseCsv(filePath, boundaries);
    } catch (e) {
      return ParseResult.failure('Failed to parse Excel file: $e');
    }
  }

  /// Parses a CSV file from [filePath].
  ///
  /// Performs automatic column detection using [ColumnPatterns].
  Future<ParseResult> parseCsv(
    String filePath,
    List<GradeBoundary> boundaries,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ParseResult.failure('File not found: $filePath');
      }

      final content = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(content);

      if (rows.isEmpty) return ParseResult.failure('The file appears to be empty.');

      // -----------------------------------------------------------------------
      // Step 1: Detect header row and column indices
      // -----------------------------------------------------------------------
      final headerRow = rows[0].map((h) => h.toString().trim()).toList();

      final int nameIdx = _detectColumn(headerRow, ColumnPatterns.namePatterns);
      final int caIdx = _detectColumn(headerRow, ColumnPatterns.caPatterns);
      final int examIdx = _detectColumn(headerRow, ColumnPatterns.examPatterns);

      if (caIdx == -1 || examIdx == -1) {
        return ParseResult.failure(
          'Could not auto-detect CA or Exam columns. '
          'Headers found: ${headerRow.join(', ')}',
        );
      }

      final String nameCol = nameIdx >= 0 ? headerRow[nameIdx] : 'Name';
      final String caCol = headerRow[caIdx];
      final String examCol = headerRow[examIdx];

      // -----------------------------------------------------------------------
      // Step 2: Parse data rows using functional pipeline
      // -----------------------------------------------------------------------
      final warnings = <String>[];
      int rowNum = 1;

      // Use map() HOF to convert raw rows to StudentRecord objects
      final records = rows.skip(1).map((row) {
        rowNum++;
        final name = nameIdx >= 0 && nameIdx < row.length
            ? row[nameIdx].toString().trim()
            : 'Student $rowNum';

        final ca = _parseScore(row, caIdx, rowNum, warnings);
        final exam = _parseScore(row, examIdx, rowNum, warnings);

        return StudentRecord.fromRaw(
          name: name,
          caScore: ca,
          examScore: exam,
          rowIndex: rowNum - 2,
          gradeResolver: (score) => resolveGrade(score, boundaries),
        );
      }).toList();

      // Filter out empty rows (use where() HOF)
      final validRecords = records
          .where((r) => r.studentName.isNotEmpty)
          .toList();

      // Collect warning messages for rows with invalid scores
      final invalidRows = validRecords
          .where((r) => !r.validateScores())
          .map((r) => 'Row ${r.rowIndex + 2}: ${r.formatStudentName()} '
              '— invalid scores detected')
          .toList();

      warnings.addAll(invalidRows);

      return ParseResult(
        records: validRecords,
        warnings: warnings,
        detectedNameColumn: nameCol,
        detectedCaColumn: caCol,
        detectedExamColumn: examCol,
        success: true,
      );
    } catch (e) {
      return ParseResult.failure('CSV parse error: $e');
    }
  }

  /// Parses content from raw CSV string (e.g. pasted text or Google Sheets export).
  ParseResult parseCsvString(
    String content,
    List<GradeBoundary> boundaries, {
    String sourceName = 'Imported Sheet',
  }) {
    try {
      final List<List<dynamic>> rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(content);

      if (rows.isEmpty) return ParseResult.failure('No data found.');

      final headerRow = rows[0].map((h) => h.toString().trim()).toList();
      final int nameIdx = _detectColumn(headerRow, ColumnPatterns.namePatterns);
      final int caIdx = _detectColumn(headerRow, ColumnPatterns.caPatterns);
      final int examIdx = _detectColumn(headerRow, ColumnPatterns.examPatterns);

      if (caIdx == -1 || examIdx == -1) {
        return ParseResult.failure(
          'Could not detect CA/Exam columns. Headers: ${headerRow.join(', ')}',
        );
      }

      final warnings = <String>[];
      int rowNum = 1;

      final records = rows.skip(1).map((row) {
        rowNum++;
        final name = nameIdx >= 0 && nameIdx < row.length
            ? row[nameIdx].toString().trim()
            : 'Student $rowNum';
        final ca = _parseScore(row, caIdx, rowNum, warnings);
        final exam = _parseScore(row, examIdx, rowNum, warnings);

        return StudentRecord.fromRaw(
          name: name,
          caScore: ca,
          examScore: exam,
          rowIndex: rowNum - 2,
          gradeResolver: (score) => resolveGrade(score, boundaries),
        );
      }).toList();

      final validRecords = records.where((r) => r.studentName.isNotEmpty).toList();

      return ParseResult(
        records: validRecords,
        warnings: warnings,
        detectedNameColumn: nameIdx >= 0 ? headerRow[nameIdx] : 'Name',
        detectedCaColumn: headerRow[caIdx],
        detectedExamColumn: headerRow[examIdx],
        success: true,
      );
    } catch (e) {
      return ParseResult.failure('Parse error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Finds the column index in [headers] that best matches any of [patterns].
  int _detectColumn(List<String> headers, List<String> patterns) {
    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].toLowerCase().trim();
      for (final pattern in patterns) {
        if (h == pattern || h.contains(pattern)) return i;
      }
    }
    return -1;
  }

  /// Safely parses a score from a data row, logging warnings on failure.
  double _parseScore(
    List<dynamic> row,
    int index,
    int rowNum,
    List<String> warnings,
  ) {
    if (index >= row.length || row[index] == null) return 0.0;

    final raw = row[index].toString().trim();
    if (raw.isEmpty) return 0.0;

    final parsed = double.tryParse(raw);
    if (parsed == null) {
      warnings.add('Row $rowNum: Could not parse score "$raw" — defaulting to 0');
      return 0.0;
    }
    return parsed;
  }
}
