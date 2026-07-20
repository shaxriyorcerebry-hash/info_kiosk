// Generates lib/src/sayyor_data.dart from the Q3-2026 mobile reception
// schedule in C:/Users/User/Downloads/jadval.md.
import 'dart:io';

const vowels = 'аеёиоуўэюяАЕЁИОУЎЭЮЯ';

const one = {
  'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'ж': 'j', 'з': 'z',
  'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o',
  'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'x',
  'э': 'e', 'ъ': "'", 'ь': '',
  'А': 'A', 'Б': 'B', 'В': 'V', 'Г': 'G', 'Д': 'D', 'Ж': 'J', 'З': 'Z',
  'И': 'I', 'Й': 'Y', 'К': 'K', 'Л': 'L', 'М': 'M', 'Н': 'N', 'О': 'O',
  'П': 'P', 'Р': 'R', 'С': 'S', 'Т': 'T', 'У': 'U', 'Ф': 'F', 'Х': 'X',
  'Э': 'E',
  'ё': 'yo', 'Ё': 'Yo', 'ю': 'yu', 'Ю': 'Yu', 'я': 'ya', 'Я': 'Ya',
  'ц': 'ts', 'Ц': 'Ts', 'ч': 'ch', 'Ч': 'Ch', 'ш': 'sh', 'Ш': 'Sh',
  'щ': 'sh', 'Щ': 'Sh',
  'ў': "o'", 'Ў': "O'", 'қ': 'q', 'Қ': 'Q', 'ғ': "g'", 'Ғ': "G'",
  'ҳ': 'h', 'Ҳ': 'H',
};

String translit(String s) {
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == 'е' || ch == 'Е') {
      final atStart = i == 0 || !RegExp(r'[\p{L}]', unicode: true).hasMatch(s[i - 1]);
      final afterVowelish = i > 0 &&
          (vowels.contains(s[i - 1]) || s[i - 1] == 'ь' || s[i - 1] == 'ъ');
      final ye = atStart || afterVowelish;
      b.write(ch == 'е' ? (ye ? 'ye' : 'e') : (ye ? 'Ye' : 'E'));
    } else {
      b.write(one[ch] ?? ch);
    }
  }
  return b.toString();
}

/// name uz / ru / en / icon, keyed by the Cyrillic org name in the source.
const orgMeta = {
  'Ижтимоий химоя': ["Ijtimoiy himoya", 'Социальная защита', 'Social protection', 'Icons.volunteer_activism_outlined'],
  'Пенсия жамғармаси': ["Pensiya jamg'armasi", 'Пенсионный фонд', 'Pension Fund', 'Icons.savings_outlined'],
  'Молия': ['Moliya', 'Финансы', 'Finance', 'Icons.payments_outlined'],
  'ДСЭНМ': ['DSENM', 'ДСЭНМ', 'Sanitary-epidemiological service', 'Icons.health_and_safety_outlined'],
  'Соғлиқни сақлаш': ["Sog'liqni saqlash", 'Здравоохранение', 'Healthcare', 'Icons.local_hospital_outlined'],
  'Ҳокимият': ['Hokimiyat', 'Хокимият', "Governor's office", 'Icons.apartment'],
  'Солиқ': ['Soliq', 'Налоговая служба', 'Tax service', 'Icons.receipt_long_outlined'],
  'Электр таъминоти': ["Elektr ta'minoti", 'Электроснабжение', 'Electricity supply', 'Icons.bolt'],
  'Прокуратура': ['Prokuratura', 'Прокуратура', "Prosecutor's office", 'Icons.gavel'],
  'Маҳаллалар уюшмаси': ['Mahallalar uyushmasi', 'Ассоциация махаллей', 'Mahalla association', 'Icons.holiday_village_outlined'],
  'Газ таъминоти': ["Gaz ta'minoti", 'Газоснабжение', 'Gas supply', 'Icons.local_fire_department_outlined'],
  'Сув таъминоти': ["Suv ta'minoti", 'Водоснабжение', 'Water supply', 'Icons.water_drop_outlined'],
  'Кадастр агентлиги': ['Kadastr agentligi', 'Кадастровое агентство', 'Cadastre agency', 'Icons.map_outlined'],
  'Маданият': ['Madaniyat', 'Культура', 'Culture', 'Icons.theater_comedy_outlined'],
  'Агробанк': ['Agrobank', 'Агробанк', 'Agrobank', 'Icons.account_balance_outlined'],
  'Ҳотин-қизлар': ['Xotin-qizlar', 'Комитет женщин', "Women's committee", 'Icons.diversity_3_outlined'],
  'Кадастр палатаси': ['Kadastr palatasi', 'Кадастровая палата', 'Cadastre chamber', 'Icons.layers_outlined'],
  'Ободонлаштириш': ['Obodonlashtirish', 'Благоустройство', 'Landscaping service', 'Icons.park_outlined'],
  'Камбағалликни қисқартириш ва бандлик': ["Kambag'allikni qisqartirish va bandlik", 'Сокращение бедности и занятость', 'Poverty reduction and employment', 'Icons.work_outline'],
  'Рақобат': ['Raqobat', 'Комитет по конкуренции', 'Competition committee', 'Icons.balance'],
  'Мажбурий ижро бюроси': ['Majburiy ijro byurosi', 'Бюро принудительного исполнения', 'Compulsory Enforcement Bureau', 'Icons.assignment_turned_in_outlined'],
  'ИИБ': ['IIB', 'ОВД', 'Internal affairs (IIB)', 'Icons.local_police_outlined'],
  'Спорт': ['Sport', 'Спорт', 'Sports', 'Icons.sports_soccer'],
  'Транспорт': ['Transport', 'Транспорт', 'Transport', 'Icons.directions_bus_outlined'],
  'Автойўл': ["Avtoyo'l", 'Автомобильные дороги', 'Highways service', 'Icons.edit_road'],
  'Иссиқлик таъминоти': ["Issiqlik ta'minoti", 'Теплоснабжение', 'Heat supply', 'Icons.thermostat'],
  'Туризм бошқармаси': ['Turizm boshqarmasi', 'Управление туризма', 'Tourism department', 'Icons.travel_explore'],
  'Ветеринария': ['Veterinariya', 'Ветеринария', 'Veterinary service', 'Icons.pets_outlined'],
  'Қурилиш уй-жой коммунал хўжалиги': ["Qurilish va uy-joy kommunal xo'jaligi", 'Строительство и ЖКХ', 'Construction and housing utilities', 'Icons.home_work_outlined'],
  'Халқ банки': ['Xalq banki', 'Народный банк', 'Xalq Bank', 'Icons.account_balance_wallet_outlined'],
  'Чирчиқ давлат тиббиёт университети': ['Chirchiq davlat tibbiyot universiteti', 'Чирчикский государственный медицинский университет', 'Chirchiq State Medical University', 'Icons.school_outlined'],
};

