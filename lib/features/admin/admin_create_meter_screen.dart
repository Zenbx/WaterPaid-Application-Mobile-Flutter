import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/admin_meters_provider.dart';

class AdminCreateMeterScreen extends ConsumerStatefulWidget {
  const AdminCreateMeterScreen({super.key});

  @override
  ConsumerState<AdminCreateMeterScreen> createState() =>
      _AdminCreateMeterScreenState();
}

class _AdminCreateMeterScreenState
    extends ConsumerState<AdminCreateMeterScreen> {
  final _serialController = TextEditingController();
  final _deviceController = TextEditingController();
  bool _isScanning = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _serialController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _createMeter() async {
    if (_serialController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(adminMetersProvider.notifier)
          .createMeter(
            _serialController.text.trim(),
            deviceId: _deviceController.text.isNotEmpty
                ? _deviceController.text.trim()
                : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meter created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to create meter. Check if Serial ID is valid UUID.',
            ),
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
    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Meter Barcode')),
        body: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              setState(() {
                _serialController.text = barcodes.first.rawValue!;
                _isScanning = false;
              });
            }
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register New Meter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(LucideIcons.plusCircle, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Add New Virtual Meter',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _serialController,
              decoration: InputDecoration(
                labelText: 'Serial ID (Required)',
                hintText: 'Enter meter serial number',
                prefixIcon: const Icon(LucideIcons.hash),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.scan),
                  onPressed: () => setState(() => _isScanning = true),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _deviceController,
              decoration: InputDecoration(
                labelText: 'Device ID (Optional)',
                hintText: 'Enter LoRa DevEui if known',
                prefixIcon: const Icon(LucideIcons.radio),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            FilledButton(
              onPressed: _isLoading || _serialController.text.isEmpty
                  ? null
                  : _createMeter,
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
                      'Register Meter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
