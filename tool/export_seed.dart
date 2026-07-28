// Exports every piece of content the kiosk currently carries in its own code
// (AppData, MasalalarData, SayyorData, KioskConfig, Tr) as:
//
//   1. backend seed JSON — one file per `/kiosk/info/*` section, in the shape
//      agreed in the docs vault (API 20), ready to import straight into
//      `kiosk_info.payload`;
//   2. a full markdown dump for the docs vault, so the content can be read and
//      reviewed without opening Dart files.
//
// Everything is written into the vault, next to the backend request docs:
//   ../Projects-FinTech/01_Projects/qabulhona/02 - API/
//       24 - Info Kiosk mock kontent (seed manbasi)/
//
// Run (needs the Flutter test harness because the data files import Material
// for their icons — a plain `dart run` cannot load `dart:ui`):
//
//   flutter test tool/export_seed.dart
//
// Regenerate after ANY content change; never hand-edit the generated files.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/config.dart';
import 'package:info_kiosk/src/data.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/masalalar_data.dart';
import 'package:info_kiosk/src/sayyor_data.dart';

/// Vault folder the export lands in, relative to the project root.
const String outDir = '../Projects-FinTech/01_Projects/qabulhona/'
    '02 - API/24 - Info Kiosk mock kontent (seed manbasi)';

const String jsonDir = '$outDir/json';

/// Icon key sent by the backend ↔ the Material icon the kiosk draws.
///
/// The backend never sends a code point — it sends this stable key, and the
/// kiosk maps it back. Keys are the Material names without the `_outlined`
/// suffix, which is what API 20 documents.
final Map<int, String> iconKeys = {
  Icons.account_balance_outlined.codePoint: 'account_balance',
  Icons.account_balance_wallet_outlined.codePoint: 'account_balance_wallet',
  Icons.apartment.codePoint: 'apartment',
  Icons.assignment_outlined.codePoint: 'assignment',
  Icons.assignment_turned_in_outlined.codePoint: 'assignment_turned_in',
  Icons.balance.codePoint: 'balance',
  Icons.bolt.codePoint: 'bolt',
  Icons.call_outlined.codePoint: 'call',
  Icons.directions_bus_outlined.codePoint: 'directions_bus',
  Icons.diversity_3_outlined.codePoint: 'diversity_3',
  Icons.edit_road.codePoint: 'edit_road',
  Icons.gavel.codePoint: 'gavel',
  Icons.health_and_safety_outlined.codePoint: 'health_and_safety',
  Icons.help_outline.codePoint: 'help',
  Icons.holiday_village_outlined.codePoint: 'holiday_village',
  Icons.home_work_outlined.codePoint: 'home_work',
  Icons.layers_outlined.codePoint: 'layers',
  Icons.local_fire_department_outlined.codePoint: 'local_fire_department',
  Icons.local_hospital_outlined.codePoint: 'local_hospital',
  Icons.local_police_outlined.codePoint: 'local_police',
  Icons.location_city_outlined.codePoint: 'location_city',
  Icons.map_outlined.codePoint: 'map',
  Icons.park_outlined.codePoint: 'park',
  Icons.payments_outlined.codePoint: 'payments',
  Icons.pets_outlined.codePoint: 'pets',
  Icons.receipt_long_outlined.codePoint: 'receipt_long',
  Icons.savings_outlined.codePoint: 'savings',
  Icons.schedule_outlined.codePoint: 'schedule',
  Icons.school_outlined.codePoint: 'school',
  Icons.smart_toy_outlined.codePoint: 'smart_toy',
  Icons.sports_soccer.codePoint: 'sports_soccer',
  Icons.theater_comedy_outlined.codePoint: 'theater_comedy',
  Icons.thermostat.codePoint: 'thermostat',
  Icons.travel_explore.codePoint: 'travel_explore',
  Icons.volunteer_activism_outlined.codePoint: 'volunteer_activism',
  Icons.water_drop_outlined.codePoint: 'water_drop',
  Icons.work_outline.codePoint: 'work',
};

String iconKey(IconData i) => iconKeys[i.codePoint] ?? 'help';

/// `{uz, ru, en}` — the language object every translated field uses.
Map<String, String> tri(Map<Lang, String> m) => {
      'uz': m[Lang.uz] ?? '',
      'ru': m[Lang.ru] ?? '',
      'en': m[Lang.en] ?? '',
    };

/// Same, for a value produced per language by a function (l10n getters).
Map<String, String> triOf(String Function(Lang) f) => {
      'uz': f(Lang.uz),
      'ru': f(Lang.ru),
      'en': f(Lang.en),
    };