const monthDates = {
  'Июль': 'Iyul',
  'Август': 'Avgust',
  'Сентябрь': 'Sentabr',
};

/// Official Russian names of the districts/cities, applied to the region
/// column and to place values that are themselves a district/city.
const ruRegions = {
  'Ангрен шаҳар': 'город Ангрен',
  'Бекобод тумани': 'Бекабадский район',
  'Бекобод шаҳар': 'город Бекабад',
  'Бўка тумани': 'Букинский район',
  'Бўстонлиқ тумани': 'Бостанлыкский район',
  'Зангиота тумани': 'Зангиатинский район',
  'Нурафшон шаҳар': 'город Нурафшон',
  'Олмалиқ шаҳар': 'город Алмалык',
  'Оққўрғон тумани': 'Аккурганский район',
  'Оҳангарон тумани': 'Ахангаранский район',
  'Оҳангарон шаҳар': 'город Ахангаран',
  'Паркент тумани': 'Паркентский район',
  'Пискент тумани': 'Пскентский район',
  'Тошкент тумани': 'Ташкентский район',
  'Чиноз тумани': 'Чиназский район',
  'Чирчиқ шаҳар': 'город Чирчик',
  'Юқори Чирчиқ тумани': 'Юкоричирчикский район',
  'Янгийўл тумани': 'Янгиюльский район',
  'Янгийўл шаҳри': 'город Янгиюль',
  'Янгийўл шаҳар': 'город Янгиюль',
  'Ўрта Чирчиқ тумани': 'Уртачирчикский район',
  'Қибрай тумани': 'Кибрайский район',
  'Қуйи Чирчиқ тумани': 'Куйичирчикский район',
  'Вилоят ташкилотлари': 'Областные организации',
};

/// Russian display form: mapped district/city name, or the source Cyrillic
/// as-is (MFY names etc.).
String ruify(String cyr) => ruRegions[cyr] ?? cyr;

String esc(String s) => s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll(r'$', r'\$');

int sortKey(String date) {
  // dd.mm.yyyy → yyyymmdd; month-only → first of that month.
  final m = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(date);
  if (m != null) {
    return int.parse(m.group(3)!) * 10000 + int.parse(m.group(2)!) * 100 + int.parse(m.group(1)!);
  }
  const months = {'Iyul': 7, 'Avgust': 8, 'Sentabr': 9};
  return 20260000 + (months[date] ?? 0) * 100;
}

