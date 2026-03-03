import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';
import '../../core/api_service.dart';
import '../../providers/dashboard_provider.dart';

class RefillScreen extends ConsumerStatefulWidget {
  const RefillScreen({super.key});

  @override
  ConsumerState<RefillScreen> createState() => _RefillScreenState();
}

class _RefillScreenState extends ConsumerState<RefillScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'ORANGE_MONEY';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'ORANGE_MONEY',
      'name': 'Orange Money',
      'icon': LucideIcons.smartphone,
    },
    {'id': 'MTN_MOMO', 'name': 'MTN MoMo', 'icon': LucideIcons.smartphone},
    {
      'id': 'CREDIT_CARD',
      'name': 'Credit Card',
      'icon': LucideIcons.creditCard,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleRefill() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final meters = ref.read(dashboardProvider).data?.meters ?? [];
    if (meters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active meter found. Please link a meter first.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final meterId = meters.first.id;
      await ref
          .read(apiServiceProvider)
          .createRefill(meterId, amount, _selectedMethod);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refill initiated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(dashboardProvider.notifier).fetchDashboard();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate refill. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('New Refill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.plusCircle,
                size: 64,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Top Up Water',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (FCFA)',
                prefixIcon: const Icon(LucideIcons.banknote),
                hintText: 'Enter amount...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Presets
            Text(
              'Quick Selection (L)',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 25, 50, 100].map((volume) {
                // Assuming 50 FCFA per liter as a default
                final price = volume * 50;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _amountController.text = price.toString();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: _amountController.text == price.toString()
                              ? colors.accent
                              : colors.border,
                        ),
                        backgroundColor:
                            _amountController.text == price.toString()
                            ? colors.accent.withOpacity(0.1)
                            : null,
                      ),
                      child: Text(
                        '${volume}L',
                        style: TextStyle(
                          fontSize: 12,
                          color: _amountController.text == price.toString()
                              ? colors.accent
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Payment Methods
            Text(
              'Payment Method',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ..._methods.map((method) {
              final isSelected = _selectedMethod == method['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = method['id']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.accent.withOpacity(0.1)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.accent : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        method['icon'],
                        color: isSelected
                            ? colors.accent
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        method['name'],
                        style: TextStyle(
                          color: isSelected
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          LucideIcons.checkCircle2,
                          color: colors.accent,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _handleRefill,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Confirm Refill',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
