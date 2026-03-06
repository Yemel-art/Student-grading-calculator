// lib/widgets/import_progress_panel.dart
// Shows a loading card with a progress bar during file analysis.

import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../controllers/home_controller.dart';

/// Displays the current processing phase and a linear progress bar.
class ImportProgressPanel extends StatelessWidget {
  final ProcessingPhase phase;
  final double progress;
  final String message;

  const ImportProgressPanel({
    super.key,
    required this.phase,
    required this.progress,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toInt()}% complete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
