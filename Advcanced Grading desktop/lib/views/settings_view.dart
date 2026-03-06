// lib/views/settings_view.dart
// Settings view: configure grade boundaries and application preferences.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/home_controller.dart';
import '../models/grade_boundary.dart';
import '../core/app_theme.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late List<GradeBoundary> _editableBoundaries;
  bool _hasChanges = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<SettingsController>();
    _editableBoundaries = settings.editableBoundaries;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.settings, color: Colors.white),
                SizedBox(width: 10),
                Text('Settings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Application Settings',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Customise grade boundaries and appearance.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 28),

                // ----- Appearance -----
                _sectionHeader(context, Icons.palette, 'Appearance'),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                        'Toggle between light and dark application theme'),
                    trailing: Switch(
                      value: settings.isDarkMode,
                      onChanged: (_) => settings.toggleDarkMode(),
                      activeColor: AppColors.thickOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ----- Grade Boundaries -----
                Row(
                  children: [
                    Expanded(
                      child: _sectionHeader(
                          context, Icons.grading, 'Grade Boundaries'),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset to Defaults'),
                      onPressed: () => _resetDefaults(context, settings),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure the score range for each letter grade.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // Grade boundary editors
                ..._editableBoundaries.asMap().entries.map((entry) {
                  return _GradeBoundaryEditor(
                    key: ValueKey(entry.key),
                    boundary: entry.value,
                    onChanged: (updated) {
                      setState(() {
                        _editableBoundaries[entry.key] = updated;
                        _hasChanges = true;
                      });
                    },
                  );
                }),

                const SizedBox(height: 20),

                // Save button
                if (_hasChanges)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Grade Boundaries'),
                    onPressed: () => _saveBoundaries(context, settings),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),

                const SizedBox(height: 40),

                // ----- Score Constraints Info -----
                _sectionHeader(context, Icons.info_outline, 'Score Constraints'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow('Max CA Score', '30 points'),
                        const Divider(),
                        _infoRow('Max Exam Score', '70 points'),
                        const Divider(),
                        _infoRow('Max Final Score', '100 points'),
                        const Divider(),
                        _infoRow('Final Score Formula', 'CA + Exam'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 22),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _saveBoundaries(
      BuildContext context, SettingsController settings) async {
    await settings.saveBoundaries(_editableBoundaries);
    // Propagate to HomeController so displayed grades are recalculated
    if (!mounted) return;
    context.read<HomeController>().updateBoundaries(_editableBoundaries);
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✔ Grade boundaries saved'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resetDefaults(
      BuildContext context, SettingsController settings) async {
    await settings.resetToDefaults();
    setState(() {
      _editableBoundaries = settings.editableBoundaries;
      _hasChanges = false;
    });
  }
}

// =============================================================================
// GRADE BOUNDARY EDITOR TILE
// =============================================================================

/// Interactive editor for a single [GradeBoundary] entry.
class _GradeBoundaryEditor extends StatefulWidget {
  final GradeBoundary boundary;
  final ValueChanged<GradeBoundary> onChanged;

  const _GradeBoundaryEditor({
    super.key,
    required this.boundary,
    required this.onChanged,
  });

  @override
  State<_GradeBoundaryEditor> createState() => _GradeBoundaryEditorState();
}

class _GradeBoundaryEditorState extends State<_GradeBoundaryEditor> {
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(
        text: widget.boundary.minScore.toStringAsFixed(0));
    _maxCtrl = TextEditingController(
        text: widget.boundary.maxScore.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = GradeColors.forGrade(widget.boundary.grade);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Grade letter badge
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                widget.boundary.grade,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 18),
              ),
            ),
            const SizedBox(width: 20),

            // Min score field
            const Text('Min:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(isDense: true),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 20),

            // Max score field
            const Text('Max:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(isDense: true),
                onChanged: (_) => _emit(),
              ),
            ),

            const Spacer(),

            // Preview range label
            Text(
              '${_minCtrl.text} – ${_maxCtrl.text}',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _emit() {
    final min = double.tryParse(_minCtrl.text) ?? widget.boundary.minScore;
    final max = double.tryParse(_maxCtrl.text) ?? widget.boundary.maxScore;
    widget.onChanged(widget.boundary.copyWith(minScore: min, maxScore: max));
  }
}
