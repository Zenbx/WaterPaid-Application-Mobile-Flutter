import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenanceMode = false;
  bool _enableAlerts = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('General Configuration', colors),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: LucideIcons.power,
            label: 'System Maintenance Mode',
            description: 'Restrict user access during updates',
            trailing: Switch(
              value: _maintenanceMode,
              onChanged: (val) => setState(() => _maintenanceMode = val),
              activeColor: colors.accent,
            ),
            colors: colors,
          ),
          _buildSettingTile(
            icon: LucideIcons.bell,
            label: 'Global Admin Alerts',
            description: 'Receive notifications for system failures',
            trailing: Switch(
              value: _enableAlerts,
              onChanged: (val) => setState(() => _enableAlerts = val),
              activeColor: colors.accent,
            ),
            colors: colors,
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('Pricing & Thresholds', colors),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: LucideIcons.banknote,
            label: 'Water Price (FCFA/L)',
            description: 'Default price used for manual recharges',
            trailing: SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '250',
                ),
                onChanged: (val) {
                  // Mock update
                },
              ),
            ),
            colors: colors,
          ),
          const SizedBox(height: 48),

          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved successfully (Local Mock)'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Configuration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors colors) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: colors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required String description,
    required Widget trailing,
    required AppColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.accent, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
