import 'package:flutter/material.dart';

import 'data.dart';
import 'l10n.dart';
import 'masalalar_data.dart';
import 'sayyor_data.dart';
import 'screen.dart';

/// Parsing of the backend's content payloads into the very same types the
/// screens already draw ([CardDef], [QabulOfficial], [Tashkilot], [SayyorOrg]
/// …), so switching a screen from built-in data to backend data is a change of
/// source, not a rewrite.
///
/// Everything here is defensive on purpose. The content is edited by hand in
/// an admin panel, so a missing translation, an unknown icon name or a date in
/// the wrong shape is a question of when, not if — and none of them may take
/// the kiosk down. A malformed entry is skipped; a malformed section throws and
/// the caller keeps its cache.

/// `{"uz": "...", "ru": "...", "en": "..."}` → a language map.
///
/// Uzbek is the source language of every section, so `ru`/`en` fall back to it
/// rather than leaving a visitor with a blank card.
Map<Lang, String> triText(dynamic raw) {
  if (raw is String) {
    return {Lang.uz: raw, Lang.ru: raw, Lang.en: raw};
  }
  if (raw is! Map) return const {Lang.uz: '', Lang.ru: '', Lang.en: ''};
  String pick(String key) => (raw[key] as String?)?.trim() ?? '';
  final uz = pick('uz');
  final ru = pick('ru');
  final en = pick('en');
  return {
    Lang.uz: uz,
    Lang.ru: ru.isEmpty ? uz : ru,
    Lang.en: en.isEmpty ? uz : en,
  };
}

bool _hasText(Map<Lang, String> m) => (m[Lang.uz] ?? '').isNotEmpty;

List<Map<String, dynamic>> _objects(dynamic raw) {
  if (raw is! List) return const [];
  return [
    for (final e in raw)
      if (e is Map) e.cast<String, dynamic>(),
  ];
}

/// Backend icon key → the Material icon the kiosk draws.
///
/// The backend never sends a code point; it sends a stable key that an admin
/// picks from a list. An unrecognised key is not an error — the kiosk simply
/// draws a neutral icon and shows the entry, because the words matter more
/// than the picture.
const Map<String, IconData> kIcons = {
  'account_balance': Icons.account_balance_outlined,
  'account_balance_wallet': Icons.account_balance_wallet_outlined,
  'apartment': Icons.apartment,
  'assignment': Icons.assignment_outlined,
  'assignment_turned_in': Icons.assignment_turned_in_outlined,
  'balance': Icons.balance,
  'bolt': Icons.bolt,
  'call': Icons.call_outlined,
  'directions_bus': Icons.directions_bus_outlined,
  'diversity_3': Icons.diversity_3_outlined,
  'edit_road': Icons.edit_road,
  'gavel': Icons.gavel,
  'health_and_safety': Icons.health_and_safety_outlined,
  'help': Icons.help_outline,
  'holiday_village': Icons.holiday_village_outlined,
  'home_work': Icons.home_work_outlined,
  'layers': Icons.layers_outlined,
  'local_fire_department': Icons.local_fire_department_outlined,
  'local_hospital': Icons.local_hospital_outlined,
  'local_police': Icons.local_police_outlined,
  'location_city': Icons.location_city_outlined,
  'map': Icons.map_outlined,
  'park': Icons.park_outlined,
  'payments': Icons.payments_outlined,
  'pets': Icons.pets_outlined,
  'receipt_long': Icons.receipt_long_outlined,
  'savings': Icons.savings_outlined,
  'schedule': Icons.schedule_outlined,
  'school': Icons.school_outlined,
  'smart_toy': Icons.smart_toy_outlined,
  'sports_soccer': Icons.sports_soccer,
  'theater_comedy': Icons.theater_comedy_outlined,
  'thermostat': Icons.thermostat,
  'travel_explore': Icons.travel_explore,
  'volunteer_activism': Icons.volunteer_activism_outlined,
  'water_drop': Icons.water_drop_outlined,
  'work': Icons.work_outline,
};

IconData iconFor(dynamic key) =>
    kIcons[key?.toString().trim()] ?? Icons.chevron_right_rounded;

/// Home-screen card keys the kiosk knows how to open.
///
/// A card is only worth showing if tapping it leads somewhere, so a `key` the
/// app has no screen for is dropped rather than drawn as a dead tile.
const Map<String, Screen> kSectionKeys = {
  'qabul': Screen.qabul,
  'jadval': Screen.jadval,
  'masalalar': Screen.masalalar,
  'faq': Screen.faq,
  'ai': Screen.ai,
  'contact': Screen.contact,
};

