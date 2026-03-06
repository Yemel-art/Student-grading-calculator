// lib/widgets/student_data_table.dart
// PaginatedDataTable that displays processed StudentRecord objects.

import 'package:flutter/material.dart';
import '../models/student_record.dart';
import '../core/app_theme.dart';
import 'grade_badge.dart';
import 'warning_indicator.dart';

/// DataTableSource adapter for [StudentRecord] lists.
class _StudentDataSource extends DataTableSource {
  final List<StudentRecord> records;
  final BuildContext context;

  _StudentDataSource(this.records, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= records.length) return null;
    final r = records[index];
    final bool isWarning = r.hasWarning;

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((_) {
        return isWarning ? AppColors.warning.withOpacity(0.08) : null;
      }),
      cells: [
        // Rank
        DataCell(Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.grey),
        )),
        // Name
        DataCell(Row(
          children: [
            if (isWarning) ...[
              const WarningIndicator(),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                r.formatStudentName(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isWarning ? AppColors.warning : null,
                ),
              ),
            ),
          ],
        )),
        // CA Score
        DataCell(_scoreCell(r.caScore, 30, isWarning && r.caScore > 30)),
        // Exam Score
        DataCell(_scoreCell(r.examScore, 70, isWarning && r.examScore > 70)),
        // Final Score
        DataCell(Text(
          r.finalScore.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWarning ? AppColors.warning : AppColors.primaryGreen,
          ),
        )),
        // Grade
        DataCell(GradeBadge(grade: r.grade)),
      ],
    );
  }

  Widget _scoreCell(double score, double max, bool exceeded) {
    return Row(
      children: [
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            color: exceeded ? AppColors.error : null,
            fontWeight: exceeded ? FontWeight.bold : null,
          ),
        ),
        if (exceeded) ...[
          const SizedBox(width: 4),
          const Icon(Icons.error_outline, size: 14, color: AppColors.error),
        ],
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => records.length;

  @override
  int get selectedRowCount => 0;
}

/// A paginated table for displaying student grade records.
class StudentDataTable extends StatelessWidget {
  final List<StudentRecord> records;
  final int rowsPerPage;

  const StudentDataTable({
    super.key,
    required this.records,
    this.rowsPerPage = 15,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No students match your search.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return PaginatedDataTable(
      rowsPerPage: rowsPerPage,
      columns: const [
        DataColumn(label: Text('#')),
        DataColumn(label: Text('Student Name')),
        DataColumn(label: Text('CA (max 30)'), numeric: true),
        DataColumn(label: Text('Exam (max 70)'), numeric: true),
        DataColumn(label: Text('Final Score'), numeric: true),
        DataColumn(label: Text('Grade')),
      ],
      source: _StudentDataSource(records, context),
      header: Row(
        children: [
          Text(
            '${records.length} student${records.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          _legendItem(AppColors.warning, 'Warning'),
          const SizedBox(width: 16),
          _legendItem(AppColors.primaryGreen, 'Valid'),
        ],
      ),
      showFirstLastButtons: true,
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
