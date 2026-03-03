import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/styled_dialog.dart';
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
    _showStyledDialog(
      context: context,
      title: 'Delete Meter',
      description:
          'Are you sure you want to delete this meter? This action cannot be undone and all associated data will be lost.',
      icon: LucideIcons.trash2,
      iconColor: Colors.red,
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
      onConfirm: () async {
        await ref.read(adminMetersProvider.notifier).deleteMeter(meter.meterId);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  void _confirmGenerateToken(BuildContext context, WidgetRef ref) {
    _showStyledDialog(
      context: context,
      title: 'Generate Token',
      description:
          'This will invalidate the current token. The user will need the new token to link this meter.',
      icon: LucideIcons.refreshCw,
      iconColor: Colors.orange,
      confirmLabel: 'Generate',
      confirmColor: Colors.orange,
      onConfirm: () async {
        await ref
            .read(adminMetersProvider.notifier)
            .generateToken(meter.meterId);
      },
    );
  }

  void _confirmUnlinkUser(BuildContext context, WidgetRef ref) {
    _showStyledDialog(
      context: context,
      title: 'Unlink User',
      description:
          'Are you sure you want to remove the user from this meter? They will lose access immediately.',
      icon: LucideIcons.userX,
      iconColor: Colors.red,
      confirmLabel: 'Unlink',
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          await ref
              .read(adminMetersProvider.notifier)
              .unlinkUser(meter.meterId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User unlinked successfully')),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to unlink: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  void _showLinkDeviceDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: meter.deviceId);
    final colors = Theme.of(context).extension<AppColors>()!;

    _showStyledDialog(
      context: context,
      title: 'Link Device ID',
      icon: LucideIcons.link,
      iconColor: colors.accent,
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'DevEui / Device ID',
          hintText: 'e.g. 0080E11505011234',
          prefixIcon: const Icon(LucideIcons.cpu),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      confirmLabel: 'Link Device',
      onConfirm: () async {
        if (controller.text.trim().isEmpty) return;
        await ref
            .read(adminMetersProvider.notifier)
            .linkDevice(meter.meterId, controller.text.trim());
      },
    );
  }

  void _showRechargeDialog(BuildContext context, WidgetRef ref) {
    final volumeController = TextEditingController();
    final priceController = TextEditingController();

    _showStyledDialog(
      context: context,
      title: 'Manual Recharge',
      icon: LucideIcons.droplets,
      iconColor: Colors.green,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: volumeController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Volume (L)',
              prefixIcon: const Icon(LucideIcons.droplet),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price (FCFA)',
              prefixIcon: const Icon(LucideIcons.banknote),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      confirmLabel: 'Confirm Recharge',
      confirmColor: Colors.green,
      onConfirm: () async {
        final vol = double.tryParse(volumeController.text) ?? 0;
        final pri = double.tryParse(priceController.text) ?? 0;
        if (vol <= 0) return;
        await ref
            .read(adminMetersProvider.notifier)
            .refillMeter(meter.meterId, vol, pri);
      },
    );
  }

  void _showStyledDialog({
    required BuildContext context,
    required String title,
    String? description,
    Widget? content,
    required IconData icon,
    required Color iconColor,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    Color? confirmColor,
  }) {
    showStyledDialog(
      context: context,
      title: title,
      description: description,
      content: content,
      icon: icon,
      iconColor: iconColor,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
      confirmColor: confirmColor,
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
