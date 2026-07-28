import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/kiosk_scroll_behavior.dart';
import 'package:info_kiosk/src/widgets/exit_button.dart';
import 'package:info_kiosk/src/widgets/pressable.dart';

/// The kiosk is driven by a touch overlay on a Windows machine, and such an
/// overlay may present itself to the system either as a real touch device or
/// as an ordinary mouse. These tests pin the behaviour that has to hold on
/// both kinds of hardware — nothing here can be verified by reading the code
/// on a developer's laptop, where the mouse is a real mouse.
void main() {
  group('scrolling', () {
    testWidgets('a long page scrolls when dragged by a mouse-kind pointer',
        (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const KioskScrollBehavior(),
          home: Scaffold(
            body: ListView.builder(
              controller: controller,
              itemCount: 60,
              itemExtent: 80,
              itemBuilder: (_, i) => Text('qator $i'),
            ),
          ),
        ),
      );

      // Exactly what an infra-red touch frame produces: a press, a drag and a
      // release, all reported as a mouse. Flutter's desktop default refuses to
      // scroll on this, which would strand a visitor on any long list.
      await tester.dragFrom(
        tester.getCenter(find.byType(ListView)),
        const Offset(0, -300),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0),
          reason: 'a finger on a mouse-reporting panel must still scroll');
    });

    testWidgets('a real touch drag scrolls too', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const KioskScrollBehavior(),
          home: Scaffold(
            body: ListView.builder(
              controller: controller,
              itemCount: 60,
              itemExtent: 80,
              itemBuilder: (_, i) => Text('qator $i'),
            ),
          ),
        ),
      );

      await tester.dragFrom(
        tester.getCenter(find.byType(ListView)),
        const Offset(0, -300),
        kind: PointerDeviceKind.touch,
      );
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0));
    });

    testWidgets('a scrollable page shows its scrollbar before anyone touches it',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const KioskScrollBehavior(),
          home: Scaffold(
            body: ListView.builder(
              itemCount: 60,
              itemExtent: 80,
              itemBuilder: (_, i) => Text('qator $i'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The visitor must be able to see that the page continues below the fold
      // without first discovering it by accident.
      final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(scrollbar.thumbVisibility, isTrue);
      expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
    });

    test('every pointer kind may start a drag', () {
      const behaviour = KioskScrollBehavior();
      expect(behaviour.dragDevices, contains(PointerDeviceKind.mouse));
      expect(behaviour.dragDevices, contains(PointerDeviceKind.touch));
      expect(behaviour.dragDevices, contains(PointerDeviceKind.stylus));
      expect(behaviour.dragDevices, contains(PointerDeviceKind.unknown));
    });
  });

  group('press feedback', () {
    testWidgets('Pressable reports the press state to its builder',
        (tester) async {
      final states = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Pressable(
              onTap: () {},
              builder: (context, pressed) {
                states.add(pressed);
                return const SizedBox(width: 120, height: 60);
              },
            ),
          ),
        ),
      );
      expect(states.last, isFalse);

      final gesture = await tester.press(find.byType(Pressable));
      await tester.pump();
      expect(states.last, isTrue, reason: 'the touch must be visible at once');

      await gesture.up();
      await tester.pump();
      expect(states.last, isFalse, reason: 'and must clear on release');
    });

    testWidgets('the press state clears when a touch slides off the target',
        (tester) async {
      final states = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Pressable(
              onTap: () {},
              builder: (context, pressed) {
                states.add(pressed);
                return const SizedBox(width: 120, height: 60);
              },
            ),
          ),
        ),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      expect(states.last, isTrue);

      // A finger that wanders off before lifting cancels the tap; without the
      // cancel handler the card would stay visually pressed for good.
      await gesture.moveBy(const Offset(0, 400));
      await gesture.up();
      await tester.pump();
      expect(states.last, isFalse);
    });
  });

  group('exit button', () {
    testWidgets('sits in a 56x56 touch area and fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: ExitButton(onTap: () => tapped = true)),
          ),
        ),
      );

      // Small badge, generous target: staff hit it without aiming, visitors
      // are not invited to.
      expect(tester.getSize(find.byType(ExitButton)), const Size(56, 56));

      await tester.tap(find.byType(ExitButton));
      expect(tapped, isTrue);
    });

    testWidgets('carries no tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: ExitButton(onTap: () {}))),
        ),
      );
      // A tooltip needs a hover or a long press; a kiosk visitor does neither,
      // so it would only ever be dead weight in the tree.
      expect(find.byType(Tooltip), findsNothing);
    });
  });
}
