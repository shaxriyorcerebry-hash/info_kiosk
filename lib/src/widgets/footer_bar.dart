import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme.dart';
import 'exit_button.dart';

/// Thin bottom strip: organisation name · phone · touch hint, with the exit
/// (door) button anchored at the trailing edge.
class FooterBar extends StatelessWidget {
  const FooterBar({
    super.key,
    required this.palette,
    required this.lang,
    required this.onExit,
    this.orgName = '',
    this.phone = '',
  });

  final Palette palette;
  final Lang lang;
  final VoidCallback onExit;

  /// Short organisation name and phone, as published by the backend. Empty
  /// until the office details have loaded.
  final String orgName;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    Widget dot() => Text(
      '·',
      style: TextStyle(color: palette.footerDot, fontWeight: FontWeight.w600),
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: palette.footerBg,
            border: Border(top: BorderSide(color: palette.headerBorder)),
          ),
          child: Row(
            children: [
              // Leading spacer balances the trailing exit button so the info
              // row stays visually centred.
              const SizedBox(width: 38),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        orgName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.footerText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      dot(),
                      const SizedBox(width: 12),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.footerText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      dot(),
                      const SizedBox(width: 12),
                      Text(
                        t.footerHint,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.footerHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ExitButton(onTap: onExit),
            ],
          ),
        ),
      ),
    );
  }
}
