import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class StyledDialog extends StatefulWidget {
  final String title;
  final String? description;
  final Widget? content;
  final IconData icon;
  final Color iconColor;
  final String confirmLabel;
  final Future<void> Function() onConfirm;
  final Color? confirmColor;

  const StyledDialog({
    super.key,
    required this.title,
    this.description,
    this.content,
    required this.icon,
    required this.iconColor,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmColor,
  });

  @override
  State<StyledDialog> createState() => _StyledDialogState();
}

class _StyledDialogState extends State<StyledDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colors.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (widget.description != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.description!,
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.content != null) ...[
              const SizedBox(height: 24),
              widget.content!,
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            try {
                              await widget.onConfirm();
                              if (context.mounted) Navigator.pop(context);
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.confirmColor ?? colors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                        : Text(
                            widget.confirmLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showStyledDialog({
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
  showDialog(
    context: context,
    builder: (context) => StyledDialog(
      title: title,
      description: description,
      content: content,
      icon: icon,
      iconColor: iconColor,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
      confirmColor: confirmColor,
    ),
  );
}