/// Turns three parallel per-language lists into a list of language objects.
List<Map<String, String>> triList(Map<Lang, List<String>> m) {
  final uz = m[Lang.uz]!, ru = m[Lang.ru]!, en = m[Lang.en]!;
  return [
    for (var i = 0; i < uz.length; i++)
      {'uz': uz[i], 'ru': i < ru.length ? ru[i] : '', 'en': i < en.length ? en[i] : ''}
  ];
}

/// Weekday number (1 = Monday) parsed from the Uzbek reception-day label.
int dayOfWeek(String uz) {
  const days = ['dushanba', 'seshanba', 'chorshanba', 'payshanba', 'juma', 'shanba', 'yakshanba'];
  final l = uz.toLowerCase();
  for (var i = 0; i < days.length; i++) {
    if (l.contains(days[i])) return i + 1;
  }
  return 0;
}

/// `dd.mm.yyyy` → ISO `yyyy-mm-dd`. A bare month name ('Iyul') becomes the
/// first day of that month; the caller keeps the original as `date_label`.
String isoDate(String d) {
  final m = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(d);
  if (m != null) return '${m[3]}-${m[2]}-${m[1]}';
  const months = {'Iyul': '07', 'Avgust': '08', 'Sentabr': '09'};
  final mm = months[d];
  return mm == null ? '' : '2026-$mm-01';
}

bool isMonthOnly(String d) => !RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(d);

String pretty(Object o) => const JsonEncoder.withIndent('  ').convert(o);

void writeFile(String path, String content) {
  final f = File(path);
  f.parent.createSync(recursive: true);
  f.writeAsStringSync(content, flush: true);
  stdout.writeln('  ${f.path}  (${content.length} belgi)');
}

/// Escapes a value for a markdown table cell.
String cell(String s) => s.replaceAll('|', r'\|').replaceAll('\n', ' ');

