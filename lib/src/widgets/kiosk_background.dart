import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The full-screen decorative backdrop: a soft blue gradient with slowly
/// drifting blurred blobs, a faint dot grid and horizon waves. Switches to a
/// dark cinematic gradient while the AI advisor screen is open.
class KioskBackground extends StatefulWidget {
  const KioskBackground({super.key, required this.dark});

  final bool dark;

  @override
  State<KioskBackground> createState() => _KioskBackgroundState();
}

class _KioskBackgroundState extends State<KioskBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: DecoratedBox(
        key: ValueKey(widget.dark),
        decoration: BoxDecoration(
          gradient: widget.dark
              ? const RadialGradient(
                  center: Alignment(0, -0.35),
                  radius: 1.1,
                  colors: AppColors.aiGradient,
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.homeGradient,
                  stops: [0.0, 0.48, 1.0],
                ),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _BackdropPainter(_c.value, widget.dark),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.t, this.dark);

  final double t;
  final bool dark;

  void _blob(Canvas c, Offset center, double r, Color color) {
    final rect = Rect.fromCircle(center: center, radius: r);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 0.7],
      ).createShader(rect);
    c.drawCircle(center, r, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final a = t * 2 * math.pi;

    if (dark) {
      _blob(canvas, Offset(w * 0.5, h * 0.32 + math.sin(a) * 20), h * 0.5,
          const Color(0x332563EB));
      return;
    }

    _blob(canvas, Offset(w * 0.08 + math.sin(a) * 24, h * 0.02 + math.cos(a) * 20),
        280, const Color(0xFF93BCEA).withValues(alpha: 0.34));
    _blob(canvas, Offset(w * 0.94 + math.cos(a) * 26, h * 0.98 + math.sin(a) * 22),
        320, const Color(0xFFB8D4F2).withValues(alpha: 0.40));
    _blob(canvas, Offset(w * 0.55 + math.sin(a + 1) * 22, h * 0.34 + math.cos(a) * 18),
        230, const Color(0xFFD9E9FA).withValues(alpha: 0.55));

    _drawDotGrid(canvas, size);
    _drawWaves(canvas, size);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E4B8F).withValues(alpha: 0.045);
    const step = 28.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  void _drawWaves(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p1 = Path()
      ..moveTo(0, h - 90)
      ..cubicTo(w * 0.27, h - 150, w * 0.53, h - 50, w * 0.8, h - 90)
      ..cubicTo(w * 0.9, h - 108, w * 0.97, h - 78, w, h - 110)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p1, Paint()..color = const Color(0xFF93BCEA).withValues(alpha: 0.14));

    final p2 = Path()
      ..moveTo(0, h - 50)
      ..cubicTo(w * 0.33, h - 90, w * 0.66, h - 25, w, h - 65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p2, Paint()..color = const Color(0xFF1E4B8F).withValues(alpha: 0.07));
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.t != t || old.dark != dark;
}
