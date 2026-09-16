// Loads every content section from the live backend, exactly as the kiosk
// does, and prints what a visitor would see. Use it after a seed to confirm
// the kiosk can read what the admin panel published.
//
//   flutter test tool/content_probe.dart
//
// (a test, not a `dart run` script, because the parsing pulls in Material
// icons — see tool/export_seed.dart for the same reason.)
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/config.dart';
import 'package:info_kiosk/src/data.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/services/content_store.dart';

void main() {
  test('live content loads and parses', () async {
    stdout.writeln('Backend: ${KioskConfig.apiBase}\n');

    // A throwaway cache: this probe must report what the *server* holds, not
    // what an earlier run left on disk.
    final dir = Directory.systemTemp.createTempSync('info_kiosk_probe');
    final store = ContentStore(api: null, cacheDir: dir);
    await store.refresh();

    String mark(bool ok) => ok ? 'OK  ' : 'BO\'SH';

    stdout.writeln(
      '${mark(store.cards.isNotEmpty)}  sections         '
      '${store.cards.length} karta',
    );
    stdout.writeln(
      '${mark(store.office != null)}  config           '
      '${store.office?.fullName[Lang.uz] ?? '-'}',
    );
    stdout.writeln(
      '${mark(store.reception?.isEmpty == false)}  reception        '
      '${store.reception?.steps.length ?? 0} bosqich, '
      '${store.reception?.docs.length ?? 0} hujjat, '
      'izoh: ${(store.reception?.note[Lang.uz] ?? '').isEmpty ? 'yo\'q' : 'bor'}',
    );
    stdout.writeln(
      '${mark(store.officials?.isEmpty == false)}  '
      'reception-schedule  ${store.officials?.officials.length ?? 0} mansabdor',
    );
    stdout.writeln(
      '${mark(store.faq?.isEmpty == false)}  faq              '
      '${store.faq?.items.length ?? 0} savol, '
      '${store.faq?.chips.length ?? 0} chip',
    );
    stdout.writeln(
      '${mark(store.topics?.isEmpty == false)}  topics           '
      '${store.topics?.orgs.length ?? 0} yo\'nalish, '
      '${store.topics?.orgs.fold<int>(0, (n, o) => n + o.masalalar.length) ?? 0} masala',
    );
    stdout.writeln(
      '${mark(store.mobileSchedule?.isEmpty == false)}  '
      'mobile-schedule  ${store.mobileSchedule?.orgs.length ?? 0} tashkilot, '
      '${store.mobileSchedule?.orgs.fold<int>(0, (n, o) => n + o.visits.length) ?? 0} tashrif',
    );
    stdout.writeln(
      '${mark(store.services.isNotEmpty)}  services         '
      '${store.services.length} xizmat',
    );
    final hokim = store.hokim;
    final at = hokim?.at;
    stdout.writeln(
      '${mark(at != null)}  reception-points hokim: '
      '${hokim == null ? 'nuqta topilmadi' : at == null ? 'vaqt belgilanmagan' : '${AppData.receptionDate(at, Lang.uz)} '
          '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}'
          ' · ${hokim.location}'}',
    );
    final shown = store.officialsShown?.officials ?? const [];
    final governor = shown.where(isHokimOfficial).firstOrNull;
    stdout.writeln(
      '      hokim kartasi: ${governor == null ? '-' : '${governor.day[Lang.uz]} ${governor.time}'}',
    );

    stdout.writeln('\nlaw_ref: ${store.office?.lawRef[Lang.uz] ?? '-'}');
    if (store.cards.isNotEmpty) {
      stdout.writeln(
        'kartalar: '
        '${store.cards.map((c) => c.title[Lang.uz]).join(' · ')}',
      );
    }

    store.dispose();
    dir.deleteSync(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