void main() {
  test('export kiosk content as backend seed + vault markdown', () {
    Directory(jsonDir).createSync(recursive: true);

    // ---- 1. config -------------------------------------------------------
    final config = {
      'org_full_name': triOf((l) => Tr(l).orgFullName),
      'org_short_name': tri(KioskConfig.orgShortName),
      'address': tri(KioskConfig.orgAddress),
      'phone': KioskConfig.orgPhone,
      'trust_phone': KioskConfig.trustPhone,
      'work_hours': triOf((l) => Tr(l).hoursValue),
      'law_ref': triOf((l) => Tr(l).lawRef),
      'location': {'lat': KioskConfig.orgLat, 'lon': KioskConfig.orgLon},
      'idle_seconds': KioskConfig.idleSeconds,
    };

    // ---- 2. sections -----------------------------------------------------
    final sections = {
      'items': [
        for (var i = 0; i < AppData.cards.length; i++)
          {
            'key': AppData.cards[i].id.name,
            'icon': iconKey(AppData.cards[i].icon),
            'sort_order': i + 1,
            'is_active': true,
            'title': tri(AppData.cards[i].title),
            'desc': tri(AppData.cards[i].desc),
          }
      ]
    };

    // ---- 3. reception ----------------------------------------------------
    final reception = {
      'steps': triList(AppData.qabulSteps),
      'docs': triList(AppData.qabulDocs),
      'note': triOf((l) => Tr(l).qabulNote),
    };

    // ---- 4. officials (shaxsiy qabul) ------------------------------------
    final officials = {
      'intro': triOf((l) => Tr(l).shaxsiyIntro),
      'note': triOf((l) => Tr(l).shaxsiyNote),
      'officials': [
        for (var i = 0; i < AppData.shaxsiyQabul.length; i++)
          {
            'id': i + 1,
            'sort_order': i + 1,
            'full_name': tri(AppData.shaxsiyQabul[i].name),
            'position': tri(AppData.shaxsiyQabul[i].position),
            'reception_day': tri(AppData.shaxsiyQabul[i].day),
            'day_of_week': dayOfWeek(AppData.shaxsiyQabul[i].day[Lang.uz] ?? ''),
            'time': AppData.shaxsiyQabul[i].time,
            'phone': AppData.shaxsiyQabul[i].phone,
            'is_active': true,
          }
      ],
    };

    // ---- 5. mobile-schedule (sayyor qabul) -------------------------------
    var visitCount = 0;
    final mobileSchedule = {
      'period': {
        'uz': '2026 yil, 3-chorak (iyul–sentabr)',
        'ru': '2026 год, 3 квартал (июль–сентябрь)',
        'en': 'Q3 2026 (July–September)',
      },
      'orgs': [
        for (var i = 0; i < SayyorData.orgs.length; i++)
          {
            'id': i + 1,
            'sort_order': i + 1,
            'icon': iconKey(SayyorData.orgs[i].icon),
            'name': tri(SayyorData.orgs[i].name),
            'visits': [
              for (final v in SayyorData.orgs[i].visits)
                {
                  'date': isoDate(v.date),
                  if (isMonthOnly(v.date))
                    'date_label': {
                      'uz': SayyorData.localizeDate(v.date, Lang.uz),
                      'ru': SayyorData.localizeDate(v.date, Lang.ru),
                      'en': SayyorData.localizeDate(v.date, Lang.en),
                    },
                  'region': {'uz': v.region, 'ru': v.regionRu, 'en': v.region},
                  'place': {'uz': v.place, 'ru': v.placeRu, 'en': v.place},
                }
            ],
          }
      ],
    };
    for (final o in SayyorData.orgs) {
      visitCount += o.visits.length;
    }

    // ---- 6. topics (masalalar + huquqiy javoblar) ------------------------
    var issueCount = 0;
    final topics = {
      'period': tri(MasalalarData.period),
      'general_notes': triList(MasalalarData.umumiyIzoh),
      'orgs': [
        for (var i = 0; i < MasalalarData.tashkilotlar.length; i++)
          {
            'id': i + 1,
            'sort_order': i + 1,
            'icon': iconKey(MasalalarData.tashkilotlar[i].icon),
            'name': tri(MasalalarData.tashkilotlar[i].name),
            'issues': [
              for (var j = 0; j < MasalalarData.tashkilotlar[i].masalalar.length; j++)
                {
                  'id': j + 1,
                  'sort_order': j + 1,
                  'title': tri(MasalalarData.tashkilotlar[i].masalalar[j].title),
                  'answer': tri(MasalalarData.tashkilotlar[i].masalalar[j].answer),
                }
            ],
          }
      ],
    };
    for (final o in MasalalarData.tashkilotlar) {
      issueCount += o.masalalar.length;
    }

    // ---- 7. faq ----------------------------------------------------------
    final faqUz = AppData.faq[Lang.uz]!,
        faqRu = AppData.faq[Lang.ru]!,
        faqEn = AppData.faq[Lang.en]!;
    final faq = {
      'items': [
        for (var i = 0; i < faqUz.length; i++)
          {
            'id': i + 1,
            'sort_order': i + 1,
            'question': {'uz': faqUz[i][0], 'ru': faqRu[i][0], 'en': faqEn[i][0]},
            'answer': {'uz': faqUz[i][1], 'ru': faqRu[i][1], 'en': faqEn[i][1]},
          }
      ],
      'chips': triList(AppData.chips),
    };

    // ---- 8. services (AI bilim bazasi) -----------------------------------
    final svcUz = AppData.xizmatlar[Lang.uz]!,
        svcRu = AppData.xizmatlar[Lang.ru]!,
        svcEn = AppData.xizmatlar[Lang.en]!;
    final services = {
      'items': [
        for (var i = 0; i < svcUz.length; i++)
          {
            'id': i + 1,
            'sort_order': i + 1,
            'title': {'uz': svcUz[i][0], 'ru': svcRu[i][0], 'en': svcEn[i][0]},
            'desc': {'uz': svcUz[i][1], 'ru': svcRu[i][1], 'en': svcEn[i][1]},
          }
      ],
    };

    // ---- write the JSON seed --------------------------------------------
    stdout.writeln('JSON seed:');
    final payloads = <String, Object>{
      'config': config,
      'sections': sections,
      'reception': reception,
      'officials': officials,
      'mobile-schedule': mobileSchedule,
      'topics': topics,
      'faq': faq,
      'services': services,
    };
    payloads.forEach((section, payload) {
      writeFile('$jsonDir/$section.json', '${pretty(payload)}\n');
    });

    // ---- write the markdown dump ----------------------------------------
    stdout.writeln('Markdown:');
    writeFile('$outDir/00 - Ro\'yxat.md', indexMd(visitCount, issueCount));
    writeFile('$outDir/01 - Config va bosh sahifa (config, sections).md',
        configMd(config, sections));
    writeFile('$outDir/02 - Qabul tartibi (reception).md', receptionMd());
    writeFile('$outDir/03 - Shaxsiy qabul (officials).md', officialsMd());
    writeFile('$outDir/04 - FAQ, chiplar va xizmatlar (faq, services).md', faqMd());
    writeFile('$outDir/05 - Masalalar va huquqiy javoblar (topics).md',
        topicsMd(issueCount));
    writeFile('$outDir/06 - Sayyor qabul jadvali (mobile-schedule).md',
        sayyorMd(visitCount));
    writeFile('$outDir/07 - Ilovada qolgan matnlar (l10n).md', l10nMd());

    stdout.writeln('Tayyor: 8 JSON + 8 markdown, '
        '$issueCount masala, $visitCount sayyor tashrif.');
  });
}

