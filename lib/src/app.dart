import 'package:flutter/material.dart';

import 'config.dart';
import 'kiosk_root.dart';
import 'kiosk_scroll_behavior.dart';
import 'theme.dart';

/// Application root — a single-page kiosk, no routing needed.
class KioskApp extends StatelessWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xalq qabulxonasi',
      debugShowCheckedModeBanner: false,
      // A finger drags the lists here, whatever pointer kind the touch overlay
      // claims to be — see [KioskScrollBehavior].
      scrollBehavior: const KioskScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
        scaffoldBackgroundColor: AppColors.homeGradient.first,
        useMaterial3: true,
      ),
      // No mouse pointer on a public screen: a touch overlay that enumerates
      // as a mouse otherwise leaves an arrow parked wherever the last visitor
      // touched. See [KioskConfig.hideCursor].
      home: MouseRegion(
        cursor: KioskConfig.hideCursor
            ? SystemMouseCursors.none
            : MouseCursor.defer,
        child: const KioskRoot(),
      ),
    );
  }
}
