import '../data.dart';
import '../l10n.dart';

/// Uzbekistan keeps UTC+5 all year, so which day a reception falls on never
/// depends on the time zone the kiosk machine happens to be set to.
const Duration tashkentOffset = Duration(hours: 5);

/// [t] on the Tashkent wall clock. An instant (`…Z`, `…+05:00`) is shifted;
/// a time written without an offset is taken to be Tashkent time already.
DateTime tashkentWall(DateTime t) => t.isUtc ? t.add(tashkentOffset) : t;

/// The Tashkent wall clock at [now].
DateTime tashkentNow(DateTime now) => now.toUtc().add(tashkentOffset);

/// The governor's next in-person reception, as the governor sets it in the
/// dashboard (`PUT /panel/reception-points/{id}/schedule`, [[API/29]]).
///
/// The weekly schedule (`reception-schedule`) is a text an editor keeps; this
/// is a date the governor picks, so where the two disagree this one is shown.
/// Only the governor has one — the deputies have no reception point. Which
/// card is the governor's is [isHokimOfficial]'s call.
class HokimReception {
  const HokimReception({this.at, this.location = ''});

  /// Start of the reception on the Tashkent wall clock, or null while none is
  /// set. The backend keeps no end time.
  final DateTime? at;

  /// Where it is held, as typed in the dashboard (Uzbek only).
  final String location;

  /// The governor's point in a `GET /kiosk/reception-points` list.
  ///
  /// Null when there is no such list or no governor in it — "unknown", which
  /// leaves the weekly wording up. A governor's point without a time is
  /// "not set", which is something else: [at] is null.
  static HokimReception? fromPoints(dynamic raw) {
    if (raw is! List) return null;
    final points = [
      for (final p in raw)
        if (p is Map && _isHokimPoint(p)) p,
    ]..sort((a, b) => _order(a).compareTo(_order(b)));
    if (points.isEmpty) return null;
    final p = points.first;
    return HokimReception(
      at: _parseTime(p['next_reception_at']),
      location: p['reception_location']?.toString().trim() ?? '',
    );
  }

  /// The ticket prefix is what the queue kiosks key on (`H` — governor,
  /// `P` — the President's reception); the name is the fallback for a list
  /// that does not carry it.
  static bool _isHokimPoint(Map p) {
    final prefix = p['ticket_prefix']?.toString().trim().toUpperCase() ?? '';
    if (prefix.isNotEmpty) return prefix == 'H';
    return (p['name_uz']?.toString().toLowerCase() ?? '').contains('hokim');
  }

  static num _order(Map p) {
    final v = p['sort_order'];
    return v is num ? v : 1 << 30;
  }

  static DateTime? _parseTime(dynamic v) {
    if (v is! String || v.trim().isEmpty) return null;
    final t = DateTime.tryParse(v.trim());
    return t == null ? null : tashkentWall(t);
  }

  /// True until the reception day is over in Tashkent: on the day itself the
  /// date stays up after the start hour, since the end hour is not known.
  bool isUpcoming(DateTime now) {
    final a = at;
    if (a == null) return false;
    final today = tashkentNow(now);
    return !DateTime.utc(a.year, a.month, a.day)
        .isBefore(DateTime.utc(today.year, today.month, today.day));
  }

  /// What the governor's card shows, to tell whether it needs redrawing.
  String keyAt(DateTime now) => '$at|$location|${isUpcoming(now)}';

  /// [official]'s card with the dated reception in place of the weekly one —
  /// or, once no date is set or the last one has passed, saying so.
  QabulOfficial applyTo(QabulOfficial official, DateTime now) {
    final a = at;
    if (a == null || !isUpcoming(now)) {
      return QabulOfficial(
        official.name,
        official.position,
        {for (final l in Lang.values) l: Tr(l).receptionUnset},
        '',
        official.phone,
      );
    }
    final withYear = a.year != tashkentNow(now).year;
    return QabulOfficial(
      official.name,
      official.position,
      {
        for (final l in Lang.values)
          l: AppData.receptionDate(a, l, withYear: withYear),
      },
      '${_two(a.hour)}:${_two(a.minute)}',
      official.phone,
      location: location,
      scheduled: ScheduledReception(a, withYear: withYear),
    );
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
