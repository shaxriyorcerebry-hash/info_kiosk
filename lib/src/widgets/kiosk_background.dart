import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The full-screen decorative backdrop: a soft blue gradient with slowly
/// drifting blurred blobs, a faint dot grid and horizon waves. Switches to a
/// dark cinematic gradient while the AI advisor screen is open.
///
/// Split into two paint layers so the per-frame work stays small: the blobs
/// (and stars, on dark) animate inside their own [RepaintBoundary], while the
/// dot grid and waves are painted once and cached.
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => CustomPaint(
                  painter: _AnimatedPainter(_c.value, widget.dark),
                  size: Size.infinite,
                ),
              ),
            ),
            if (!widget.dark)
              const RepaintBoundary(
                child: CustomPaint(
                  painter: _StaticPainter(),
                  size: Size.infinite,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The animated layer: drifting blobs, plus twinkling stars on dark.
class _AnimatedPainter extends CustomPainter {
  _AnimatedPainter(this.t, this.dark);

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
      _blob(canvas, Offset(w * 0.16 + math.cos(a * 0.7) * 30, h * 0.72), h * 0.34,
          const Color(0x1F1D4ED8));
      _blob(canvas, Offset(w * 0.86 + math.sin(a * 0.8) * 26, h * 0.18), h * 0.30,
          const Color(0x1A0E7490));
      _drawStars(canvas, size, a);
      return;
    }

    _blob(canvas, Offset(w * 0.08 + math.sin(a) * 24, h * 0.02 + math.cos(a) * 20),
        280, const Color(0xFF93BCEA).withValues(alpha: 0.34));
    _blob(canvas, Offset(w * 0.94 + math.cos(a) * 26, h * 0.98 + math.sin(a) * 22),
        320, const Color(0xFFB8D4F2).withValues(alpha: 0.40));
    _blob(canvas, Offset(w * 0.55 + math.sin(a + 1) * 22, h * 0.34 + math.cos(a) * 18),
        230, const Color(0xFFD9E9FA).withValues(alpha: 0.55));
  }

  /// A field of gently twinkling stars for the dark (AI advisor) backdrop.
  /// Positions are derived from the index, so the field is stable frame to
  /// frame while each star breathes on its own rhythm.
  void _drawStars(Canvas canvas, Size size, double a) {
    final paint = Paint();
    for (var i = 0; i < 90; i++) {
      final fx = (math.sin(i * 12.9898) * 43758.5453).abs() % 1.0;
      final fy = (math.sin(i * 78.2330) * 12543.8567).abs() % 1.0;
      final twinkle =
          0.5 + 0.5 * math.sin(a * (0.6 + fx * 0.9) + i * 2.4);
      paint.color = Colors.white.withValues(alpha: 0.06 + 0.22 * twinkle);
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        0.8 + fy * 1.4 + twinkle * 0.6,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AnimatedPainter old) => old.t != t || old.dark != dark;
}

/// The static overlay of the light backdrop: dot grid and horizon waves.
/// Painted once (its RepaintBoundary caches the layer between frames).
class _StaticPainter extends CustomPainter {
  const _StaticPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawDotGrid(canvas, size);
    _drawWaves(canvas, size);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E4B8F).withValues(alpha: 0.045)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    const step = 28.0;
    final points = <Offset>[
      for (double y = 0; y < size.height; y += step)
        for (double x = 0; x < size.width; x += step) Offset(x, y),
    ];
    canvas.drawPoints(PointMode.points, points, paint);
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
  bool shouldRepaint(_StaticPainter old) => false;
}
