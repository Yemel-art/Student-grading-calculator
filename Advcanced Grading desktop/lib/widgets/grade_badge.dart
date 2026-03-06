// lib/widgets/grade_badge.dart
// Colored badge that displays a letter grade.

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// A compact colored chip displaying a letter grade.
class GradeBadge extends StatelessWidget {
  final String grade;
  final double fontSize;

  const GradeBadge({super.key, required this.grade, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final color = GradeColors.forGrade(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
