// The governor's reception date, set in the dashboard, drives the governor's
// card in "Shaxsiy qabul"; staff can pull fresh content with a long press on
// the logo; and the section lays out for the portrait hall kiosks.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/data.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/screens/home_screen.dart';
import 'package:info_kiosk/src/screens/jadval_screen.dart';
import 'package:info_kiosk/src/services/ai_api.dart';
import 'package:info_kiosk/src/services/content_store.dart';
import 'package:info_kiosk/src/services/hokim_reception.dart';
import 'package:info_kiosk/src/services/kiosk_content_api.dart';
import 'package:info_kiosk/src/theme.dart';
import 'package:info_kiosk/src/widgets/empty_content.dart';
import 'package:info_kiosk/src/widgets/header_bar.dart';
import 'package:info_kiosk/src/widgets/staff_refresh.dart';

/// `GET /kiosk/reception-points` as the backend served it on 2026-09-16.
List<dynamic> _points({Object? at = '2026-09-24T05:00:00Z'}) => [
  {
    'id': 1,
    'name_uz': 'Prezident Xalq qabulxonasi',
    'ticket_prefix': 'P',
    'sort_order': 1,
    'next_reception_at': '2026-09-20T05:00:00Z',
    'reception_location': null,
  },
  {
    'id': 2,
    'name_uz': 'Hokim qabuli',
    'ticket_prefix': 'H',
    'sort_order': 2,
    'next_reception_at': at,
    'reception_location': 'Toshkent viloyati Xalq qabulxonasi',
  },
];

Map<String, dynamic> _official(
  String name,
  String position,
  String day,
  String time,
  String phone,
) => {
  'full_name': {'uz': name, 'ru': name, 'en': name},
  'position': {'uz': position, 'ru': position, 'en': position},
  'reception_day': {'uz': day, 'ru': day, 'en': day},
  'time': time,
  'phone': phone,
  'is_active': true,
};

/// The `reception-schedule` payload: the governor and three deputies.
Map<String, dynamic> _schedule() => {
  'intro': {'uz': 'Qabul jadvali'},
  'note': {'uz': 'Izoh'},
  'officials': [
    _official('Mirzayev Zoyir Toirovich', 'Toshkent viloyati hokimi',
        'Har haftaning chorshanba kuni', '10:00 – 14:00', '71-232-80-73'),
    _official('Tursunov Otabek', "Viloyat hokimining birinchi o'rinbosari",
        'Har haftaning seshanba kuni', '14:00 – 16:00', '71-232-80-71'),
    _official('Qoraboyev Xurshid', "Viloyat hokimining o'rinbosari",
        'Har haftaning juma kuni', '15:00 – 17:00', '71-232-80-44'),
    _official('Mahmudov Shukurulla', "Viloyat hokimining o'rinbosari",
        'Har haftaning seshanba kuni', '10:00 – 12:00', '71-232-80-42'),
  ],
};

/// 2026-09-16 15:00 in Tashkent.
DateTime _wed() => DateTime.utc(2026, 9, 16, 10);

/// A backend that answers from memory and counts the calls.
class _FakeApi extends KioskContentApi {
  _FakeApi({this.schedule, this.points, this.delay = Duration.zero})
    : super(apiBase: 'https://example.invalid/api');

  Object? schedule;
  Object? points;
  final Duration delay;
  int sectionCalls = 0;
  int pointsCalls = 0;

  @override
  Future<ContentResponse> fetch(String section, {String? etag}) async {
    sectionCalls++;
    await Future<void>.delayed(delay);
    final value = section == 'reception-schedule' ? schedule : null;
    if (value is Exception) throw value;
    return ContentResponse(
      section: section,
      data: value as Map<String, dynamic>?,
    );
  }

  @override
  Future<List<dynamic>> fetchReceptionPoints() async {
    pointsCalls++;
    final value = points;
    if (value is Exception) throw value;
    return (value as List<dynamic>?) ?? const [];
  }
}

class _NoAi extends AiApi {
  _NoAi() : super(apiBase: '');
}