/// Sorts a payload list by `sort_order`, leaving entries without one where
/// they were.
List<Map<String, dynamic>> _sorted(List<Map<String, dynamic>> items) {
  final copy = [...items];
  copy.sort((a, b) {
    final x = a['sort_order'];
    final y = b['sort_order'];
    if (x is! num || y is! num) return 0;
    return x.compareTo(y);
  });
  return copy;
}

bool _isActive(Map<String, dynamic> m) => m['is_active'] != false;

// ---------------------------------------------------------------------------
// config
// ---------------------------------------------------------------------------

/// Office details: what the header, the footer and the contact screen show.
class OfficeInfo {
  const OfficeInfo({
    required this.fullName,
    required this.shortName,
    required this.address,
    required this.workHours,
    required this.lawRef,
    required this.phone,
    required this.trustPhone,
    this.idleSeconds,
    this.lat,
    this.lon,
  });

  final Map<Lang, String> fullName;
  final Map<Lang, String> shortName;
  final Map<Lang, String> address;
  final Map<Lang, String> workHours;
  final Map<Lang, String> lawRef;
  final String phone;
  final String trustPhone;

  /// Seconds of inactivity before the kiosk returns to the home screen.
  ///
  /// Clamped on the way in: a stray `0` or a missing digit in the admin panel
  /// would otherwise either reset the screen out from under a visitor mid-read
  /// or leave their session — and whatever they were looking up — on display
  /// for the next person. Null when unset, and the built-in default applies.
  final int? idleSeconds;

  /// Office coordinates. The contact screen's map is an offline image with the
  /// pin baked in at build time ([KioskConfig.mapPinX]), so these are carried
  /// for completeness rather than drawn — a moved office needs a new tile
  /// image, not just a new number.
  final double? lat;
  final double? lon;