// ---------------------------------------------------------------------------
// Markdown builders. Each file opens with the same "generated" banner so a
// reader always knows to edit the source, not the dump.
// ---------------------------------------------------------------------------

const String banner = '> ⚠️ **Avtomatik yaratilgan** — `info_kiosk/tool/export_seed.dart` '
    '(`flutter test tool/export_seed.dart`). Qo\'lда tahrirlamang: manba ilova kodida.';

String header(String title, String source) => '# $title\n\n'
    '$banner\n>\n'
    '> **Manba:** `$source`\n'
    '> **Bog\'liq:** [[00 - Ro\'yxat]] · '
    '[[../24 - Info Kiosk — API tahlili va seed vazifasi (DevOps)|24 - API tahlili]]\n\n---\n\n';

String indexMd(int visits, int issues) => '''
# Info Kiosk — mock kontent (seed manbasi)

$banner

`info_kiosk` (Xalq qabulxonasi axborot kioski) ichida **qattiq yozilgan** (hardcoded)
butun kontent shu papkaga eksport qilingan: backend `/kiosk/info/*` bo'limlarini
**seed** qilish uchun tayyor JSON + o'qish uchun markdown.

> **Nima uchun:** kiosk hozir kontentni koddan oladi. Backendда `kiosk_info`
> bo'limlari bo'sh — ular shu ma'lumot bilan to'ldirilsa, kiosk keyingi bosqichда
> backenddan ishlay boshlaydi. Vazifa: [[../24 - Info Kiosk — API tahlili va seed vazifasi (DevOps)|24 - API tahlili va seed vazifasi]].

---

## 📄 Hujjatlar

| # | Fayl | Bo'lim | Hajm |
|---|------|--------|------|
| 01 | [[01 - Config va bosh sahifa (config, sections)]] | `config`, `sections` | 1 obyekt + 6 karta |
| 02 | [[02 - Qabul tartibi (reception)]] | `reception` | 4 bosqich + 4 hujjat + izoh |
| 03 | [[03 - Shaxsiy qabul (officials)]] | `reception-schedule` | 9 mansabdor |
| 04 | [[04 - FAQ, chiplar va xizmatlar (faq, services)]] | `faq`, `services` | 6 + 4 + 6 |
| 05 | [[05 - Masalalar va huquqiy javoblar (topics)]] | `topics` | 15 yo'nalish, $issues masala |
| 06 | [[06 - Sayyor qabul jadvali (mobile-schedule)]] | `mobile-schedule` | 32 tashkilot, $visits tashrif |
| 07 | [[07 - Ilovada qolgan matnlar (l10n)]] | — (interfeys matnlari) | qaror kerak |

---

## 📦 Seed JSON (`json/`)

Har fayl — bitta bo'limning **`data` payload'i** (jonli javob `{"section":…,"version":…,"data":{…}}`
ichidagi `data` qismi). To'g'ridan-to'g'ri `kiosk_info.payload` ga yoziladi yoki
backend'ning `app/seed_data/kiosk_info/` papkasiga ko'chiriladi.

| Fayl | Endpoint | Holat (2026-07-28) |
|------|----------|--------------------|
| `json/config.json` | `GET /kiosk/info/config` | ✅ backendда bor (version 1) |
| `json/sections.json` | `GET /kiosk/info/sections` | ✅ backendда bor (version 1) |
| `json/reception.json` | `GET /kiosk/info/reception` | ✅ backendда bor (version 1) — `note` qo'shilsin |
| `json/officials.json` | `GET /kiosk/reception-schedule` | 🔴 endpoint **404** |
| `json/mobile-schedule.json` | `GET /kiosk/info/mobile-schedule` | 🟡 `data: null` — **seed kerak** |
| `json/topics.json` | `GET /kiosk/info/topics` | 🟡 `data: null` — **seed kerak** |
| `json/faq.json` | `GET /kiosk/info/faq` | 🟡 `data: null` — **seed kerak** |
| `json/services.json` | `GET /kiosk/info/services` | 🟡 `data: null` — **seed kerak** |

---

## 🔄 Qayta yaratish

```bash
cd C:/flutter_projects/info_kiosk
flutter test tool/export_seed.dart
```

Kontent kodda o'zgarsa — shu buyruq qayta ishga tushirilsin, JSON va markdown
birga yangilanadi.

---

## 🔗 Bog'liq
- [[../24 - Info Kiosk — API tahlili va seed vazifasi (DevOps)|24 - API tahlili va seed vazifasi (DevOps/Backend)]]
- [[../20 - Info Kiosk kontent (Home + ichki bo'limlar) — Backend so'rovi|20 - Shartnoma (JSON shakllari)]]
- [[../22 - Info Kiosk kontent — jonli holat va seed vazifasi (Backend so'rovi)|22 - Jonli holat]]
- [[../18 - Shaxsiy qabul jadvali — Backend so'rovi|18 - Shaxsiy qabul shakli]]
''';

