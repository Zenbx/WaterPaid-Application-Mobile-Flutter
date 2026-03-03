import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/models.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/styled_dialog.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).extension<AppColors>()!;
    final themeMode = ref.watch(themeProvider);
    final user = authState.user;

    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header with Edit Icon
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colors.accent.withOpacity(0.1),
                      child: Text(
                        user.pseudo[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showEditProfileDialog(context, ref, user),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          child: const Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.pseudo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrator',
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Admin Menu
          _buildSectionTitle(context, 'MANAGEMENT', colors),
          _ProfileMenuItem(
            icon: LucideIcons.fileText,
            label: 'Reports & Logs',
            subtitle: 'View system activity and reports',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminReportsScreen(),
                ),
              );
            },
            colors: colors,
          ),
          _ProfileMenuItem(
            icon: LucideIcons.sliders,
            label: 'System Settings',
            subtitle: 'Configure global application parameters',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSettingsScreen(),
                ),
              );
            },
            colors: colors,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'PREFERENCES', colors),
          _ProfileMenuItem(
            icon: LucideIcons.settings,
            label: 'Account Settings',
            subtitle: 'Theme: ${themeMode.name.toUpperCase()}',
            onTap: () => _showThemeDialog(context, ref),
            colors: colors,
          ),
          _ProfileMenuItem(
            icon: LucideIcons.bell,
            label: 'Notifications',
            subtitle: 'Admin alerts and notifications',
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeColor: colors.accent,
            ),
            onTap: () {},
            colors: colors,
          ),
          _ProfileMenuItem(
            icon: LucideIcons.shield,
            label: 'Security',
            subtitle: 'Update your password',
            onTap: () => _showChangePasswordDialog(context, ref),
            colors: colors,
          ),
          const SizedBox(height: 32),

          _ProfileMenuItem(
            icon: LucideIcons.logOut,
            label: 'Logout',
            onTap: () => ref.read(authProvider.notifier).logout(),
            textColor: colors.danger,
            iconColor: colors.danger,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    AppColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
  ) {
    if (user == null) return;
    final pseudoController = TextEditingController(text: user.pseudo);
    final phoneController = TextEditingController(text: user.phoneNumber);

    showStyledDialog(
      context: context,
      title: 'Edit Admin Profile',
      description: 'Update your administrator credentials',
      icon: LucideIcons.userCheck,
      iconColor: Theme.of(context).extension<AppColors>()!.accent,
      confirmLabel: 'Save',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: pseudoController,
            decoration: const InputDecoration(labelText: 'Pseudo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      onConfirm: () async {
        await ref
            .read(authProvider.notifier)
            .updateProfile(
              pseudo: pseudoController.text.trim(),
              phone: phoneController.text.trim(),
            );
      },
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeProvider);
    showStyledDialog(
      context: context,
      title: 'App Theme',
      description: 'Choose between light or dark mode',
      icon: LucideIcons.eye,
      iconColor: Theme.of(context).extension<AppColors>()!.accent,
      confirmLabel: 'Done',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: currentTheme,
            onChanged: (val) {
              if (val != null) {
                ref.read(themeProvider.notifier).setTheme(val);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (val) {
              if (val != null) {
                ref.read(themeProvider.notifier).setTheme(val);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: currentTheme,
            onChanged: (val) {
              if (val != null) {
                ref.read(themeProvider.notifier).setTheme(val);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      onConfirm: () async {},
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showStyledDialog(
      context: context,
      title: 'Change Password',
      description: 'Update your administrator password',
      icon: LucideIcons.shieldAlert,
      iconColor: Theme.of(context).extension<AppColors>()!.warning,
      confirmLabel: 'Update',
      confirmColor: Theme.of(context).extension<AppColors>()!.warning,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Old Password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
        ],
      ),
      onConfirm: () async {
        await ref
            .read(authProvider.notifier)
            .changePassword(oldController.text, newController.text);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        }
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final AppColors colors;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.textColor,
    this.iconColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? colors.textPrimary, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: textColor ?? colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: colors.textSecondary,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
