import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme.dart';

/// The "back / home + section title" bar shown on every non-home screen.
class SectionNav extends StatelessWidget {
  const SectionNav({
    super.key,
    required this.title,
    required this.palette,
    required this.lang,
    required this.onGoHome,
  });

  final String title;
  final Palette palette;
  final Lang lang;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 10),
      child: Row(
        children: [
          _NavButton(
            palette: palette,
            onTap: onGoHome,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('←',
                    style: TextStyle(fontSize: 22, color: palette.navText, height: 1)),
                const SizedBox(width: 9),
                Text(t.back,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: palette.navText)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _NavButton(
            palette: palette,
            onTap: onGoHome,
            circle: true,
            child: Icon(Icons.home_rounded, size: 24, color: palette.navText),
          ),
          const SizedBox(width: 18),
          Container(width: 1, height: 34, color: palette.navDivider),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: palette.titleColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.palette,
    required this.onTap,
    required this.child,
    this.circle = false,
    this.padding = EdgeInsets.zero,
  });

  final Palette palette;
  final VoidCallback onTap;
  final Widget child;
  final bool circle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: circle ? 54 : null,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.navBg,
          border: Border.all(color: palette.navBorder, width: 1.5),
          borderRadius: BorderRadius.circular(circle ? 27 : 27),
        ),
        child: child,
      ),
    );
  }
}
