// lib/models/student_record.dart
// Core data model representing a single student's grade record.
// Implements validation, formatting, and grade calculation logic.

import '../core/constants.dart';

/// Represents a single student's grade record.
///
/// This class encapsulates all grade-related data for one student,
/// including raw CA and Exam scores, calculated final score, grade,
/// and validation state.
class StudentRecord {
  /// The student's display name
  final String studentName;

  /// Continuous Assessment score (max 30)
  final double caScore;

  /// Examination score (max 70)
  final double examScore;

  /// Calculated final score (CA + Exam, max 100)
  final double finalScore;

  /// Assigned letter grade (A/B/C/D/F)
  final String grade;

  /// Whether this record has any invalid/out-of-range scores
  final bool hasWarning;

  /// Original row index in the source file (for reference)
  final int rowIndex;

  const StudentRecord({
    required this.studentName,
    required this.caScore,
    required this.examScore,
    required this.finalScore,
    required this.grade,
    this.hasWarning = false,
    this.rowIndex = 0,
  });

  // ---------------------------------------------------------------------------
  // Method 1: validateScores()
  // Checks all score constraints are within valid bounds.
  // Returns true if all scores are valid.
  // ---------------------------------------------------------------------------

  /// Validates that all scores are within permitted ranges.
  ///
  /// Rules enforced:
  ///   - CA score must be between 0 and 30
  ///   - Exam score must be between 0 and 70
  ///   - Final score must be between 0 and 100
  ///
  /// Returns [true] if all constraints pass; [false] otherwise.
  bool validateScores() {
    if (caScore < ScoreConstraints.minScore ||
        caScore > ScoreConstraints.maxCaScore) {
      return false;
    }
    if (examScore < ScoreConstraints.minScore ||
        examScore > ScoreConstraints.maxExamScore) {
      return false;
    }
    if (finalScore < ScoreConstraints.minScore ||
        finalScore > ScoreConstraints.maxFinalScore) {
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Method 2: formatStudentName()
  // Formats the student name with proper title-case capitalisation.
  // ---------------------------------------------------------------------------

  /// Returns the student's name properly formatted in Title Case.
  ///
  /// Example: "JOHN doe SMITH" → "John Doe Smith"
  String formatStudentName() {
    if (studentName.trim().isEmpty) return 'Unknown Student';

    return studentName
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Factory constructor: create a StudentRecord from raw imported values.
  ///
  /// Accepts a [gradeResolver] function so grading logic stays decoupled
  /// from the model itself (dependency injection / higher-order function use).
  factory StudentRecord.fromRaw({
    required String name,
    required double caScore,
    required double examScore,
    required int rowIndex,
    required String Function(double finalScore) gradeResolver,
  }) {
    final double finalScore = caScore + examScore;
    final String grade = gradeResolver(finalScore);

    final record = StudentRecord(
      studentName: name.trim().isEmpty ? 'Student ${rowIndex + 1}' : name,
      caScore: caScore,
      examScore: examScore,
      finalScore: finalScore,
      grade: grade,
      rowIndex: rowIndex,
      hasWarning: false,
    );

    // Re-create with warning flag after validation
    final bool valid = record.validateScores();
    return StudentRecord(
      studentName: record.studentName,
      caScore: caScore,
      examScore: examScore,
      finalScore: finalScore,
      grade: grade,
      rowIndex: rowIndex,
      hasWarning: !valid,
    );
  }

  /// Returns a copy of this record with optional field overrides.
  StudentRecord copyWith({
    String? studentName,
    double? caScore,
    double? examScore,
    double? finalScore,
    String? grade,
    bool? hasWarning,
    int? rowIndex,
  }) {
    return StudentRecord(
      studentName: studentName ?? this.studentName,
      caScore: caScore ?? this.caScore,
      examScore: examScore ?? this.examScore,
      finalScore: finalScore ?? this.finalScore,
      grade: grade ?? this.grade,
      hasWarning: hasWarning ?? this.hasWarning,
      rowIndex: rowIndex ?? this.rowIndex,
    );
  }

  /// Serialise to a JSON-compatible map for Hive storage.
  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'caScore': caScore,
      'examScore': examScore,
      'finalScore': finalScore,
      'grade': grade,
      'hasWarning': hasWarning,
      'rowIndex': rowIndex,
    };
  }

  /// Deserialise from a stored map.
  factory StudentRecord.fromMap(Map<dynamic, dynamic> map) {
    return StudentRecord(
      studentName: map['studentName'] as String? ?? '',
      caScore: (map['caScore'] as num?)?.toDouble() ?? 0.0,
      examScore: (map['examScore'] as num?)?.toDouble() ?? 0.0,
      finalScore: (map['finalScore'] as num?)?.toDouble() ?? 0.0,
      grade: map['grade'] as String? ?? 'F',
      hasWarning: map['hasWarning'] as bool? ?? false,
      rowIndex: map['rowIndex'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'StudentRecord(name: $studentName, CA: $caScore, '
        'Exam: $examScore, Final: $finalScore, Grade: $grade, '
        'Warning: $hasWarning)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentRecord &&
        other.studentName == studentName &&
        other.caScore == caScore &&
        other.examScore == examScore &&
        other.rowIndex == rowIndex;
  }

  @override
  int get hashCode =>
      studentName.hashCode ^ caScore.hashCode ^ examScore.hashCode;
}
