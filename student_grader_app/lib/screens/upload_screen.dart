import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grader_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GraderProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Upload Grade Sheet',
            subtitle:
                'Select an Excel (.xlsx) file to automatically\ncalculate student grades.',
          ),

          // ── Drop zone ──────────────────────────────
          _DropZone(onTap: provider.pickAndProcess),
          const SizedBox(height: 16),

          // ── Primary CTA ────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.pickAndProcess,
              icon: const Icon(Icons.folder_open_rounded, size: 19),
              label: const Text('Choose Excel File'),
            ),
          ),
          const SizedBox(height: 32),

          // ── Format guide ───────────────────────────
          const _FormatGuideCard(),
        ],
      ),
    );
  }
}

class _DropZone extends StatefulWidget {
  final VoidCallback onTap;

  const _DropZone({required this.onTap});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: _hovering
                ? AppTheme.navy.withOpacity(0.03)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovering
                  ? AppTheme.navy
                  : AppTheme.navy.withOpacity(0.25),
              width: 1.8,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navy.withOpacity(_hovering ? 0.1 : 0.05),
                blurRadius: _hovering ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Opacity(
                  opacity: _hovering ? 1 : _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppTheme.navy.withOpacity(0.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    size: 32,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tap to Browse Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Supports .xlsx files only',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatGuideCard extends StatelessWidget {
  const _FormatGuideCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 17, color: Colors.blueGrey.shade400),
                const SizedBox(width: 7),
                const Text(
                  'Expected File Format',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Column requirements
            _buildColRow('Student Name', 'Column header containing "Name" or "Student"'),
            const SizedBox(height: 8),
            _buildColRow('Total Marks', 'Column header containing "Marks", "Score", or "Total"'),

            const Divider(height: 22),

            // Grading scale
            const Text(
              'Grading Scale',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _GradeBadge(grade: 'A', range: '90 – 100', color: AppTheme.gradeA),
                _GradeBadge(grade: 'B', range: '80 – 89', color: AppTheme.gradeB),
                _GradeBadge(grade: 'C', range: '70 – 79', color: AppTheme.gradeC),
                _GradeBadge(grade: 'D', range: '60 – 69', color: AppTheme.gradeD),
                _GradeBadge(grade: 'F', range: '< 60', color: AppTheme.gradeF),
              ],
            ),

            const Divider(height: 22),

            // Sample preview
            const Text(
              'Sample Spreadsheet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),
            _SampleTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildColRow(String colName, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            colName,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.navy,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String grade;
  final String range;
  final Color color;

  const _GradeBadge({
    required this.grade,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$grade: $range',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }
}

class _SampleTable extends StatelessWidget {
  final _headers = const ['Student Name', 'Total Marks'];
  final _rows = const [
    ['Alice Johnson', '92'],
    ['Bob Martinez', '75'],
    ['Clara Chen', '58'],
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Table(
        border: TableBorder.all(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(10),
        ),
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(color: AppTheme.navy),
            children: _headers.map((h) => _cell(h, isHeader: true)).toList(),
          ),
          // Data rows
          ..._rows.map((row) => TableRow(
                children: row.map((cell) => _cell(cell)).toList(),
              )),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
          color: isHeader ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }
}
