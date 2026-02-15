import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../providers/admin_meters_provider.dart';
import '../../core/app_theme.dart';
import '../../models/models.dart';
import 'admin_history_screen.dart';

class AdminMeterDetailScreen extends ConsumerWidget {
  final AdminMeterModel meter;

  const AdminMeterDetailScreen({super.key, required this.meter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meter: ${meter.serialId}'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            _buildHeader(colors),
            const SizedBox(height: 24),

            // Status & Device Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Status',
                    meter.meterState,
                    colors,
                    meter.isActive ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Device ID',
                    meter.deviceId ?? 'Not Linked',
                    colors,
                    colors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Token Section
            _buildTokenSection(colors, context),
            const SizedBox(height: 24),

            // Actions Section
            Text(
              'Actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: LucideIcons.history,
              label: 'View Transaction History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminHistoryScreen(
                      targetId: meter.meterId,
                      title: 'Meter: ${meter.serialId}',
                    ),
                  ),
                );
              },
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: LucideIcons.link,
              label: 'Link Physical Device (DevEui)',
              onTap: () => _showLinkDeviceDialog(context, ref),
              color: colors.accent,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: LucideIcons.droplets,
              label: 'Manual Volume Recharge',
              onTap: () => _showRechargeDialog(context, ref),
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: LucideIcons.refreshCw,
              label: 'Generate New Token',
              onTap: () => _confirmGenerateToken(context, ref),
              color: Colors.orange,
            ),
            if (meter.attributed) ...[
              const SizedBox(height: 12),
              _ActionButton(
                icon: LucideIcons.userX,
                label: 'Unlink User from Meter',
                onTap: () => _confirmUnlinkUser(context, ref),
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.gauge, size: 48, color: colors.accent),
          const SizedBox(height: 16),
          Text(
            'Serial Number',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          Text(
            meter.serialId,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Registered on ${DateFormat('MMMM d, yyyy').format(meter.registeredAt)}',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    AppColors colors,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSection(AppColors colors, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Linking Token',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Give this token to the user to link this meter to their account.',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    meter.token ?? 'No token generated',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.copy),
                onPressed: meter.token == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: meter.token!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Token copied to clipboard'),
                          ),
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meter'),
        content: const Text(
          'Are you sure you want to delete this meter? This action cannot be undone.',
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
                  .read(adminMetersProvider.notifier)
                  .deleteMeter(meter.meterId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmGenerateToken(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Token'),
        content: const Text(
          'This will invalidate the previous token. Proceed?',
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
                  .read(adminMetersProvider.notifier)
                  .generateToken(meter.meterId);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _confirmUnlinkUser(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink User'),
        content: const Text(
          'Are you sure you want to remove the user from this meter? '
          'The user will no longer be able to use this meter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(adminMetersProvider.notifier)
                    .unlinkUser(meter.meterId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User unlinked from meter successfully'),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to unlink user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Unlink', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLinkDeviceDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: meter.deviceId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Device ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter DevEui / Device ID',
          ),
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
                  .read(adminMetersProvider.notifier)
                  .linkDevice(meter.meterId, controller.text.trim());
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }

  void _showRechargeDialog(BuildContext context, WidgetRef ref) {
    final volumeController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Recharge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: volumeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Volume (L)',
                hintText: 'e.g. 500',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (FCFA)',
                hintText: 'e.g. 250',
              ),
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
              final vol = double.tryParse(volumeController.text) ?? 0;
              final pri = double.tryParse(priceController.text) ?? 0;
              Navigator.pop(context);
              await ref
                  .read(adminMetersProvider.notifier)
                  .refillMeter(meter.meterId, vol, pri);
            },
            child: const Text('Recharge'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