ContentStore _store({DateTime Function()? clock}) =>
    ContentStore(api: _FakeApi(), clock: clock ?? _wed)
      ..applyPayload('reception-schedule', _schedule());

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HokimReception', () {
    test("reads the governor's point, on the Tashkent clock", () {
      final h = HokimReception.fromPoints(_points())!;
      expect(h.at, DateTime.utc(2026, 9, 24, 10));
      expect(h.location, 'Toshkent viloyati Xalq qabulxonasi');
    });

    test('an offset or a bare time is read as Tashkent time too', () {
      for (final at in ['2026-09-24T10:00:00+05:00', '2026-09-24T10:00:00']) {
        final h = HokimReception.fromPoints(_points(at: at))!;
        expect((h.at!.day, h.at!.hour), (24, 10), reason: at);
      }
    });

    test('no time set is "not set"; no governor at all is "unknown"', () {
      expect(HokimReception.fromPoints(_points(at: null))!.at, isNull);
      expect(HokimReception.fromPoints([_points().first]), isNull);
      expect(HokimReception.fromPoints({'detail': 'x'}), isNull);
      expect(
        HokimReception.fromPoints([
          {'name_uz': 'Hokim qabuli', 'next_reception_at': '2026-09-24T05:00:00Z'},
        ])?.at?.day,
        24,
        reason: 'without a ticket prefix the name decides',
      );
    });

    test('stays upcoming to the end of its day in Tashkent', () {
      final h = HokimReception.fromPoints(_points())!;
      expect(h.isUpcoming(_wed()), isTrue);
      expect(h.isUpcoming(DateTime.utc(2026, 9, 24, 18, 59)), isTrue);
      expect(h.isUpcoming(DateTime.utc(2026, 9, 24, 19)), isFalse);
    });

    test('finds the governor, not a deputy "hokimining o\'rinbosari"', () {
      final seed = AppData.shaxsiyQabul;
      expect([
        for (var i = 0; i < seed.length; i++)
          if (isHokimOfficial(seed[i])) i,
      ], [0]);
    });

    test('dates read naturally in all three languages', () {
      final d = DateTime.utc(2026, 9, 24, 10);
      expect(AppData.receptionDate(d, Lang.uz), '24-sentabr, payshanba');
      expect(AppData.receptionDate(d, Lang.ru), '24 сентября, четверг');
      expect(AppData.receptionDate(d, Lang.en), 'Thursday, 24 September');
      final jan = DateTime.utc(2027, 1, 4);
      expect(AppData.receptionDate(jan, Lang.uz, withYear: true),
          '2027-yil 4-yanvar, dushanba');
    });
  });

  group("ContentStore — the governor's card", () {
    test('a set date replaces the weekly slot on that card only', () {
      final s = _store()..applyPoints(_points());
      final shown = s.officialsShown!.officials;

      expect(shown.first.day[Lang.ru], '24 сентября, четверг');
      expect(shown.first.time, '10:00');
      expect(shown.first.location, 'Toshkent viloyati Xalq qabulxonasi');
      expect(shown.first.scheduled?.at, DateTime.utc(2026, 9, 24, 10));
      for (var i = 1; i < shown.length; i++) {
        expect(shown[i], same(s.officials!.officials[i]));
      }
    });

    test('a passed or cleared date says it is not set', () {
      for (final s in [
        _store(clock: () => DateTime.utc(2026, 9, 25, 6))..applyPoints(_points()),
        _store()..applyPoints(_points(at: null)),
      ]) {
        final hokim = s.officialsShown!.officials.first;
        expect(hokim.day[Lang.uz], 'Qabul vaqti belgilanmagan');
        expect(hokim.time, isEmpty);
        expect(hokim.scheduled, isNull);
      }
    });

    test('an unknown date leaves the published schedule as it is', () {
      final s = _store()..applyPoints([_points().first]);
      expect(s.officialsShown, same(s.officials));
    });

    test('no published schedule stays empty — the date invents no card', () {
      final s = ContentStore(api: _FakeApi(), clock: _wed)
        ..applyPoints(_points());
      expect(s.officialsShown, isNull);
    });

    test('a cached date is on screen before the network is touched',
        () async {
      final dir = Directory.systemTemp.createTempSync('info_kiosk_points');
      addTearDown(() => dir.deleteSync(recursive: true));

      final online = ContentStore(
        api: _FakeApi(schedule: _schedule(), points: _points()),
        cacheDir: dir,
        clock: _wed,
      );
      expect(await online.refresh(), isTrue);
      online.dispose();

      final offline = ContentStore(
        api: _FakeApi(
          schedule: Exception('down'),
          points: Exception('down'),
        ),
        cacheDir: dir,
        clock: _wed,
      );
      await offline.start();
      expect(offline.officialsShown!.officials.first.time, '10:00');
      offline.dispose();
    });
  });

  group('ContentStore.refresh', () {
    test('false when the points fail, while the sections still apply',
        () async {
      final dir = Directory.systemTemp.createTempSync('info_kiosk_fail');
      addTearDown(() => dir.deleteSync(recursive: true));
      final s = ContentStore(
        api: _FakeApi(schedule: _schedule(), points: Exception('down')),
        cacheDir: dir,
        clock: _wed,
      );
      expect(await s.refresh(), isFalse);
      expect(s.officials?.officials, hasLength(4));
      expect(s.officialsShown!.officials.first.time, '10:00 – 14:00');
    });

    test('an offline build reports failure', () async {
      final s = ContentStore(api: KioskContentApi(apiBase: ''));
      expect(await s.refresh(), isFalse);
    });

    test('a second call while one is running joins it', () async {
      final api = _FakeApi(
        schedule: _schedule(),
        points: _points(),
        delay: const Duration(milliseconds: 5),
      );
      final dir = Directory.systemTemp.createTempSync('info_kiosk_join');
      addTearDown(() => dir.deleteSync(recursive: true));
      final s = ContentStore(api: api, cacheDir: dir);

      expect(await Future.wait([s.refresh(), s.refresh()]), [true, true]);
      expect((api.sectionCalls, api.pointsCalls),
          (KioskContentApi.sections.length, 1));

      await s.refresh();
      expect(api.pointsCalls, 2);
    });
  });

  group('Shaxsiy qabul screen', () {
    KioskState stateWith(ContentStore store) =>
        KioskState(api: _NoAi(), content: store)
          ..openJadval(JadvalView.shaxsiy);

    testWidgets("the governor's card shows the date and the place",
        (tester) async {
      final state = stateWith(_store()..applyPoints(_points()));
      await tester.pumpWidget(_app(JadvalScreen(state: state)));
      await tester.pumpAndSettle();

      expect(find.text('24-sentabr'), findsOneWidget);
      expect(find.text('Payshanba'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('NAVBATDAGI QABUL'), findsOneWidget);
      expect(find.text('Toshkent viloyati Xalq qabulxonasi'), findsOneWidget);
      expect(find.text('10:00 – 14:00'), findsNothing);
    });

    testWidgets('an empty schedule still says so, date or not',
        (tester) async {
      final store = ContentStore(api: _FakeApi(), clock: _wed)
        ..applyPayload('reception-schedule', null)
        ..applyPoints(_points());
      await tester.pumpWidget(_app(JadvalScreen(state: stateWith(store))));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyContent), findsOneWidget);
      expect(find.text('24-sentabr'), findsNothing);
    });

    testWidgets('portrait 1080 px: governor side by side, deputies two a row',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final state = stateWith(_store()..applyPoints(_points()));
      await tester.pumpWidget(_app(JadvalScreen(state: state)));
      await tester.pumpAndSettle();

      final name = tester.getRect(find.text('Mirzayev Zoyir Toirovich'));
      final date = tester.getRect(find.text('24-sentabr'));
      expect(date.left, greaterThan(name.right));

      final second = tester.getRect(find.text('Tursunov Otabek'));
      final third = tester.getRect(find.text('Qoraboyev Xurshid'));
      expect(third.top, closeTo(second.top, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('portrait at 125 % and 150 % scaling lays out cleanly',
        (tester) async {
      addTearDown(tester.view.reset);
      for (final (ratio, sideBySide) in [(1.25, true), (1.5, false)]) {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = ratio;
        for (final lang in Lang.values) {
          final state = stateWith(_store()..applyPoints(_points()))
            ..setLang(lang);
          await tester.pumpWidget(_app(JadvalScreen(state: state)));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$ratio $lang');
        }
        final name = tester.getRect(find.text('Mirzayev Zoyir Toirovich'));
        final date = tester.getRect(find.text('24 September'));
        expect(date.left > name.right, sideBySide, reason: '$ratio');
      }
    });
  });

  group('home screen, portrait', () {
    ContentStore withCards(int n) => ContentStore(api: _FakeApi())
      ..applyPayload('sections', {
        'items': [
          for (final (i, key) in ['qabul', 'jadval', 'masalalar', 'faq',
            'ai', 'contact'].take(n).indexed)
            {
              'key': key,
              'icon': 'help',
              'sort_order': i,
              'title': {'uz': 'Bo\'lim $i'},
              'desc': {'uz': 'Tavsif $i'},
            },
        ],
      });

    for (final size in const [Size(1080, 1920), Size(1080, 1400)]) {
      testWidgets('six cards fit a ${size.width}x${size.height} screen',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final state = KioskState(api: _NoAi(), content: withCards(6));
        await tester.pumpWidget(_app(HomeScreen(state: state)));
        await tester.pump(const Duration(seconds: 2));

        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        expect(scroll.position.maxScrollExtent, 0);
        // …and the block sits in the middle rather than at the top.
        final title = tester.getTopLeft(find.text("Kerakli bo'limni tanlang"));
        expect(title.dy, greaterThan(40));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('staff refresh', () {
    testWidgets('the logo fires only after a three-second hold',
        (tester) async {
      var held = 0;
      final state = KioskState(api: _NoAi(), content: _store());
      await tester.pumpWidget(_app(HeaderBar(
        state: state,
        palette: Palette.light,
        clock: ValueNotifier(DateTime(2026, 9, 16)),
        onLogoHold: () => held++,
      )));

      Future<void> hold(Duration d) async {
        final g = await tester.startGesture(
          tester.getCenter(find.byType(Image).first),
        );
        await tester.pump(d);
        await g.up();
        await tester.pump();
      }

      await hold(const Duration(seconds: 1));
      expect(held, 0);
      await hold(const Duration(milliseconds: 3100));
      expect(held, 1);
    });

    Future<void> run(WidgetTester tester, Lang lang, bool ok) async {
      await tester.pumpWidget(_app(Builder(
        builder: (context) => TextButton(
          onPressed: () => runStaffRefresh(
            context,
            lang: () => lang,
            refresh: () async => ok,
          ),
          child: const Text('go'),
        ),
      )));
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('a refresh that worked says so, with the time',
        (tester) async {
      await run(tester, Lang.uz, true);
      expect(find.textContaining("Ma'lumot yangilandi · "), findsOneWidget);
    });

    testWidgets('an unreachable server is reported in the visitor language',
        (tester) async {
      await run(tester, Lang.ru, false);
      expect(
        find.text('Нет связи с сервером — показаны прежние данные'),
        findsOneWidget,
      );
    });
  });
}
