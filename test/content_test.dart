import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/content_models.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/screen.dart';
import 'package:info_kiosk/src/services/content_store.dart';
import 'package:info_kiosk/src/services/kiosk_content_api.dart';

/// A backend stub: hands back whatever payload the test set, and counts calls.
class _FakeApi extends KioskContentApi {
  _FakeApi(this.payloads) : super(apiBase: 'https://example.invalid/api');

  /// section → payload, or a thrown error when the value is an [Exception].
  final Map<String, Object?> payloads;
  final List<String> asked = [];

  @override
  Future<ContentResponse> fetch(String section, {String? etag}) async {
    asked.add(section);
    final value = payloads[section];
    if (value is Exception) throw value;
    return ContentResponse(
      section: section,
      data: value as Map<String, dynamic>?,
      etag: 'etag-$section',
    );
  }
}

Directory _tempDir() =>
    Directory.systemTemp.createTempSync('info_kiosk_content_test');

void main() {
  group('parsing', () {
    test('home cards keep their order and drop keys the app cannot open', () {
      final cards = parseCards(const {
        'items': [
          {
            'key': 'faq',
            'icon': 'help',
            'sort_order': 2,
            'title': {'uz': 'Savollar'},
          },
          {
            'key': 'qabul',
            'icon': 'assignment',
            'sort_order': 1,
            'title': {'uz': 'Qabul tartibi'},
          },
          // A section added on the server before the app knows how to show it.
          {
            'key': 'yangi_bolim',
            'sort_order': 3,
            'title': {'uz': 'Yangi'},
          },
          // Switched off by the office.
          {
            'key': 'contact',
            'sort_order': 4,
            'is_active': false,
            'title': {'uz': 'Aloqa'},
          },
        ],
      });

      expect(cards.map((c) => c.id), [Screen.qabul, Screen.faq]);
      expect(cards.first.title[Lang.uz], 'Qabul tartibi');
    });

    test('an unknown icon name still leaves the entry readable', () {
      final cards = parseCards(const {
        'items': [
          {
            'key': 'qabul',
            'icon': 'no_such_icon',
            'title': {'uz': 'Qabul tartibi'},
          },
        ],
      });
      expect(cards, hasLength(1));
      expect(cards.first.icon, isA<IconData>());
    });

    test('officials without a name are skipped, inactive ones hidden', () {
      final info = OfficialsInfo.parse(const {
        'intro': {'uz': 'Jadval'},
        'officials': [
          {
            'sort_order': 1,
            'full_name': {'uz': 'Mirzayev Zoyir'},
            'position': {'uz': 'Hokim'},
            'time': '10:00 – 14:00',
            'phone': '71-232-80-73',
          },
          {
            'sort_order': 2,
            'full_name': {'uz': ''},
          },
          {
            'sort_order': 3,
            'is_active': false,
            'full_name': {'uz': 'Nofaol xodim'},
          },
        ],
      });

      expect(info.officials, hasLength(1));
      expect(info.officials.first.name[Lang.uz], 'Mirzayev Zoyir');
      expect(info.officials.first.time, '10:00 – 14:00');
      expect(info.isEmpty, isFalse);
    });

    test('mobile-schedule dates arrive as ISO and are shown day-first', () {
      final info = MobileScheduleInfo.parse(const {
        'orgs': [
          {
            'name': {'uz': 'Ijtimoiy himoya'},
            'icon': 'volunteer_activism',
            'visits': [
              {
                'date': '2026-07-22',
                'region': {'uz': 'Parkent tumani', 'ru': 'Паркентский район'},
                'place': {'uz': 'Samsarak MFY', 'ru': 'Самсарак МФЙ'},
              },
              // The source only knew the month for this one.
              {
                'date': '2026-08-01',
                'date_label': {'uz': 'Avgust', 'ru': 'Август'},
                'region': {'uz': 'Chinoz tumani'},
                'place': {'uz': 'Eshonobod MFY'},
              },
            ],
          },
        ],
      });

      final visits = info.orgs.single.visits;
      expect(visits.first.date, '22.07.2026');
      expect(visits.first.regionRu, 'Паркентский район');
      expect(
        visits.last.date,
        'Avgust',
        reason: 'a month-only visit keeps its label',
      );
    });

    test('the office sets the idle reset, within sane bounds', () {
      OfficeInfo parse(Object? seconds) =>
          OfficeInfo.parse({'idle_seconds': seconds});

      expect(parse(120).idleSeconds, 120);
      // A typo in the admin panel must not reset the screen under a visitor's
      // hands, nor leave their session up for the next person.
      expect(parse(0).idleSeconds, 15);
      expect(parse(99999).idleSeconds, 600);
      expect(parse(null).idleSeconds, isNull, reason: 'built-in default wins');
    });

    test('a missing translation falls back to Uzbek, not to blank', () {
      final text = triText(const {'uz': 'Qabul tartibi', 'ru': '', 'en': null});
      expect(text[Lang.ru], 'Qabul tartibi');
      expect(text[Lang.en], 'Qabul tartibi');
    });
  });

  group('store', () {
    test('an empty section from the backend empties the screen', () async {
      final dir = _tempDir();
      final api = _FakeApi({
        'faq': {
          'items': [
            {
              'question': {'uz': 'Savol?'},
              'answer': {'uz': 'Javob.'},
            },
          ],
        },
      });
      final store = ContentStore(api: api, cacheDir: dir);

      await store.refresh();
      expect(store.faq?.items, hasLength(1));

      // The office deletes the FAQ in the admin panel.
      api.payloads['faq'] = null;
      await store.refresh();

      // No stale copy, no built-in list: the screen will say so.
      expect(store.faq, isNull);
      dir.deleteSync(recursive: true);
    });

    test('a failed fetch keeps the last good content', () async {
      final dir = _tempDir();
      final api = _FakeApi({
        'topics': {
          'orgs': [
            {
              'name': {'uz': 'Ijtimoiy himoya'},
              'issues': [
                {
                  'title': {'uz': 'Nafaqa'},
                  'answer': {'uz': 'Qonun asosida ...'},
                },
              ],
            },
          ],
        },
      });
      final store = ContentStore(api: api, cacheDir: dir);
      await store.refresh();
      expect(store.topics?.orgs, hasLength(1));

      // The network drops on the next cycle.
      api.payloads['topics'] = Exception('network down');
      await store.refresh();

      expect(
        store.topics?.orgs,
        hasLength(1),
        reason: 'a dropped connection is not an empty section',
      );
      dir.deleteSync(recursive: true);
    });

    test('content survives a restart through the disk cache', () async {
      final dir = _tempDir();
      final payload = {
        'reception': {
          'steps': [
            {'uz': 'Xodimga murojaat qiling.'},
          ],
          'docs': [
            {'uz': 'Pasport.'},
          ],
        },
      };

      final first = ContentStore(api: _FakeApi(payload), cacheDir: dir);
      await first.refresh();
      expect(first.reception?.steps, hasLength(1));
      first.dispose();

      // A kiosk that reboots with the network still down must come back with
      // its content, not with an apology.
      final offline = _FakeApi({'reception': Exception('no network')});
      final second = ContentStore(api: offline, cacheDir: dir);
      await second.start();

      expect(
        second.reception?.steps.first[Lang.uz],
        'Xodimga murojaat qiling.',
      );
      expect(second.ready, isTrue);
      second.dispose();
      dir.deleteSync(recursive: true);
    });

    test('one malformed section does not cost the others', () async {
      final dir = _tempDir();
      final store = ContentStore(
        api: _FakeApi({
          // `orgs` should be a list; the admin panel wrote an object.
          'topics': {'orgs': 'buzilgan'},
          'faq': {
            'items': [
              {
                'question': {'uz': 'Savol?'},
                'answer': {'uz': 'Javob.'},
              },
            ],
          },
        }),
        cacheDir: dir,
      );

      await store.refresh();

      expect(store.topics?.isEmpty ?? true, isTrue);
      expect(store.faq?.items, hasLength(1));
      dir.deleteSync(recursive: true);
    });

    test('every section the kiosk needs is asked for', () async {
      final dir = _tempDir();
      final api = _FakeApi({});
      final store = ContentStore(api: api, cacheDir: dir);

      await store.refresh();

      expect(
        api.asked,
        containsAll(<String>[
          'sections',
          'config',
          'reception',
          'reception-schedule',
          'faq',
          'topics',
          'mobile-schedule',
          'services',
        ]),
      );
      dir.deleteSync(recursive: true);
    });
  });

  group('envelope', () {
    test('the payload is read from data, and from the top level', () {
      expect(
        KioskContentApi.payloadOf(const {
          'section': 'faq',
          'version': 2,
          'data': {'items': []},
        }),
        const {'items': []},
      );
      expect(
        KioskContentApi.payloadOf(const {
          'section': 'faq',
          'version': 2,
          'items': [],
        }),
        const {'items': []},
      );
      expect(
        KioskContentApi.payloadOf(const {'section': 'faq', 'data': null}),
        isNull,
      );
    });
  });
}