  static OfficeInfo parse(Map<String, dynamic> d) {
    double? num_(dynamic v) => v is num ? v.toDouble() : null;
    final loc = d['location'];
    return OfficeInfo(
      fullName: triText(d['org_full_name']),
      shortName: triText(d['org_short_name']),
      address: triText(d['address']),
      workHours: triText(d['work_hours']),
      lawRef: triText(d['law_ref']),
      phone: d['phone']?.toString().trim() ?? '',
      trustPhone: d['trust_phone']?.toString().trim() ?? '',
      idleSeconds: d['idle_seconds'] is num
          ? (d['idle_seconds'] as num).toInt().clamp(15, 600)
          : null,
      lat: loc is Map ? num_(loc['lat']) : null,
      lon: loc is Map ? num_(loc['lon']) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// sections (home cards)
// ---------------------------------------------------------------------------

List<CardDef> parseCards(Map<String, dynamic> d) {
  return [
    for (final item in _sorted(_objects(d['items'])))
      if (_isActive(item) && kSectionKeys.containsKey(item['key']?.toString()))
        if (_hasText(triText(item['title'])))
          CardDef(
            kSectionKeys[item['key'].toString()]!,
            iconFor(item['icon']),
            triText(item['title']),
            triText(item['desc']),
          ),
  ];
}

// ---------------------------------------------------------------------------
// reception (procedure)
// ---------------------------------------------------------------------------

/// Reception procedure: the numbered steps, the documents to bring and the
/// legal notice about appeals that are not considered.
class ReceptionInfo {
  const ReceptionInfo({
    required this.steps,
    required this.docs,
    required this.note,
  });

  final List<Map<Lang, String>> steps;
  final List<Map<Lang, String>> docs;
  final Map<Lang, String> note;

  bool get isEmpty => steps.isEmpty && docs.isEmpty;

  static ReceptionInfo parse(Map<String, dynamic> d) {
    List<Map<Lang, String>> lines(dynamic raw) => [
      if (raw is List)
        for (final e in raw)
          if (_hasText(triText(e))) triText(e),
    ];
    return ReceptionInfo(
      steps: lines(d['steps']),
      docs: lines(d['docs']),
      note: triText(d['note']),
    );
  }
}

// ---------------------------------------------------------------------------
// reception-schedule (officials)
// ---------------------------------------------------------------------------

/// The weekly in-person reception schedule: an intro banner, the officials and
/// a closing note.
class OfficialsInfo {
  const OfficialsInfo({
    required this.intro,
    required this.note,
    required this.officials,
  });

  final Map<Lang, String> intro;
  final Map<Lang, String> note;
  final List<QabulOfficial> officials;

  bool get isEmpty => officials.isEmpty;

  static OfficialsInfo parse(Map<String, dynamic> d) {
    return OfficialsInfo(
      intro: triText(d['intro']),
      note: triText(d['note']),
      officials: [
        for (final o in _sorted(_objects(d['officials'])))
          if (_isActive(o) && _hasText(triText(o['full_name'])))
            QabulOfficial(
              triText(o['full_name']),
              triText(o['position']),
              triText(o['reception_day']),
              o['time']?.toString().trim() ?? '',
              o['phone']?.toString().trim() ?? '',
            ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// topics (issues and their legal answers)
// ---------------------------------------------------------------------------

class TopicsInfo {
  const TopicsInfo({
    required this.period,
    required this.orgs,
    required this.generalNotes,
  });

  final Map<Lang, String> period;
  final List<Tashkilot> orgs;
  final List<Map<Lang, String>> generalNotes;

  bool get isEmpty => orgs.isEmpty;

  static TopicsInfo parse(Map<String, dynamic> d) {
    return TopicsInfo(
      period: triText(d['period']),
      generalNotes: [
        if (d['general_notes'] is List)
          for (final e in d['general_notes'] as List)
            if (_hasText(triText(e))) triText(e),
      ],
      orgs: [
        for (final org in _sorted(_objects(d['orgs'])))
          if (_isActive(org) && _hasText(triText(org['name'])))
            Tashkilot(triText(org['name']), iconFor(org['icon']), [
              for (final issue in _sorted(_objects(org['issues'])))
                if (_hasText(triText(issue['title'])))
                  Masala(triText(issue['title']), triText(issue['answer'])),
            ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// mobile-schedule (sayyor qabul)
// ---------------------------------------------------------------------------

class MobileScheduleInfo {
  const MobileScheduleInfo({required this.period, required this.orgs});

  final Map<Lang, String> period;
  final List<SayyorOrg> orgs;

  bool get isEmpty => orgs.isEmpty;

  /// ISO `2026-07-22` → `22.07.2026`, the shape [SayyorData.localizeDate] and
  /// the schedule cards already speak. A `date_label` wins when the source
  /// only knew the month ("Iyul"), and anything unparseable is passed through
  /// untouched rather than dropped — a visit with an odd date is still a visit.
  static String readDate(Map<String, dynamic> v) {
    final label = v['date_label'];
    if (label != null) {
      final text = triText(label)[Lang.uz] ?? '';
      if (text.isNotEmpty) return text;
    }
    final raw = v['date']?.toString().trim() ?? '';
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    return iso == null ? raw : '${iso[3]}.${iso[2]}.${iso[1]}';
  }

  static MobileScheduleInfo parse(Map<String, dynamic> d) {
    return MobileScheduleInfo(
      period: triText(d['period']),
      orgs: [
        for (final org in _sorted(_objects(d['orgs'])))
          if (_isActive(org) && _hasText(triText(org['name'])))
            SayyorOrg(triText(org['name']), iconFor(org['icon']), [
              for (final v in _objects(org['visits']))
                SayyorVisit(
                  triText(v['region'])[Lang.uz] ?? '',
                  triText(v['region'])[Lang.ru] ?? '',
                  readDate(v),
                  triText(v['place'])[Lang.uz] ?? '',
                  triText(v['place'])[Lang.ru] ?? '',
                ),
            ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// faq + services
// ---------------------------------------------------------------------------

/// One question and its answer, plus the ready-made questions offered on the
/// AI screen to a visitor who would rather tap than speak.
class FaqInfo {
  const FaqInfo({required this.items, required this.chips});

  final List<({Map<Lang, String> question, Map<Lang, String> answer})> items;
  final List<Map<Lang, String>> chips;

  bool get isEmpty => items.isEmpty;

  static FaqInfo parse(Map<String, dynamic> d) {
    return FaqInfo(
      items: [
        for (final e in _sorted(_objects(d['items'])))
          if (_hasText(triText(e['question'])))
            (question: triText(e['question']), answer: triText(e['answer'])),
      ],
      chips: [
        if (d['chips'] is List)
          for (final c in d['chips'] as List)
            if (_hasText(triText(c))) triText(c),
      ],
    );
  }
}

/// A service the office provides. Never drawn on screen — this is the offline
/// advisor's vocabulary, so it can answer "what can I do here" without asking
/// the backend.
class ServiceInfo {
  const ServiceInfo({required this.title, required this.desc});

  final Map<Lang, String> title;
  final Map<Lang, String> desc;

  static List<ServiceInfo> parseList(Map<String, dynamic> d) => [
    for (final e in _sorted(_objects(d['items'])))
      if (_hasText(triText(e['title'])))
        ServiceInfo(title: triText(e['title']), desc: triText(e['desc'])),
  ];
}
