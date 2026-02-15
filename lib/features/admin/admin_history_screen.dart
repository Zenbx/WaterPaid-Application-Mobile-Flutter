import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_history_provider.dart';
import '../../core/app_theme.dart';
import '../../models/models.dart';

class AdminHistoryScreen extends ConsumerStatefulWidget {
  final String targetId; // user_id or meter_id
  final String title;

  const AdminHistoryScreen({
    super.key,
    required this.targetId,
    this.title = 'Audit History',
  });

  @override
  ConsumerState<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends ConsumerState<AdminHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(adminHistoryProvider.notifier).fetchHistory(widget.targetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminHistoryProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(adminHistoryProvider.notifier)
            .fetchHistory(widget.targetId),
        child: state.isLoading && state.transactions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.transactions.isEmpty
            ? _buildEmptyState(colors)
            : _buildTransactionList(state.transactions, colors),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.history,
            size: 64,
            color: colors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found for this target',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    AppColors colors,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final bool isSuccess = tx.refillState == 'SUCCEEDED';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSuccess ? Colors.green : Colors.orange).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess ? LucideIcons.checkCircle2 : LucideIcons.clock,
                  color: isSuccess ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${NumberFormat('#,###').format(tx.price)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${tx.volume} L • ${tx.refillMethod}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM d, y').format(tx.createdAt),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(tx.createdAt),
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
