import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass surface: blurred backdrop + translucent tint + hairline
/// border. The shared building block of the kiosk's transparency-led look.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(24)),
    this.tint = const Color(0x14FFFFFF),
    this.borderColor = const Color(0x24FFFFFF),
    this.blur = 18,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final BorderRadius radius;
  final Color tint;
  final Color borderColor;
  final double blur;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
