import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/app_theme.dart';
import '../../models/models.dart';
import '../../shared/widgets/styled_dialog.dart';
import 'help_support_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final colors = Theme.of(context).extension<AppColors>()!;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile Header with Edit Icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colors.accent.withOpacity(0.1),
                  child: Icon(LucideIcons.user, size: 50, color: colors.accent),
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
              user?.pseudo ?? 'User',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.phoneNumber ?? '',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Settings List
            _buildSettingItem(
              context,
              icon: LucideIcons.settings,
              title: 'Account Settings',
              subtitle: 'Theme: ${themeMode.name.toUpperCase()}',
              onTap: () => _showThemeDialog(context, ref),
              colors: colors,
            ),
            _buildSettingItem(
              context,
              icon: LucideIcons.bell,
              title: 'Notifications',
              subtitle: 'Enable or disable push notifications',
              trailing: Switch(
                value: true, // Placeholder for notification state
                onChanged: (val) {
                  // Notification toggle logic
                },
                activeColor: colors.accent,
              ),
              onTap: () {},
              colors: colors,
            ),
            _buildSettingItem(
              context,
              icon: LucideIcons.shield,
              title: 'Security',
              subtitle: 'Change your password',
              onTap: () => _showChangePasswordDialog(context, ref),
              colors: colors,
            ),
            _buildSettingItem(
              context,
              icon: LucideIcons.helpCircle,
              title: 'Help & Support',
              subtitle: 'FAQs and contact info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
              colors: colors,
            ),

            const Divider(height: 32),

            _buildSettingItem(
              context,
              icon: LucideIcons.logOut,
              title: 'Log Out',
              textColor: colors.danger,
              onTap: () => ref.read(authProvider.notifier).logout(),
              colors: colors,
            ),
          ],
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
      title: 'Edit Profile',
      description: 'Update your personal information',
      icon: LucideIcons.user,
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
      description: 'Choose your preferred visual style',
      icon: LucideIcons.palette,
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
      description: 'Strengthen your account security',
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

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required AppColors colors,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? colors.textPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            )
          : null,
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18),
      contentPadding: EdgeInsets.zero,
    );
  }
}
