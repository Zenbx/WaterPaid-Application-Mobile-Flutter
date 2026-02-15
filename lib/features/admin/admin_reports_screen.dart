import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_reports_provider.dart';
import '../../core/app_theme.dart';
import '../../models/models.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReportsProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showCreateReportDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminReportsProvider.notifier).refresh(),
        child: state.isLoading && state.reports.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.reports.isEmpty
            ? _buildEmptyState(colors)
            : _buildReportList(state.reports, colors),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileText,
            size: 64,
            color: colors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No reports generated yet',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(List<ReportModel> reports, AppColors colors) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.fileSpreadsheet,
                color: colors.accent,
                size: 24,
              ),
            ),
            title: Text(
              'Report: ${DateFormat('MMM d').format(report.startedAt)} - ${DateFormat('MMM d, y').format(report.endedAt)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Format: ${report.format} • Created: ${DateFormat('MMM d, HH:mm').format(report.createdAt)}',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(LucideIcons.download),
              onPressed: () {
                // TODO: Download report
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading report...')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCreateReportDialog(BuildContext context, WidgetRef ref) {
    DateTime start = DateTime.now().subtract(const Duration(days: 30));
    DateTime end = DateTime.now();
    String format = 'CSV';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(start)),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: start,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => start = picked);
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(end)),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: end,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => end = picked);
                },
              ),
              DropdownButtonFormField<String>(
                value: format,
                decoration: const InputDecoration(labelText: 'Format'),
                items: ['CSV', 'PDF']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => format = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(adminReportsProvider.notifier)
                    .createReport(start, end, format);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}
