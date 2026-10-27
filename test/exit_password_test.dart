import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/config.dart';
import 'package:info_kiosk/src/widgets/exit_password_dialog.dart';

/// Pumps a host page whose single button opens the exit password prompt, and
/// records what the prompt resolved to.
/// Testdagi parol — haqiqiy chiqish paroli kodda yo'q (faqat xeshi), shuning
/// uchun dialog shu parolning xeshi bilan tekshiriladi.
const _testPass = 'test2026';

bool _verifyTest(String input) =>
    KioskConfig.hashPassword(input) == KioskConfig.hashPassword(_testPass);

Future<void> _open(
  WidgetTester tester,
  List<bool> results, {
  bool Function(String input)? verify = _verifyTest,
}) async {
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
            onPressed: () async => results.add(
              await askExitPassword(context, verify: verify),
            ),
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

    await tester.enterText(find.byType(TextField), _testPass);
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();

    expect(results, [true]);
  });

  testWidgets('wrong password is rejected and clears the field', (
    tester,
  ) async {
    final results = <bool>[];
    await _open(tester, results, verify: null); // haqiqiy xesh bilan
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
    for (final ch in _testPass.split('')) {
      await tester.tap(find.widgetWithText(Container, ch).first);
      await tester.pump();
    }
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();

    expect(results, [true]);
  });

  group('chiqish paroli xeshi', () {
    test('hashPassword SHA-256 hex qaytaradi', () {
      // "abc" ning standart SHA-256 qiymati (FIPS 180-2).
      expect(
        KioskConfig.hashPassword('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('kodda faqat 64 belgili hex xesh turadi', () {
      expect(
        RegExp(r'^[0-9a-f]{64}$').hasMatch(KioskConfig.exitPasswordSha256),
        isTrue,
      );
    });

    test("noto'g'ri parollar rad etiladi", () {
      expect(KioskConfig.isExitPassword(''), isFalse);
      expect(KioskConfig.isExitPassword('wrong-password'), isFalse);
      expect(
        KioskConfig.isExitPassword(KioskConfig.exitPasswordSha256),
        isFalse,
      );
    });
  });
}
