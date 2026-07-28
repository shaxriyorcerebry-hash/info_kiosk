import 'package:flutter/material.dart';

/// Touch-first tap wrapper: shrinks slightly while the finger is down and
/// springs back on release. Every tappable surface on the kiosk uses this so
/// touches always produce immediate, visible feedback.
///
/// There is deliberately **no hover state** anywhere in this kiosk. The screen
/// is driven by a touch overlay, so a finger either presses or it does not —
/// and when such an overlay enumerates as a mouse (common with infra-red
/// frames), a hover style would latch on at the last touched point and stay
/// there after the finger is long gone. Press feedback is the only affordance
/// that is true on this hardware.
///
/// Pass [builder] instead of [child] when the content itself should react to
/// being pressed (a filling arrow, a brighter border …).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    this.child,
    this.builder,
    this.pressedScale = 0.955,
  }) : assert(
         child != null || builder != null,
         'Pressable needs either a child or a builder',
       );

  final VoidCallback onTap;

  /// Static content, used when the child does not care about the press state.
  final Widget? child;

  /// Content that rebuilds with the current press state.
  final Widget Function(BuildContext context, bool pressed)? builder;

  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: Duration(milliseconds: _down ? 80 : 220),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child ?? widget.builder!(context, _down),
      ),
    );
  }
}
