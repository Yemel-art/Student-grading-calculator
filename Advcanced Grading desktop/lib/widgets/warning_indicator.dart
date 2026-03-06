// lib/widgets/warning_indicator.dart
// Small icon + tooltip shown on rows with invalid/out-of-range scores.

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Icon indicator shown on rows with invalid scores.
class WarningIndicator extends StatelessWidget {
  final String? tooltip;

  const WarningIndicator({super.key, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'Score out of allowed range',
      child: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warning,
        size: 18,
      ),
    );
  }
}
