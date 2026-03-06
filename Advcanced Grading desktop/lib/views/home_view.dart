// lib/views/home_view.dart
// Main Home view: file import, grade processing, and results preview.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/settings_controller.dart';
import '../core/app_theme.dart';
import '../widgets/student_data_table.dart';
import '../widgets/import_progress_panel.dart';
import '../widgets/stats_summary_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeController, SettingsController>(
      builder: (context, home, settings, _) {
        return Scaffold(
          appBar: _buildAppBar(context, settings),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 20),

                // Import toolbar
                _buildImportToolbar(context, home),
                const SizedBox(height: 12),

                // Processing indicator
                if (home.isProcessing)
                  ImportProgressPanel(
                    phase: home.phase,
                    progress: home.progress,
                    message: home.progressMessage,
                  ),

                // Error banner
                if (home.errorMessage != null)
                  _buildErrorBanner(context, home.errorMessage!),

                // Completion info bar
                if (home.phase == ProcessingPhase.complete && home.hasData)
                  _buildCompletionBanner(context, home),

                // Parse warnings
                if (home.parseWarnings.isNotEmpty)
                  _buildWarningsList(context, home.parseWarnings),

                // Data section
                if (home.hasData) ...[
                  const SizedBox(height: 8),
                  _buildSearchAndActions(context, home),
                  const SizedBox(height: 12),
                  StatsSummaryBar(records: home.allRecords),
                  Expanded(
                    child: StudentDataTable(records: home.records),
                  ),
                ],

                // Empty state
                if (!home.hasData && !home.isProcessing)
                  Expanded(child: _buildEmptyState(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------

  AppBar _buildAppBar(BuildContext context, SettingsController settings) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Student Grading Calculator',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        // Theme toggle
        Row(
          children: [
            const Icon(Icons.light_mode, size: 18, color: Colors.white70),
            Switch(
              value: settings.isDarkMode,
              onChanged: (_) => settings.toggleDarkMode(),
              activeColor: AppColors.thickOrange,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white38,
            ),
            const Icon(Icons.dark_mode, size: 18, color: Colors.white70),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grade Sheet Import',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Import a CSV or Excel file to auto-detect, calculate, and preview grades.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildImportToolbar(BuildContext context, HomeController home) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        // Primary import button
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Import File (CSV / Excel)'),
          onPressed: home.isProcessing ? null : home.importFile,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        // Google Sheets URL import
        OutlinedButton.icon(
          icon: const Icon(Icons.link),
          label: const Text('Import from URL'),
          onPressed: home.isProcessing
              ? null
              : () => _showUrlDialog(context, home),
        ),

        // Clear button
        if (home.hasData)
          OutlinedButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            onPressed: home.clearData,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletionBanner(BuildContext context, HomeController home) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '✔ ${home.totalStudents} students processed  '
              '· CA column: "${home.detectedCaCol}"  '
              '· Exam column: "${home.detectedExamCol}"',
              style: const TextStyle(color: AppColors.success, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsList(BuildContext context, List<String> warnings) {
    return ExpansionTile(
      leading: const Icon(Icons.warning_amber_rounded,
          color: AppColors.warning, size: 20),
      title: Text(
        '${warnings.length} warning${warnings.length > 1 ? 's' : ''} detected',
        style: const TextStyle(
            color: AppColors.warning, fontWeight: FontWeight.w600),
      ),
      children: warnings
          .map((w) => ListTile(
                dense: true,
                leading: const Icon(Icons.info_outline,
                    size: 16, color: AppColors.warning),
                title: Text(w, style: const TextStyle(fontSize: 12)),
              ))
          .toList(),
    );
  }

  Widget _buildSearchAndActions(BuildContext context, HomeController home) {
    return Row(
      children: [
        // Search bar
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search student by name…',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: home.search,
          ),
        ),
        const SizedBox(width: 16),

        // Save to vault
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save to Vault'),
          onPressed: () => _handleSaveToVault(context, home),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 10),

        // Export
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export CSV'),
          onPressed: () => _handleExport(context, home),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.thickOrange,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload_file,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text('No file imported yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text(
            'Click "Import File" to load a CSV or Excel grade sheet.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Import File'),
            onPressed: context.read<HomeController>().importFile,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _handleSaveToVault(
      BuildContext context, HomeController home) async {
    await home.saveToVault();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✔ Saved to Vault'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Refresh vault controller
    context.read<VaultRefreshNotifier>().notify();
  }

  Future<void> _handleExport(BuildContext context, HomeController home) async {
    final path = await home.exportToChosenPath();
    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✔ Exported to: $path'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUrlDialog(BuildContext context, HomeController home) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a Google Sheets CSV export URL or any direct CSV URL:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://docs.google.com/spreadsheets/…',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: In Google Sheets go to File → Download → CSV',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              home.importFromUrl(_urlController.text.trim());
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

/// Simple notifier to let the Vault view know it should refresh.
class VaultRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