void main() {
  final lines = File('C:/Users/User/Downloads/jadval.md').readAsLinesSync();
  final rows = <List<String>>[];
  for (var line in lines) {
    line = line.trim();
    if (!line.startsWith('|')) continue;
    final c = line
        .substring(1, line.length - (line.endsWith('|') ? 1 : 0))
        .split('|')
        .map((e) => e.trim())
        .toList();
    if (c.length != 4) continue;
    if (c[0].startsWith('Туман') || RegExp(r'^-+$').hasMatch(c[0])) continue;
    rows.add(c);
  }

  // Group rows by organisation, keeping both the transliterated Latin and
  // the original Cyrillic (shown when the kiosk language is Russian):
  // [regionLat, regionCyr, date, placeLat, placeCyr].
  final byOrg = <String, List<List<String>>>{};
  for (final r in rows) {
    var regionCyr = r[0] == 'Қибрай туман' ? 'Қибрай тумани' : r[0]; // typo
    var region = translit(regionCyr);
    var date = monthDates[r[2]] ?? r[2];
    var placeCyr = r[3].replaceAll(' МФЙ МФЙ', ' МФЙ'); // source typo
    var place = translit(placeCyr);
    if (!RegExp(r'^\d').hasMatch(date)) date = monthDates[r[2]] ?? translit(date);
    byOrg
        .putIfAbsent(r[1], () => [])
        .add([region, ruify(regionCyr), date, place, ruify(placeCyr)]);
  }

  // Largest organisations first; visits sorted chronologically.
  final orgNames = byOrg.keys.toList()
    ..sort((a, b) => byOrg[b]!.length.compareTo(byOrg[a]!.length));

  final missing = orgNames.where((o) => !orgMeta.containsKey(o)).toList();
  if (missing.isNotEmpty) {
    stderr.writeln('MISSING ORG META: $missing');
    exit(1);
  }

  final b = StringBuffer();
  b.writeln('''
// GENERATED from the Q3-2026 mobile reception schedule (jadval.md) —
// regenerate with the generator script rather than editing rows by hand.
import 'package:flutter/material.dart';

import 'l10n.dart';

/// One mobile (field) reception stop: the district/city it belongs to, the
/// date and the venue (usually an MFY — citizens' assembly). Place names are
/// carried in Uzbek Latin plus the source's Cyrillic, shown for Russian.
class SayyorVisit {
  const SayyorVisit(
      this.region, this.regionRu, this.date, this.place, this.placeRu);

  final String region;
  final String regionRu;

  /// `dd.mm.yyyy`, or an Uzbek month name ('Iyul') when the source schedule
  /// gave only the month. Render through [SayyorData.localizeDate].
  final String date;
  final String place;
  final String placeRu;

  /// District/city name in the kiosk language.
  String regionFor(Lang lang) {
    if (lang == Lang.ru) return regionRu;
    if (lang == Lang.en && region == 'Viloyat tashkilotlari') {
      return 'Regional organisations';
    }
    return region;
  }

  /// Venue (MFY) name in the kiosk language's script.
  String placeFor(Lang lang) => lang == Lang.ru ? placeRu : place;
}

/// An organisation holding mobile receptions across the region.
class SayyorOrg {
  const SayyorOrg(this.name, this.icon, this.visits);

  final Map<Lang, String> name;
  final IconData icon;
  final List<SayyorVisit> visits;
}

/// The Tashkent region Q3-2026 mobile reception schedule, grouped by
/// organisation (largest first), each visit sorted chronologically.
class SayyorData {
  const SayyorData._();

  static const Map<Lang, List<String>> _months = {
    Lang.uz: ['Iyul', 'Avgust', 'Sentabr'],
    Lang.ru: ['Июль', 'Август', 'Сентябрь'],
    Lang.en: ['July', 'August', 'September'],
  };

  /// dd.mm.yyyy dates pass through; bare month names are localised.
  static String localizeDate(String date, Lang lang) {
    final i = _months[Lang.uz]!.indexOf(date);
    return i == -1 ? date : _months[lang]![i];
  }

  static const List<SayyorOrg> orgs = [''');

  for (final org in orgNames) {
    final meta = orgMeta[org]!;
    final visits = byOrg[org]!
      ..sort((a, b) => sortKey(a[2]).compareTo(sortKey(b[2])));
    b.writeln('    SayyorOrg({');
    b.writeln('      Lang.uz: "${esc(meta[0])}",');
    b.writeln('      Lang.ru: "${esc(meta[1])}",');
    b.writeln('      Lang.en: "${esc(meta[2])}",');
    b.writeln('    }, ${meta[3]}, [');
    for (final v in visits) {
      b.writeln('      SayyorVisit("${esc(v[0])}", "${esc(v[1])}", '
          '"${esc(v[2])}", "${esc(v[3])}", "${esc(v[4])}"),');
    }
    b.writeln('    ]),');
  }
  b.writeln('  ];');
  b.writeln('}');

  File('C:/flutter_projects/info_kiosk/lib/src/sayyor_data.dart')
      .writeAsStringSync(b.toString());
  final total = rows.length;
  stdout.writeln('OK: ${orgNames.length} orgs, $total visits');
}
