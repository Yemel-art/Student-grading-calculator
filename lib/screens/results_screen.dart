import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grader_provider.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _exportingExcel = false;
  bool _exportingPdf = false;
  String _sortField = 'name'; // 'name' | 'marks' | 'grade'
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GraderProvider>();
    final summary = provider.summary!;
    final dist = summary.distribution;

    // Sort students
    final students = [...summary.students];
    students.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'marks':
          cmp = a.marks.compareTo(b.marks);
          break;
        case 'grade':
          cmp = a.grade.compareTo(b.grade);
          break;
        default:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return _sortAsc ? cmp : -cmp;
    });

    return Column(
      children: [
        // ── Sticky summary header ────────────────────
        _SummaryHeader(
          fileName: provider.fileName ?? 'Results',
          studentCount: summary.students.length,
          average: summary.average,
          distribution: dist,
          exportingExcel: _exportingExcel,
          exportingPdf: _exportingPdf,
          hasWarnings: provider.hasWarnings,
          onExportExcel: _handleExcelExport,
          onExportPdf: _handlePdfExport,
          onWarningsTap: () => _showWarnings(context, provider),
        ),

        // ── Stats row ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              StatCard(
                label: 'Class Average',
                value: '${summary.average.toStringAsFixed(1)}%',
                icon: Icons.bar_chart_rounded,
                color: AppTheme.navy,
              ),
              const SizedBox(width: 10),
              StatCard(
                label: 'Top Score',
                value: summary.topScorer.marks.toStringAsFixed(1),
                icon: Icons.emoji_events_rounded,
                color: AppTheme.gradeA,
              ),
              const SizedBox(width: 10),
              StatCard(
                label: 'Pass Rate',
                value: '${summary.passRate.toStringAsFixed(0)}%',
                icon: Icons.check_circle_outline_rounded,
                color: AppTheme.gradeB,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Data table ───────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  // Table header
                  Container(
                    color: AppTheme.navy,
                    child: Row(
                      children: [
                        _HeaderCell(
                          label: '#',
                          width: 40,
                          onTap: null,
                        ),
                        _HeaderCell(
                          label: 'Student Name',
                          flex: 3,
                          field: 'name',
                          sortField: _sortField,
                          sortAsc: _sortAsc,
                          onTap: () => _setSort('name'),
                        ),
                        _HeaderCell(
                          label: 'Marks',
                          flex: 2,
                          field: 'marks',
                          sortField: _sortField,
                          sortAsc: _sortAsc,
                          onTap: () => _setSort('marks'),
                          align: TextAlign.right,
                        ),
                        _HeaderCell(
                          label: 'Grade',
                          flex: 1,
                          field: 'grade',
                          sortField: _sortField,
                          sortAsc: _sortAsc,
                          onTap: () => _setSort('grade'),
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Rows
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final s = students[i];
                      final isEven = i % 2 == 0;
                      return Container(
                        color: isEven ? Colors.white : AppTheme.surface,
                        child: Row(
                          children: [
                            // Row number
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            // Name
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 4),
                                child: Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            // Marks
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 4),
                                child: _MarkBar(marks: s.marks),
                              ),
                            ),
                            // Grade
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  child: GradeChip(grade: s.grade),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Footer summary row
                  Container(
                    color: const Color(0xFFEEF4FB),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        const Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            child: Text(
                              'Class Average',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.navy,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            child: Text(
                              summary.average.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.navy,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: GradeChip(
                                  grade: summary.students.isNotEmpty
                                      ? _avgGrade(summary.average)
                                      : '-'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _avgGrade(double avg) {
    if (avg >= 90) return 'A';
    if (avg >= 80) return 'B';
    if (avg >= 70) return 'C';
    if (avg >= 60) return 'D';
    return 'F';
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  Future<void> _handleExcelExport() async {
    if (_exportingExcel) return;
    setState(() => _exportingExcel = true);
    try {
      final provider = context.read<GraderProvider>();
      await ExportService.toExcel(
          provider.summary!, provider.fileName ?? 'grades.xlsx');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingExcel = false);
    }
  }

  Future<void> _handlePdfExport() async {
    if (_exportingPdf) return;
    setState(() => _exportingPdf = true);
    try {
      final provider = context.read<GraderProvider>();
      await ExportService.toPdf(
          provider.summary!, provider.fileName ?? 'grades.xlsx');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  void _showWarnings(BuildContext context, GraderProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => WarningsBottomSheet(warnings: provider.warnings),
    );
  }
}

// ── Summary Header ────────────────────────────────────────────────────────────
class _SummaryHeader extends StatelessWidget {
  final String fileName;
  final int studentCount;
  final double average;
  final Map<String, int> distribution;
  final bool exportingExcel;
  final bool exportingPdf;
  final bool hasWarnings;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final VoidCallback onWarningsTap;

  const _SummaryHeader({
    required this.fileName,
    required this.studentCount,
    required this.average,
    required this.distribution,
    required this.exportingExcel,
    required this.exportingPdf,
    required this.hasWarnings,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.onWarningsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navy,
                        fontFamily: 'Outfit',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$studentCount students  ·  Avg ${average.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (hasWarnings)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: onWarningsTap,
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color:
                                AppTheme.gradeC.withOpacity(0.1),
                            border: Border.all(
                              color: AppTheme.gradeC.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppTheme.gradeC,
                          ),
                        ),
                      ),
                    ),
                  ExportButton(
                    icon: Icons.table_chart_rounded,
                    label: 'Excel',
                    onTap: onExportExcel,
                    isLoading: exportingExcel,
                  ),
                  const SizedBox(width: 6),
                  ExportButton(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF',
                    onTap: onExportPdf,
                    isLoading: exportingPdf,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grade distribution
          Row(
            children: distribution.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: DistBadge(grade: e.key, count: e.value),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Mark Bar ──────────────────────────────────────────────────────────────────
class _MarkBar extends StatelessWidget {
  final double marks;

  const _MarkBar({required this.marks});

  @override
  Widget build(BuildContext context) {
    final pct = (marks / 100).clamp(0.0, 1.0);
    final color = AppTheme.gradeColor(_getGrade(marks));
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marks.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGrade(double m) {
    if (m >= 90) return 'A';
    if (m >= 80) return 'B';
    if (m >= 70) return 'C';
    if (m >= 60) return 'D';
    return 'F';
  }
}

// ── Sortable Header Cell ──────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final double? width;
  final int? flex;
  final String? field;
  final String? sortField;
  final bool sortAsc;
  final VoidCallback? onTap;
  final TextAlign align;

  const _HeaderCell({
    required this.label,
    this.width,
    this.flex,
    this.field,
    this.sortField,
    this.sortAsc = true,
    this.onTap,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = field != null && field == sortField;
    Widget cell = GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        child: Row(
          mainAxisAlignment: align == TextAlign.center
              ? MainAxisAlignment.center
              : align == TextAlign.right
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? AppTheme.accent
                    : Colors.white,
              ),
            ),
            if (field != null && onTap != null) ...[
              const SizedBox(width: 3),
              Icon(
                isActive
                    ? (sortAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 12,
                color: isActive
                    ? AppTheme.accent
                    : Colors.white54,
              ),
            ],
          ],
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: cell);
    return Expanded(flex: flex ?? 1, child: cell);
  }
}
