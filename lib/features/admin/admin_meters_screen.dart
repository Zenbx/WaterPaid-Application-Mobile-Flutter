import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_meters_provider.dart';
import '../../core/app_theme.dart';
import '../../models/models.dart';
import 'admin_meter_detail_screen.dart';

class AdminMetersScreen extends ConsumerStatefulWidget {
  const AdminMetersScreen({super.key});

  @override
  ConsumerState<AdminMetersScreen> createState() => _AdminMetersScreenState();
}

class _AdminMetersScreenState extends ConsumerState<AdminMetersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMetersProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    final filteredMeters = state.meters.where((m) {
      final query = _searchQuery.toLowerCase();
      return m.serialId.toLowerCase().contains(query) ||
          (m.deviceId?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meters Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw),
            onPressed: () => ref.read(adminMetersProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by Serial or Device ID',
                prefixIcon: const Icon(LucideIcons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surface,
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(adminMetersProvider.notifier).refresh(),
              child: state.isLoading && state.meters.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.meters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.error!,
                            style: TextStyle(color: colors.danger),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(adminMetersProvider.notifier)
                                .refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : filteredMeters.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildMeterList(filteredMeters, colors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.gauge,
            size: 64,
            color: colors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No meters yet'
                : 'No meters match your search',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterList(List<AdminMeterModel> meters, AppColors colors) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: meters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final meter = meters[index];
        return _MeterCard(meter: meter, colors: colors);
      },
    );
  }
}

class _MeterCard extends StatelessWidget {
  final AdminMeterModel meter;
  final AppColors colors;

  const _MeterCard({required this.meter, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMeterDetailScreen(meter: meter),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.gauge,
                    color: colors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Serial ID: ${meter.serialId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        meter.deviceId != null
                            ? 'Device: ${meter.deviceId}'
                            : 'No device linked',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  status: meter.meterState,
                  isActive: meter.isActive,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(
                  icon: LucideIcons.user,
                  label: 'Owner',
                  value: meter.isLinked ? 'Assigned' : 'Unassigned',
                  color: meter.isLinked ? colors.accent : Colors.grey,
                ),
                _InfoItem(
                  icon: LucideIcons.calendar,
                  label: 'Registered',
                  value: DateFormat('MMM d, y').format(meter.registeredAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isActive;

  const _StatusBadge({required this.status, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? colors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 10),
            ),
            Text(
              value,
              style: TextStyle(
                color: color ?? colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
