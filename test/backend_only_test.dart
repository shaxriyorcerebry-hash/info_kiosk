import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/screens/contact_screen.dart';
import 'package:info_kiosk/src/screens/faq_screen.dart';
import 'package:info_kiosk/src/screens/home_screen.dart';
import 'package:info_kiosk/src/screens/jadval_screen.dart';
import 'package:info_kiosk/src/screens/masalalar_screen.dart';
import 'package:info_kiosk/src/screens/qabul_screen.dart';
import 'package:info_kiosk/src/services/ai_api.dart';
import 'package:info_kiosk/src/widgets/empty_content.dart';

/// Proof that the kiosk has no content of its own left.
///
/// Every screen is pumped with an empty store — the state a kiosk is in before
/// its first successful fetch, or when the office has published nothing. If
/// any built-in text were still wired up, one of these screens would render it
/// instead of the "no data entered" panel, and the test would fail.
///
/// This is the guarantee behind the promise made to the office: what a visitor
/// reads is what the admin panel says, and nothing else.
class _NoBackend extends AiApi {
  _NoBackend() : super(apiBase: '');
}

KioskState _emptyState() => KioskState(api: _NoBackend());

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
  await tester.pump();
}

void main() {
  testWidgets('the home screen shows no built-in cards', (tester) async {
    final s = _emptyState();
    await _pump(tester, HomeScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    // The section names that used to be compiled in must be nowhere on screen.
    expect(find.text('Qabul tartibi'), findsNothing);
    expect(find.text('AI Maslahatchi'), findsNothing);
    s.dispose();
  });

  testWidgets('the reception procedure shows no built-in steps', (tester) async {
    final s = _emptyState();
    await _pump(tester, QabulScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    expect(find.textContaining('pasport', findRichText: true), findsNothing);
    s.dispose();
  });

  testWidgets('the FAQ shows no built-in questions', (tester) async {
    final s = _emptyState();
    await _pump(tester, FaqScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    s.dispose();
  });

  testWidgets('the contact screen shows no built-in address or phone',
      (tester) async {
    final s = _emptyState();
    await _pump(tester, ContactScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    expect(find.text('(71) 230-24-30'), findsNothing);
    expect(find.text('Nurafshon shahri'), findsNothing);
    s.dispose();
  });

  testWidgets('the issues section shows no built-in subjects', (tester) async {
    final s = _emptyState();
    await _pump(tester, MasalalarScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    s.dispose();
  });

  testWidgets('the in-person schedule shows no built-in officials',
      (tester) async {
    final s = _emptyState()..openJadval(JadvalView.shaxsiy);
    await _pump(tester, JadvalScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    expect(find.textContaining('Mirzayev'), findsNothing);
    s.dispose();
  });

  testWidgets('the mobile schedule shows no built-in organisations',
      (tester) async {
    final s = _emptyState()..openJadval(JadvalView.sayyor);
    await _pump(tester, JadvalScreen(state: s));

    expect(find.byType(EmptyContent), findsOneWidget);
    s.dispose();
  });

  testWidgets('an empty section says so in the visitor\'s language',
      (tester) async {
    final s = _emptyState()..setLang(Lang.ru);
    s.content.applyPayload('faq', null); // the fetch happened, nothing in it
    await _pump(tester, FaqScreen(state: s));

    expect(find.text(Tr(Lang.ru).noContent), findsOneWidget);
    s.dispose();
  });

  testWidgets('nothing is blamed on the office before the first fetch',
      (tester) async {
    final s = _emptyState();
    // `ready` is false until the cache has been read and a fetch attempted:
    // a slow start-up must not accuse the office of an empty database.
    await _pump(tester, FaqScreen(state: s));
    expect(find.text(Tr(Lang.uz).contentLoading), findsOneWidget);

    s.content.applyPayload('faq', null); // fetch done, section genuinely empty
    await _pump(tester, FaqScreen(state: s));
    expect(find.text(Tr(Lang.uz).noContent), findsOneWidget);
    s.dispose();
  });
}
