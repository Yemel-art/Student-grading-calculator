// lib/widgets/stats_summary_bar.dart
// Displays summary statistics (total, avg, warnings) for the current session.

import 'package:flutter/material.dart';
import '../models/student_record.dart';
import '../core/app_theme.dart';
import '../core/processing_utils.dart';

class StatsSummaryBar extends StatelessWidget {
  final List<StudentRecord> records;

  const StatsSummaryBar({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();

    final total = records.length;
    final valid = filterValidStudents(records).length;
    final warnings = records.where((r) => r.hasWarning).length;
    final avg = records.isEmpty
        ? 0.0
        : records.fold(0.0, (s, r) => s + r.finalScore) / records.length;
    final gradeGroups = groupByGrade(records);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _statChip(context, Icons.people, '$total', 'Students',
                AppColors.accentBlue),
            const SizedBox(width: 16),
            _statChip(context, Icons.calculate, avg.toStringAsFixed(1),
                'Class Avg', AppColors.primaryGreen),
            const SizedBox(width: 16),
            _statChip(context, Icons.check_circle, '$valid', 'Valid',
                AppColors.success),
            if (warnings > 0) ...[
              const SizedBox(width: 16),
              _statChip(context, Icons.warning_amber, '$warnings', 'Warnings',
                  AppColors.warning),
            ],
            const Spacer(),
            // Grade distribution chips
            ...gradeGroups.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _gradePill(e.key, e.value.length),
                )),
          ],
        ),
      ),
    );
  }

  Widget _statChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _gradePill(String grade, int count) {
    final color = GradeColors.forGrade(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$grade: $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
