import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../core/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw),
            onPressed: () =>
                ref.read(adminDashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminDashboardProvider.notifier).refresh(),
        child: state.isLoading && state.recentMeters.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.recentMeters.isEmpty
            ? Center(child: Text(state.error!))
            : _buildContent(context, state, colors),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AdminDashboardState state,
    AppColors colors,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: LucideIcons.banknote,
                label: 'Total Revenue',
                value:
                    '${NumberFormat('#,###').format(state.totalRevenue)} FCFA',
                color: colors.success,
              ),
              _StatCard(
                icon: LucideIcons.droplet,
                label: 'Water (L)',
                value:
                    '${NumberFormat('#,###').format(state.totalWaterDistributed)} L',
                color: colors.accent,
              ),
              _StatCard(
                icon: LucideIcons.gauge,
                label: 'Active Meters',
                value: '${state.activeMetersCount}',
                color: Colors.orange,
              ),
              _StatCard(
                icon: LucideIcons.users,
                label: 'Total Users',
                value: '${state.totalUsersCount}',
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Recent Meters Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (state.recentMeters.isEmpty)
            _buildEmptyState(colors, 'No meters found')
          else
            ...state.recentMeters
                .take(5)
                .map((m) => _MeterSummaryItem(meter: m, colors: colors)),

          const SizedBox(height: 24),
          Text(
            'Recent Users',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (state.recentUsers.isEmpty)
            _buildEmptyState(colors, 'No users found')
          else
            ...state.recentUsers
                .take(5)
                .map((u) => _UserSummaryItem(user: u, colors: colors)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: colors.textSecondary)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MeterSummaryItem extends StatelessWidget {
  final dynamic meter;
  final AppColors colors;

  const _MeterSummaryItem({required this.meter, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (meter.isActive ? Colors.green : Colors.grey).withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.gauge,
              color: meter.isActive ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serial: ${meter.serialId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  meter.isLinked ? 'Linked to User' : 'Unlinked',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (meter.isActive ? Colors.green : Colors.grey).withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              meter.meterState,
              style: TextStyle(
                color: meter.isActive ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSummaryItem extends StatelessWidget {
  final dynamic user;
  final AppColors colors;

  const _UserSummaryItem({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.accent.withOpacity(0.1),
            child: Text(
              user.pseudo[0].toUpperCase(),
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.pseudo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.phone,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 16, color: colors.textSecondary),
        ],
      ),
    );
  }
}
