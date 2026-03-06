// lib/core/processing_utils.dart
// Demonstrates higher-order functions (HOF) as required by the spec.
// All public functions here accept or return lambdas/callbacks.

import '../models/student_record.dart';
import '../models/grade_boundary.dart';

// =============================================================================
// CUSTOM HIGHER-ORDER FUNCTION
// =============================================================================

/// Applies [action] to every [StudentRecord] in [students].
///
/// This is the custom HOF required by the spec. It accepts a lambda so
/// the caller can supply any per-record side-effect or transformation.
///
/// Example usage:
/// ```dart
/// processStudents(students, (student) {
///   print(student.finalScore);
/// });
/// ```
void processStudents(
  List<StudentRecord> students,
  void Function(StudentRecord student) action,
) {
  for (final student in students) {
    action(student);
  }
}

/// Transforms a list of [StudentRecord] using [transform], returning a new list.
///
/// Generic variant that supports returning a value per record.
List<T> mapStudents<T>(
  List<StudentRecord> students,
  T Function(StudentRecord student) transform,
) {
  // Uses Dart's built-in map() HOF internally.
  return students.map(transform).toList();
}

// =============================================================================
// FUNCTIONAL PIPELINE HELPERS
// =============================================================================

/// Returns only the records that fail [validateScores()].
///
/// Uses filter() (Dart's [where]) to detect invalid rows.
List<StudentRecord> filterInvalidStudents(List<StudentRecord> students) {
  return students.where((student) => !student.validateScores()).toList();
}

/// Returns only the records with valid scores.
List<StudentRecord> filterValidStudents(List<StudentRecord> students) {
  return students.where((student) => student.validateScores()).toList();
}

/// Calculates final scores for all students and returns updated records.
///
/// Demonstrates map() usage: students.map((s) => s.calculateFinal())
List<StudentRecord> recalculateFinalScores(
  List<StudentRecord> students,
  List<GradeBoundary> boundaries,
) {
  return students.map((student) {
    final newFinal = student.caScore + student.examScore;
    final newGrade = resolveGrade(newFinal, boundaries);
    return student.copyWith(finalScore: newFinal, grade: newGrade);
  }).toList();
}

/// Assigns grades to all students and returns updated records.
List<StudentRecord> assignGrades(
  List<StudentRecord> students,
  List<GradeBoundary> boundaries,
) {
  final result = <StudentRecord>[];
  for (final student in students) {
    final grade = resolveGrade(student.finalScore, boundaries);
    result.add(student.copyWith(grade: grade));
  }
  return result;
}

/// Filters students by [searchQuery] (case-insensitive name match).
List<StudentRecord> filterByName(
  List<StudentRecord> students,
  String searchQuery,
) {
  if (searchQuery.trim().isEmpty) return students;
  final query = searchQuery.toLowerCase();
  return students
      .where((s) => s.formatStudentName().toLowerCase().contains(query))
      .toList();
}

/// Groups students by their assigned grade letter.
Map<String, List<StudentRecord>> groupByGrade(List<StudentRecord> students) {
  final grouped = <String, List<StudentRecord>>{};
  for (final student in students) {
    grouped.putIfAbsent(student.grade, () => []).add(student);
  }
  return grouped;
}

/// Sorts students by [finalScore] descending (class rank order).
List<StudentRecord> sortByScore(List<StudentRecord> students) {
  final sorted = List<StudentRecord>.from(students);
  sorted.sort((a, b) => b.finalScore.compareTo(a.finalScore));
  return sorted;
}
