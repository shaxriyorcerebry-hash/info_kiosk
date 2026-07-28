import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

/// Scroll rules for a touch-driven Windows kiosk.
///
/// Flutter's desktop default refuses to start a scroll from a *mouse* drag —
/// on a normal PC that is right, because there a mouse scrolls with its wheel.
/// A kiosk has no wheel: the visitor drags the list with a finger, and many
/// touch overlays (infra-red frames especially) present themselves to Windows
/// as an ordinary mouse. On such a machine the stock behaviour leaves every
/// long list — the 446 mobile-reception visits, the legal answers, the FAQ —
/// completely unscrollable, with nothing on screen to explain why.
///
/// So every pointer kind may drag here. On a panel that reports real touch
/// events nothing changes; on one that reports a mouse the kiosk still works.
///
/// The scrollbar and the end-of-list stretch are the other half of the same
/// problem: standing at a kiosk, a visitor has no wheel, no keyboard and no
/// scrollbar habit, so the screen itself has to say "there is more below" and
/// "this is the end".
class KioskScrollBehavior extends MaterialScrollBehavior {
  const KioskScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };

  /// A permanently visible, finger-width scrollbar.
  ///
  /// The desktop default fades its bar in only once the pointer arrives, which
  /// on a kiosk means it is invisible exactly when it is needed: before the
  /// visitor has touched anything and is deciding whether the page continues.
  /// Flutter still omits it entirely when the content fits, so short screens
  /// stay clean.
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      thickness: 10,
      radius: const Radius.circular(5),
      child: child,
    );
  }

  /// Stretch the content at the ends of a list instead of stopping dead.
  ///
  /// On a touch screen this is the confirmation that the finger is working and
  /// the list is simply over — without it a visitor pulling at an unmoving
  /// page cannot tell that from a frozen kiosk.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}