String configMd(Map<String, Object?> config, Map<String, Object?> sections) {
  final b = StringBuffer(header('01 — Config va bosh sahifa', 'lib/src/config.dart, lib/src/data.dart → cards, lib/src/l10n.dart'));

  b.writeln('## 1️⃣ `config` — idora ma\'lumoti\n');
  b.writeln('| Maydon | uz | ru | en |');
  b.writeln('|--------|----|----|----|');
  for (final k in ['org_full_name', 'org_short_name', 'address', 'work_hours', 'law_ref']) {
    final v = (config[k] as Map).cast<String, String>();
    b.writeln('| `$k` | ${cell(v['uz']!)} | ${cell(v['ru']!)} | ${cell(v['en']!)} |');
  }
  b.writeln('\n| Maydon | Qiymat | Izoh |');
  b.writeln('|--------|--------|------|');
  b.writeln('| `phone` | ${config['phone']} | Qabulxona telefoni |');
  b.writeln('| `trust_phone` | ${config['trust_phone']} | Ishonch telefoni |');
  final loc = (config['location'] as Map).cast<String, Object>();
  b.writeln('| `location` | lat ${loc['lat']}, lon ${loc['lon']} | Kontakt ekranidagi xarita nuqtasi |');
  b.writeln('| `idle_seconds` | ${config['idle_seconds']} | Bo\'sh turganda bosh sahifaga qaytish (soniya) |');
  b.writeln('\n> Xarita rasmi (`assets/images/office_map.png`) — offline OSM tayl, **ilovada qoladi**.');
  b.writeln('> Chiqish paroli (`KioskConfig.exitPassword`) — **ilovada qoladi**, backendга yuborilmaydi.\n');

  b.writeln('---\n\n## 2️⃣ `sections` — bosh sahifa kartalari (6 ta)\n');
  b.writeln('| # | `key` | `icon` | Sarlavha (uz) | Sarlavha (ru) | Sarlavha (en) |');
  b.writeln('|---|-------|--------|---------------|---------------|---------------|');
  for (final it in (sections['items'] as List).cast<Map<String, Object?>>()) {
    final t = (it['title'] as Map).cast<String, String>();
    b.writeln('| ${it['sort_order']} | `${it['key']}` | `${it['icon']}` | '
        '${cell(t['uz']!)} | ${cell(t['ru']!)} | ${cell(t['en']!)} |');
  }
  b.writeln('\n**Tavsiflar (`desc`):**\n');
  b.writeln('| `key` | uz | ru | en |');
  b.writeln('|-------|----|----|----|');
  for (final it in (sections['items'] as List).cast<Map<String, Object?>>()) {
    final d = (it['desc'] as Map).cast<String, String>();
    b.writeln('| `${it['key']}` | ${cell(d['uz']!)} | ${cell(d['ru']!)} | ${cell(d['en']!)} |');
  }
  b.writeln('\n> ⚠️ `key` — **belgilangan ro\'yxat**: `qabul` · `jadval` · `masalalar` · `faq` · `ai` · `contact`.');
  b.writeln('> Kiosk faqat tanigan `key` ni ko\'rsatadi; noma\'lum `key` jim tashlanadi.');
  return b.toString();
}

