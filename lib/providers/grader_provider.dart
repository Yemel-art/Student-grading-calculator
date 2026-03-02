import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../models/student_record.dart';

enum GraderState { idle, loading, success, error }

class ParseWarning {
  final int rowNumber;
  final String studentName;
  final String issue;

  const ParseWarning({
    required this.rowNumber,
    required this.studentName,
    required this.issue,
  });
}

class GraderProvider extends ChangeNotifier {
  GraderState _state = GraderState.idle;
  GradeSummary? _summary;
  String _errorMessage = '';
  String? _fileName;
  List<ParseWarning> _warnings = [];

  // ── Getters ──────────────────────────────────
  GraderState get state => _state;
  GradeSummary? get summary => _summary;
  String get errorMessage => _errorMessage;
  String? get fileName => _fileName;
  List<ParseWarning> get warnings => _warnings;
  bool get hasWarnings => _warnings.isNotEmpty;

  // ── Public Actions ────────────────────────────
  Future<void> pickAndProcess() async {
    _setState(GraderState.loading);
    _warnings = [];

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        _setState(GraderState.idle);
        return;
      }

      final file = result.files.first;
      _fileName = file.name;

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _setError(
          'Could not read the file data.\n'
          'The file may be corrupted or empty.',
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 600)); // UX breathing room
      _processBytes(bytes);
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    }
  }

  void reset() {
    _state = GraderState.idle;
    _summary = null;
    _errorMessage = '';
    _fileName = null;
    _warnings = [];
    notifyListeners();
  }

  // ── Private Helpers ───────────────────────────
  void _processBytes(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);

      if (excel.sheets.isEmpty) {
        _setError('The Excel file appears to be empty (no sheets found).');
        return;
      }

      final sheet = excel.sheets.values.first;
      final rows = sheet.rows;

      if (rows.isEmpty) {
        _setError('The spreadsheet contains no data.');
        return;
      }

      // ── Find header columns ─────────────────
      final headerRow = rows[0];
      int nameCol = -1;
      int marksCol = -1;

      for (int i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell == null) continue;
        final val = cell.value?.toString().toLowerCase().trim() ?? '';
        if (val.contains('name') || val.contains('student')) nameCol = i;
        if (val.contains('mark') ||
            val.contains('score') ||
            val.contains('total') ||
            val.contains('point')) {
          marksCol = i;
        }
      }

      if (nameCol == -1) {
        _setError(
          'Could not find a Student Name column.\n\n'
          'Please ensure your spreadsheet has a column header '
          'containing "Name" or "Student".\n\n'
          'Example headers: "Student Name", "Name", "Student"',
        );
        return;
      }

      if (marksCol == -1) {
        _setError(
          'Could not find a Marks column.\n\n'
          'Please ensure your spreadsheet has a column header '
          'containing "Marks", "Score", "Total", or "Points".\n\n'
          'Example headers: "Total Marks", "Score", "Marks"',
        );
        return;
      }

      // ── Parse data rows ─────────────────────
      final students = <StudentRecord>[];

      for (int r = 1; r < rows.length; r++) {
        final row = rows[r];
        if (row.isEmpty) continue;

        final nameCell = nameCol < row.length ? row[nameCol] : null;
        final marksCell = marksCol < row.length ? row[marksCol] : null;

        final name = nameCell?.value?.toString().trim() ?? '';
        if (name.isEmpty) continue; // blank rows are silently skipped

        final rawMarks = marksCell?.value?.toString().trim() ?? '';
        if (rawMarks.isEmpty) {
          _warnings.add(ParseWarning(
            rowNumber: r + 1,
            studentName: name,
            issue: 'No marks value — row skipped',
          ));
          continue;
        }

        final marks = double.tryParse(rawMarks);
        if (marks == null) {
          _warnings.add(ParseWarning(
            rowNumber: r + 1,
            studentName: name,
            issue: 'Invalid marks value "$rawMarks" — row skipped',
          ));
          continue;
        }

        if (marks < 0 || marks > 100) {
          _warnings.add(ParseWarning(
            rowNumber: r + 1,
            studentName: name,
            issue: 'Marks out of range ($marks) — expected 0–100, row skipped',
          ));
          continue;
        }

        students.add(StudentRecord.fromRaw(name, marks));
      }

      if (students.isEmpty) {
        final detail = _warnings.isNotEmpty
            ? '\n\nSkipped rows:\n${_warnings.map((w) => '• Row ${w.rowNumber}: ${w.issue}').join('\n')}'
            : '';
        _setError('No valid student records found in the file.$detail');
        return;
      }

      _summary = GradeSummary(students);
      _setState(GraderState.success);
    } on FormatException catch (e) {
      _setError('The file could not be parsed. It may be corrupt.\n\nDetails: ${e.message}');
    } catch (e) {
      _setError('Failed to process the Excel file.\n\nDetails: $e');
    }
  }

  void _setState(GraderState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _state = GraderState.error;
    notifyListeners();
  }
}
