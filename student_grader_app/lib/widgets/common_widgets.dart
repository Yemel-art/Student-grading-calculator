import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/student_record.dart';

// ── Grade Chip ──────────────────────────────────────────────────────────────
class GradeChip extends StatelessWidget {
  final String grade;
  final double? fontSize;

  const GradeChip({super.key, required this.grade, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(grade);
    return Container(
      width: 40,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: fontSize ?? 14,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }
}

// ── Grade Distribution Badge ─────────────────────────────────────────────────
class DistBadge extends StatelessWidget {
  final String grade;
  final int count;

  const DistBadge({super.key, required this.grade, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    final color = AppTheme.gradeColor(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Outfit',
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.navy;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: c),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Export Button ─────────────────────────────────────────────────────────────
class ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool isLoading;

  const ExportButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.navy;
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppTheme.border),
          color: Colors.white,
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: c),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

// ── Warning Sheet ─────────────────────────────────────────────────────────────
class WarningsBottomSheet extends StatelessWidget {
  final List<dynamic> warnings;

  const WarningsBottomSheet({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.gradeC, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${warnings.length} Row${warnings.length == 1 ? '' : 's'} Skipped',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'These rows had issues and were not included in the results.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: warnings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final w = warnings[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.gradeC.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Row ${w.rowNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gradeC,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            Text(
                              w.issue,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