String receptionMd() {
  final b = StringBuffer(header('02 — Qabul tartibi (`reception`)', 'lib/src/data.dart → qabulSteps, qabulDocs; l10n → qabulNote'));
  b.writeln('## Bosqichlar (`steps`) — 4 ta\n');
  b.writeln('| # | uz | ru | en |');
  b.writeln('|---|----|----|----|');
  final steps = triList(AppData.qabulSteps);
  for (var i = 0; i < steps.length; i++) {
    b.writeln('| ${i + 1} | ${cell(steps[i]['uz']!)} | ${cell(steps[i]['ru']!)} | ${cell(steps[i]['en']!)} |');
  }
  b.writeln('\n## Kerakli hujjatlar (`docs`) — 4 ta\n');
  b.writeln('| # | uz | ru | en |');
  b.writeln('|---|----|----|----|');
  final docs = triList(AppData.qabulDocs);
  for (var i = 0; i < docs.length; i++) {
    b.writeln('| ${i + 1} | ${cell(docs[i]['uz']!)} | ${cell(docs[i]['ru']!)} | ${cell(docs[i]['en']!)} |');
  }
  b.writeln('\n## Ogohlantirish izohi (`note`)\n');
  b.writeln('> ⚠️ Hozir bu matn **ilovada** (`l10n → qabulNote`), backend shartnomasida yo\'q edi.');
  b.writeln('> Seed JSON\'ga `note` sifatida qo\'shildi — `reception` bo\'limiga kiritilsin.\n');
  for (final l in Lang.values) {
    b.writeln('### ${l.name}\n');
    b.writeln('```text\n${Tr(l).qabulNote}\n```\n');
  }
  return b.toString();
}

String officialsMd() {
  final b = StringBuffer(header('03 — Shaxsiy qabul (`officials`)', 'lib/src/data.dart → shaxsiyQabul; l10n → shaxsiyIntro, shaxsiyNote'));
  b.writeln('> 🔴 Endpoint `GET /kiosk/reception-schedule` jonli **404** qaytaradi (2026-07-28).');
  b.writeln('> Shakl [[../18 - Shaxsiy qabul jadvali — Backend so\'rovi|API 18]] dagi bilan bir xil.\n');
  b.writeln('## 9 mansabdor\n');
  b.writeln('| # | F.I.Sh. (uz) | F.I.Sh. (ru) | Lavozim (uz) | Qabul kuni | `day_of_week` | Vaqt | Telefon |');
  b.writeln('|---|--------------|--------------|--------------|------------|---------------|------|---------|');
  for (var i = 0; i < AppData.shaxsiyQabul.length; i++) {
    final o = AppData.shaxsiyQabul[i];
    b.writeln('| ${i + 1} | ${cell(o.name[Lang.uz]!)} | ${cell(o.name[Lang.ru]!)} | '
        '${cell(o.position[Lang.uz]!)} | ${cell(o.day[Lang.uz]!)} | '
        '${dayOfWeek(o.day[Lang.uz]!)} | ${o.time} | ${o.phone} |');
  }
  b.writeln('\n### Lavozimlar — ru va en\n');
  b.writeln('| # | Lavozim (ru) | Lavozim (en) |');
  b.writeln('|---|--------------|--------------|');
  for (var i = 0; i < AppData.shaxsiyQabul.length; i++) {
    final o = AppData.shaxsiyQabul[i];
    b.writeln('| ${i + 1} | ${cell(o.position[Lang.ru]!)} | ${cell(o.position[Lang.en]!)} |');
  }
  b.writeln('\n## Ekran matnlari\n');
  b.writeln('| Maydon | uz | ru | en |');
  b.writeln('|--------|----|----|----|');
  b.writeln('| `intro` | ${cell(Tr(Lang.uz).shaxsiyIntro)} | ${cell(Tr(Lang.ru).shaxsiyIntro)} | ${cell(Tr(Lang.en).shaxsiyIntro)} |');
  b.writeln('| `note` | ${cell(Tr(Lang.uz).shaxsiyNote)} | ${cell(Tr(Lang.ru).shaxsiyNote)} | ${cell(Tr(Lang.en).shaxsiyNote)} |');
  return b.toString();
}

