import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/core/update/kiosk_updater.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/theme.dart';
import 'package:info_kiosk/src/widgets/exit_button.dart';
import 'package:info_kiosk/src/widgets/footer_bar.dart';
import 'package:info_kiosk/src/widgets/settings_panel.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Pastki tasma, kiosk root'idagi kabi ulangan: oddiy bosish — parolli chiqish,
/// uzoq bosish — sozlamalar paneli (parolsiz), paneldagi «Chiqish» — yana
/// parolli chiqish.
Future<void> _pumpFooter(
  WidgetTester tester, {
  required List<String> log,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1080, 1600);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Align(
            alignment: Alignment.bottomCenter,
            child: FooterBar(
              palette: Palette.light,
              lang: Lang.uz,
              onExit: () => log.add('parolli chiqish'),
              onSettings: () async {
                log.add('sozlamalar');
                if (await showKioskSettings(context)) log.add('parolli chiqish');
              },
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'info_kiosk',
      packageName: 'info_kiosk',
      version: '1.7.0',
      buildNumber: '11',
      buildSignature: '',
    );
    // Test muhitida yangilovchi «qo'llab-quvvatlanmaydi» holatida qoladi
    // (release build emas) — tarmoqqa chiqmaydi, taymer qo'ymaydi.
    KioskUpdater.init(const KioskUpdateConfig(
      appKey: 'info_kiosk',
      appTitle: 'Info kiosk',
      installName: 'InfoKiosk',
    ));
  });

  testWidgets('oddiy bosish — avvalgidek parolli chiqish', (tester) async {
    final log = <String>[];
    await _pumpFooter(tester, log: log);

    await tester.tap(find.byType(ExitButton));
    await tester.pumpAndSettle();

    expect(log, ['parolli chiqish']);
    expect(find.text('Sozlamalar'), findsNothing);
  });

  testWidgets('uzoq bosish — sozlamalar paneli parolsiz ochiladi', (
    tester,
  ) async {
    final log = <String>[];
    await _pumpFooter(tester, log: log);

    await tester.longPress(find.byType(ExitButton));
    await tester.pumpAndSettle();

    expect(log, ['sozlamalar']);
    expect(find.text('Sozlamalar'), findsOneWidget);
    // Parol maydoni yo'q — panel to'g'ridan-to'g'ri ochildi.
    expect(find.byType(TextField), findsNothing);
    // «Yangilanish» bo'limi va haqiqiy paket versiyasi.
    expect(find.text('Yangilanish'), findsOneWidget);
    expect(find.text('1.7.0'), findsOneWidget);
    expect(find.text('Hozir tekshirish'), findsOneWidget);

    await tester.tap(find.text('Yopish'));
    await tester.pumpAndSettle();
    expect(find.text('Sozlamalar'), findsNothing);
    expect(log, ['sozlamalar']);
  });

  testWidgets('paneldagi «Chiqish» parolli chiqishga o\'tadi', (
    tester,
  ) async {
    final log = <String>[];
    await _pumpFooter(tester, log: log);

    await tester.longPress(find.byType(ExitButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();

    expect(log, ['sozlamalar', 'parolli chiqish']);
    expect(find.text('Sozlamalar'), findsNothing);
  });
}
