// lib/models/grade_boundary.dart
// Represents a single configurable grade range (e.g. A: 80-100).

import '../core/constants.dart';

/// A single grade boundary configuration entry.
class GradeBoundary {
  /// Letter grade label (A, B, C, D, F)
  final String grade;

  /// Minimum score required (inclusive)
  final double minScore;

  /// Maximum score allowed (inclusive)
  final double maxScore;

  const GradeBoundary({
    required this.grade,
    required this.minScore,
    required this.maxScore,
  });

  /// Checks whether [score] falls within this boundary.
  bool contains(double score) => score >= minScore && score <= maxScore;

  /// Serialise to map for persistence.
  Map<String, dynamic> toMap() => {
        'grade': grade,
        'minScore': minScore,
        'maxScore': maxScore,
      };

  /// Deserialise from stored map.
  factory GradeBoundary.fromMap(Map<dynamic, dynamic> map) {
    return GradeBoundary(
      grade: map['grade'] as String,
      minScore: (map['minScore'] as num).toDouble(),
      maxScore: (map['maxScore'] as num).toDouble(),
    );
  }

  GradeBoundary copyWith({String? grade, double? minScore, double? maxScore}) {
    return GradeBoundary(
      grade: grade ?? this.grade,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
    );
  }

  @override
  String toString() => '$grade: $minScore–$maxScore';
}

/// Builds the default list of grade boundaries from [DefaultGradeBoundaries].
List<GradeBoundary> buildDefaultBoundaries() {
  return DefaultGradeBoundaries.ranges.entries
      .map((e) => GradeBoundary(
            grade: e.key,
            minScore: e.value[0],
            maxScore: e.value[1],
          ))
      .toList()
    ..sort((a, b) => b.minScore.compareTo(a.minScore));
}

/// Resolves a [score] to a letter grade using [boundaries].
///
/// Returns 'F' if no boundary matches (fail-safe).
String resolveGrade(double score, List<GradeBoundary> boundaries) {
  for (final boundary in boundaries) {
    if (boundary.contains(score)) return boundary.grade;
  }
  return 'F';
}
