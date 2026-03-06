// lib/views/vault_view.dart
// Vault view: lists saved grading sessions and allows preview/export/delete.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/vault_controller.dart';
import '../models/vault_item.dart';
import '../core/app_theme.dart';
import '../widgets/student_data_table.dart';
import '../widgets/stats_summary_bar.dart';
import '../core/processing_utils.dart';
import 'home_view.dart';

class VaultView extends StatefulWidget {
  const VaultView({super.key});

  @override
  State<VaultView> createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView> {
  @override
  void initState() {
    super.initState();
    // Load vault items on first paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultController>().loadItems();
      // Listen for save events from HomeView
      context.read<VaultRefreshNotifier>().addListener(_onRefresh);
    });
  }

  @override
  void dispose() {
    context.read<VaultRefreshNotifier>().removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) context.read<VaultController>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultController>(
      builder: (context, vault, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.archive, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Vault  (${vault.items.length} saved)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              if (vault.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Refresh',
                        style: TextStyle(color: Colors.white)),
                    onPressed: vault.loadItems,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
            ],
          ),
          body: vault.isEmpty
              ? _buildEmptyState(context)
              : _buildItemList(context, vault),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.archive_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text('Vault is empty',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text(
            'Processed grade sheets saved from the Home tab will appear here.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, VaultController vault) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Sessions',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Click a session to preview, export, or delete.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: vault.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _VaultItemCard(item: vault.items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card representing a single [VaultItem] in the list.
class _VaultItemCard extends StatelessWidget {
  final VaultItem item;

  const _VaultItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('MMM d, yyyy  h:mm a').format(item.createdAt);
    final avg = item.averageScore;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_chart,
                    color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatted,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Stats
              _statPill('${item.studentCount}', 'students', AppColors.accentBlue),
              const SizedBox(width: 10),
              _statPill(avg.toStringAsFixed(1), 'avg', AppColors.primaryGreen),
              if (item.warningCount > 0) ...[
                const SizedBox(width: 10),
                _statPill(
                    '${item.warningCount}', 'warnings', AppColors.warning),
              ],

              const SizedBox(width: 16),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VaultDetailScreen(item: item)),
    );
  }
}

// =============================================================================
// VAULT DETAIL SCREEN
// =============================================================================

/// Full-screen preview for a single [VaultItem].
class VaultDetailScreen extends StatefulWidget {
  final VaultItem item;

  const VaultDetailScreen({super.key, required this.item});

  @override
  State<VaultDetailScreen> createState() => _VaultDetailScreenState();
}

class _VaultDetailScreenState extends State<VaultDetailScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _displayedRecords = [];

  @override
  void initState() {
    super.initState();
    _displayedRecords = widget.item.records;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.fileName),
        actions: [
          // Export button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Export CSV'),
              onPressed: () => _export(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.thickOrange,
              ),
            ),
          ),
          // Delete button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              onPressed: () => _confirmDelete(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsSummaryBar(records: widget.item.records),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search student by name…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (q) {
                setState(() {
                  _displayedRecords =
                      filterByName(widget.item.records, q);
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StudentDataTable(
                records: _displayedRecords.cast(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final vault = context.read<VaultController>();
    final path = await vault.exportItem(widget.item);
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content:
            Text('Delete "${widget.item.fileName}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final vault = context.read<VaultController>();
              await vault.deleteItem(widget.item.id);
              if (!mounted) return;
              Navigator.pop(context); // pop detail screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