String faqMd() {
  final b = StringBuffer(header('04 — FAQ, chiplar va xizmatlar', 'lib/src/data.dart → faq, chips, xizmatlar'));
  b.writeln('## 1️⃣ `faq` — savol-javob (6 ta)\n');
  final fu = AppData.faq[Lang.uz]!, fr = AppData.faq[Lang.ru]!, fe = AppData.faq[Lang.en]!;
  for (var i = 0; i < fu.length; i++) {
    b.writeln('### ${i + 1}. ${fu[i][0]}\n');
    b.writeln('| Til | Savol | Javob |');
    b.writeln('|-----|-------|-------|');
    b.writeln('| uz | ${cell(fu[i][0])} | ${cell(fu[i][1])} |');
    b.writeln('| ru | ${cell(fr[i][0])} | ${cell(fr[i][1])} |');
    b.writeln('| en | ${cell(fe[i][0])} | ${cell(fe[i][1])} |');
    b.writeln('');
  }
  b.writeln('---\n\n## 2️⃣ `chips` — AI ekranidagi tayyor savollar (4 ta)\n');
  b.writeln('| # | uz | ru | en |');
  b.writeln('|---|----|----|----|');
  final chips = triList(AppData.chips);
  for (var i = 0; i < chips.length; i++) {
    b.writeln('| ${i + 1} | ${cell(chips[i]['uz']!)} | ${cell(chips[i]['ru']!)} | ${cell(chips[i]['en']!)} |');
  }
  b.writeln('\n---\n\n## 3️⃣ `services` — xizmatlar (6 ta, ekranда ko\'rinmaydi)\n');
  b.writeln('> Bosh sahifada karta yo\'q — bu ro\'yxat faqat **oflayn AI maslahatchi**ning');
  b.writeln('> bilim bazasi (`ai_responder.dart` FAQ + xizmatlar ustidan qidiradi).\n');
  final su = AppData.xizmatlar[Lang.uz]!, sr = AppData.xizmatlar[Lang.ru]!, se = AppData.xizmatlar[Lang.en]!;
  b.writeln('| # | Nomi (uz) | Tavsif (uz) | Nomi (ru) | Nomi (en) |');
  b.writeln('|---|-----------|-------------|-----------|-----------|');
  for (var i = 0; i < su.length; i++) {
    b.writeln('| ${i + 1} | ${cell(su[i][0])} | ${cell(su[i][1])} | ${cell(sr[i][0])} | ${cell(se[i][0])} |');
  }
  b.writeln('\n**Tavsiflar — ru va en:**\n');
  b.writeln('| # | Tavsif (ru) | Tavsif (en) |');
  b.writeln('|---|-------------|-------------|');
  for (var i = 0; i < su.length; i++) {
    b.writeln('| ${i + 1} | ${cell(sr[i][1])} | ${cell(se[i][1])} |');
  }
  return b.toString();
}

String topicsMd(int issues) {
  final b = StringBuffer(header('05 — Masalalar va huquqiy javoblar (`topics`)', 'lib/src/masalalar_data.dart'));
  b.writeln('**Davr:** ${MasalalarData.period[Lang.uz]} · '
      '**${MasalalarData.tashkilotlar.length} yo\'nalish** · **$issues masala** · har biri 3 tilда\n');
  b.writeln('> Eng katta bo\'lim. Har masalaning javobi — qonun havolalari bilan to\'liq matn.\n');
  b.writeln('## Yo\'nalishlar ro\'yxati\n');
  b.writeln('| # | `icon` | Nomi (uz) | Nomi (ru) | Masala |');
  b.writeln('|---|--------|-----------|-----------|--------|');
  for (var i = 0; i < MasalalarData.tashkilotlar.length; i++) {
    final o = MasalalarData.tashkilotlar[i];
    b.writeln('| ${i + 1} | `${iconKey(o.icon)}` | ${cell(o.name[Lang.uz]!)} | '
        '${cell(o.name[Lang.ru]!)} | ${o.masalalar.length} |');
  }
  b.writeln('\n---\n');
  for (var i = 0; i < MasalalarData.tashkilotlar.length; i++) {
    final o = MasalalarData.tashkilotlar[i];
    b.writeln('## ${i + 1}. ${o.name[Lang.uz]}\n');
    b.writeln('*ru:* ${o.name[Lang.ru]} · *en:* ${o.name[Lang.en]} · `icon: ${iconKey(o.icon)}`\n');
    for (var j = 0; j < o.masalalar.length; j++) {
      final m = o.masalalar[j];
      b.writeln('### ${i + 1}.${j + 1} ${m.title[Lang.uz]}\n');
      b.writeln('*ru:* ${m.title[Lang.ru]}  \n*en:* ${m.title[Lang.en]}\n');
      b.writeln('**Javob (uz):** ${m.answer[Lang.uz]}\n');
      b.writeln('**Javob (ru):** ${m.answer[Lang.ru]}\n');
      b.writeln('**Javob (en):** ${m.answer[Lang.en]}\n');
    }
    b.writeln('---\n');
  }
  b.writeln('## Umumiy huquqiy izoh (`general_notes`)\n');
  final notes = triList(MasalalarData.umumiyIzoh);
  for (var i = 0; i < notes.length; i++) {
    b.writeln('${i + 1}. **uz:** ${notes[i]['uz']}');
    b.writeln('   **ru:** ${notes[i]['ru']}');
    b.writeln('   **en:** ${notes[i]['en']}\n');
  }
  return b.toString();
}

