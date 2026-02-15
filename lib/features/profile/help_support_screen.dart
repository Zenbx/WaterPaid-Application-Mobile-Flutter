import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Common Questions', [
              _buildFaqItem(
                'How do I link a meter?',
                'Go to the Home screen, tap the plus (+) button, and enter the token provided by your admin.',
                colors,
              ),
              _buildFaqItem(
                'How do I refill my meter?',
                'Tap the water droplet icon on the Home screen, select your meter, enter the amount, and choose a payment method.',
                colors,
              ),
              _buildFaqItem(
                'What if my valve is closed?',
                'Ensure you have sufficient credit. If you do, check if the device is online. For technical issues, contact support.',
                colors,
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'Contact Us', [
              ListTile(
                leading: Icon(LucideIcons.mail, color: colors.accent),
                title: const Text('Email Support'),
                subtitle: const Text('support@waterpaid.com'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(LucideIcons.phone, color: colors.accent),
                title: const Text('Call Us'),
                subtitle: const Text('+237 6XX XXX XXX'),
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer, AppColors colors) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
