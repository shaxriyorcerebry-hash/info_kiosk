// The mobile-reception dialog lists the coming stops first: the schedule is a
// quarter long, and by its last month a visitor would otherwise scroll past a
// hundred held receptions to find next week's.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/content_models.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/sayyor_data.dart';
import 'package:info_kiosk/src/screens/jadval_screen.dart';
import 'package:info_kiosk/src/services/ai_api.dart';
import 'package:info_kiosk/src/services/content_store.dart';
import 'package:info_kiosk/src/services/kiosk_content_api.dart';

SayyorVisit _visit(String date, String place) =>
    SayyorVisit('Parkent tumani', 'Паркентский район', date, place, place);

class _NoAi extends AiApi {
  _NoAi() : super(apiBase: '');
}

void main() {
  group('MobileScheduleInfo.isPast', () {
    final today = DateTime.utc(2026, 9, 16);

    test('a day before today is past; today and later are not', () {
      expect(MobileScheduleInfo.isPast(_visit('15.09.2026', 'a'), today), isTrue);
      expect(MobileScheduleInfo.isPast(_visit('16.09.2026', 'a'), today), isFalse);
      expect(MobileScheduleInfo.isPast(_visit('01.10.2026', 'a'), today), isFalse);
      expect(MobileScheduleInfo.isPast(_visit('20.12.2025', 'a'), today), isTrue);
    });

    test('a month-only stop is past once its month is', () {
      expect(MobileScheduleInfo.isPast(_visit('Avgust', 'a'), today), isTrue);
      expect(MobileScheduleInfo.isPast(_visit('Sentabr', 'a'), today), isFalse);
    });

    test('an unreadable date is never pushed out of sight', () {
      expect(MobileScheduleInfo.isPast(_visit('kelishiladi', 'a'), today), isFalse);
    });
  });

  group('organisation dialog', () {
    Future<void> openDialog(WidgetTester tester, List<SayyorVisit> visits) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final store = ContentStore(api: KioskContentApi(apiBase: ''))
        ..applyPayload('mobile-schedule', {
          'orgs': [
            {
              'name': {'uz': 'Ijtimoiy himoya'},
              'icon': 'social',
              'visits': [
                for (final v in visits)
                  {
                    'date': v.date,
                    'region': {'uz': v.region},
                    'place': {'uz': v.place},
                  },
              ],
            },
          ],
        });
      final state = KioskState(api: _NoAi(), content: store)
        ..openJadval(JadvalView.sayyor);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: JadvalScreen(state: state))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      await tester.pumpAndSettle();
    }

    testWidgets('coming stops come first, held ones under a divider',
        (tester) async {
      await openDialog(tester, [
        _visit('22.07.2000', 'Eski MFY'),
        _visit('23.07.2000', 'Eskiroq MFY'),
        _visit('10.10.2099', 'Kelgusi MFY'),
      ]);

      final coming = tester.getTopLeft(find.text('Kelgusi MFY'));
      final divider = tester.getTopLeft(find.text("O'tgan qabullar"));
      final held = tester.getTopLeft(find.text('Eski MFY'));
      expect(coming.dy, lessThan(divider.dy));
      expect(divider.dy, lessThan(held.dy));
      expect(find.text('Yaqin kunlarda sayyor qabul rejalashtirilmagan'),
          findsNothing);
    });

    testWidgets('nothing left to come is said, above the held stops',
        (tester) async {
      await openDialog(tester, [_visit('22.07.2000', 'Eski MFY')]);

      final note = tester.getTopLeft(
        find.text('Yaqin kunlarda sayyor qabul rejalashtirilmagan'),
      );
      expect(note.dy, lessThan(tester.getTopLeft(find.text('Eski MFY')).dy));
    });

    testWidgets('an all-coming schedule shows no divider', (tester) async {
      await openDialog(tester, [_visit('10.10.2099', 'Kelgusi MFY')]);
      expect(find.text("O'tgan qabullar"), findsNothing);
    });
  });
}
