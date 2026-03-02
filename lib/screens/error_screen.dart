import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grader_provider.dart';
import '../theme/app_theme.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GraderProvider>();
    final message = context.select<GraderProvider, String>(
        (p) => p.errorMessage);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.gradeF.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppTheme.gradeF,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Could Not Process File',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Error message box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gradeF.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.gradeF.withOpacity(0.2)),
            ),
            child: SelectableText(
              message,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.pickAndProcess,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Try Another File'),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: provider.reset,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textMuted,
              textStyle: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
