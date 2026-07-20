import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/config.dart';
import 'package:info_kiosk/src/widgets/exit_password_dialog.dart';

/// Pumps a host page whose single button opens the exit password prompt, and
/// records what the prompt resolved to.
Future<void> _open(WidgetTester tester, List<bool> results) async {
  // The dialog carries a full on-screen keyboard; give it a kiosk-sized
  // surface so every key and button is actually hit-testable.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1080, 1500);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(await askExitPassword(context)),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('correct password resolves true', (tester) async {
    final results = <bool>[];
    await _open(tester, results);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), KioskConfig.exitPassword);
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();

    expect(results, [true]);
  });

  testWidgets('wrong password is rejected and clears the field', (
    tester,
  ) async {
    final results = <bool>[];
    await _open(tester, results);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'wrong-password');
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();

    // Still open, showing the error, with the field emptied for a retry.
    expect(results, isEmpty);
    expect(find.text("Parol noto'g'ri"), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
  });

  testWidgets('cancel resolves false', (tester) async {
    final results = <bool>[];
    await _open(tester, results);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });

  testWidgets('on-screen keys type the password without a keyboard', (
    tester,
  ) async {
    final results = <bool>[];
    await _open(tester, results);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Tap the password out one on-screen key at a time.
    for (final ch in KioskConfig.exitPassword.split('')) {
      await tester.tap(find.widgetWithText(Container, ch).first);
      await tester.pump();
    }
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();

    expect(results, [true]);
  });
}
