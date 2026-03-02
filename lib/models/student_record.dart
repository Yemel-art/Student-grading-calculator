import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StudentRecord {
  final String name;
  final double marks;
  final String grade;

  const StudentRecord({
    required this.name,
    required this.marks,
    required this.grade,
  });

  Color get gradeColor => AppTheme.gradeColor(grade);

  static String computeGrade(double marks) {
    if (marks >= 90) return 'A';
    if (marks >= 80) return 'B';
    if (marks >= 70) return 'C';
    if (marks >= 60) return 'D';
    return 'F';
  }

  factory StudentRecord.fromRaw(String name, double marks) {
    return StudentRecord(
      name: name,
      marks: marks,
      grade: computeGrade(marks),
    );
  }

  @override
  String toString() => 'StudentRecord(name: $name, marks: $marks, grade: $grade)';
}

class GradeSummary {
  final List<StudentRecord> students;

  const GradeSummary(this.students);

  double get average {
    if (students.isEmpty) return 0;
    return students.map((s) => s.marks).reduce((a, b) => a + b) / students.length;
  }

  StudentRecord get topScorer => students.reduce(
    (a, b) => a.marks >= b.marks ? a : b,
  );

  StudentRecord get lowestScorer => students.reduce(
    (a, b) => a.marks <= b.marks ? a : b,
  );

  Map<String, int> get distribution {
    final dist = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
    for (final s in students) {
      dist[s.grade] = (dist[s.grade] ?? 0) + 1;
    }
    return dist;
  }

  double get passRate {
    if (students.isEmpty) return 0;
    final passed = students.where((s) => s.grade != 'F').length;
    return (passed / students.length) * 100;
  }
}
