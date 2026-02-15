import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterTankWidget extends StatefulWidget {
  final double percentage;
  final double width;
  final double height;

  const WaterTankWidget({
    super.key,
    required this.percentage,
    this.width = 100,
    this.height = 160,
  });

  @override
  State<WaterTankWidget> createState() => _WaterTankWidgetState();
}

class _WaterTankWidgetState extends State<WaterTankWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            // Background
            Container(color: const Color(0xFFF1F5F9)),

            // Water with waves
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _WaterWavePainter(
                    percentage: widget.percentage,
                    wavePhase: _waveAnimation.value,
                  ),
                );
              },
            ),

            // Glass shine effect
            Positioned(
              left: 8,
              top: 8,
              bottom: 8,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double percentage;
  final double wavePhase;

  _WaterWavePainter({required this.percentage, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final fillHeight = size.height * (1 - percentage / 100);
    final waveHeight = 8.0;
    final waveWidth = size.width;

    final path = Path();
    path.moveTo(0, fillHeight);

    // Draw wave
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          fillHeight +
          math.sin((x / waveWidth) * 2 * math.pi + wavePhase) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFBFDBFE).withOpacity(0.8),
        const Color(0xFF3B82F6),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, fillHeight, size.width, size.height - fillHeight),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaterWavePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.wavePhase != wavePhase;
  }
}