String sayyorMd(int visits) {
  final b = StringBuffer(header('06 — Sayyor qabul jadvali (`mobile-schedule`)', 'lib/src/sayyor_data.dart (tool/gen_sayyor_data.dart bilan yaratilgan)'));
  b.writeln('**${SayyorData.orgs.length} tashkilot · $visits tashrif · 2026 yil 3-chorak (iyul–sentabr)**\n');
  b.writeln('> ⭐ **Har chorak to\'liq almashadi** — backendда bo\'lishi eng foydali bo\'lim.');
  b.writeln('> Sana JSON\'да ISO (`YYYY-MM-DD`); manba faqat oy bergan yozuvlarда `date_label` ham bor.\n');
  b.writeln('## Tashkilotlar\n');
  b.writeln('| # | `icon` | Nomi (uz) | Nomi (ru) | Tashrif |');
  b.writeln('|---|--------|-----------|-----------|---------|');
  for (var i = 0; i < SayyorData.orgs.length; i++) {
    final o = SayyorData.orgs[i];
    b.writeln('| ${i + 1} | `${iconKey(o.icon)}` | ${cell(o.name[Lang.uz]!)} | '
        '${cell(o.name[Lang.ru]!)} | ${o.visits.length} |');
  }
  b.writeln('\n---\n');
  for (var i = 0; i < SayyorData.orgs.length; i++) {
    final o = SayyorData.orgs[i];
    b.writeln('## ${i + 1}. ${o.name[Lang.uz]} — ${o.visits.length} tashrif\n');
    b.writeln('| Sana (ISO) | Manba | Tuman/shahar (uz) | Tuman/shahar (ru) | Joy (uz) | Joy (ru) |');
    b.writeln('|------------|-------|-------------------|-------------------|----------|----------|');
    for (final v in o.visits) {
      b.writeln('| ${isoDate(v.date)} | ${v.date} | ${cell(v.region)} | '
          '${cell(v.regionRu)} | ${cell(v.place)} | ${cell(v.placeRu)} |');
    }
    b.writeln('');
  }
  return b.toString();
}

String l10nMd() {
  final b = StringBuffer(header('07 — Ilovada qolgan matnlar (`l10n`)', 'lib/src/l10n.dart'));
  b.writeln('Bu matnlar **interfeys** matnlari — tugma, sarlavha, holat yozuvlari.');
  b.writeln('Ular backendда **bo\'lishi shart emas** (ilova bilan birga o\'zgaradi).');
  b.writeln('Faqat pastdagi ✅ belgilanganlar kontent hisoblanadi va seed JSON\'ga kiritildi.\n');
  b.writeln('| Kalit | Backendga | Qayerga | uz |');
  b.writeln('|-------|-----------|---------|----|');
  final rows = <List<String>>[
    ['orgFullName', '✅', '`config.org_full_name`', Tr(Lang.uz).orgFullName],
    ['hoursValue', '✅', '`config.work_hours`', Tr(Lang.uz).hoursValue],
    ['lawRef', '✅', '`config.law_ref`', Tr(Lang.uz).lawRef],
    ['qabulNote', '✅', '`reception.note`', Tr(Lang.uz).qabulNote],
    ['shaxsiyIntro', '✅', '`officials.intro`', Tr(Lang.uz).shaxsiyIntro],
    ['shaxsiyNote', '✅', '`officials.note`', Tr(Lang.uz).shaxsiyNote],
    ['aiIntro', '⚪ qaror', 'AI ekrani kirish matni', Tr(Lang.uz).aiIntro],
    ['aiOffline', '⚪ qaror', 'AI javob topolmaganda', Tr(Lang.uz).aiOffline],
    ['aiGreetingPrompt', '⚪ qaror', 'Live avatar salomlashuvi', Tr(Lang.uz).aiGreetingPrompt],
    ['masalalarIntro', '❌', 'Interfeys', Tr(Lang.uz).masalalarIntro],
    ['sayyorHint', '❌', 'Interfeys', Tr(Lang.uz).sayyorHint],
    ['homeTitle', '❌', 'Interfeys', Tr(Lang.uz).homeTitle],
    ['footerHint', '❌', 'Interfeys', Tr(Lang.uz).footerHint],
  ];
  for (final r in rows) {
    b.writeln('| `${r[0]}` | ${r[1]} | ${r[2]} | ${cell(r[3])} |');
  }
  b.writeln('\n> Qolgan ~40 kalit (tugma yozuvlari, holat matnlari, oy/hafta nomlari) — sof interfeys, ilovada qoladi.');
  return b.toString();
}
