import 'package:flutter/material.dart';

import '../content_models.dart';
import '../data.dart';
import '../kiosk_state.dart';
import '../l10n.dart';
import '../sayyor_data.dart';
import '../services/hokim_reception.dart';
import '../theme.dart';
import '../widgets/empty_content.dart';
import '../widgets/info_card.dart';
import '../widgets/pressable.dart';

const List<Color> _personalAccent = [Color(0xFF1E4B8F), Color(0xFF2563EB)];
const List<Color> _sayyorAccent = [Color(0xFF0E7490), Color(0xFF0891B2)];

/// Hours & reception schedule — a hub of two sub-sections. "Shaxsiy
/// murojaat qabuli" opens the weekly in-person schedule of the governor and
/// deputies; "Sayyor qabul" opens the list of organisations holding mobile
/// receptions, each with its schedule in a modal dialog.
///
/// The open sub-section lives in [KioskState.jadvalView], so the global
/// back button pops one level at a time.
class JadvalScreen extends StatelessWidget {
  const JadvalScreen({super.key, required this.state});

  final KioskState state;

  @override
  Widget build(BuildContext context) {
    final t = Tr(state.lang);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.03, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      child: switch (state.jadvalView) {
        JadvalView.hub => _Hub(
            key: const ValueKey('hub'),
            t: t,
            onShaxsiy: () => state.openJadval(JadvalView.shaxsiy),
            onSayyor: () => state.openJadval(JadvalView.sayyor),
          ),
        JadvalView.shaxsiy => switch (state.content.officialsShown) {
            final o? when !o.isEmpty =>
              _ShaxsiyList(key: const ValueKey('shaxsiy'), t: t, info: o),
            _ => EmptyContent(
                key: const ValueKey('shaxsiy-empty'),
                lang: state.lang,
                loading: !state.content.ready,
                offline: state.content.unreachable,
              ),
          },
        JadvalView.sayyor => switch (state.content.mobileSchedule) {
            final s? when !s.isEmpty => _SayyorList(
                key: const ValueKey('sayyor'),
                t: t,
                lang: state.lang,
                orgs: s.orgs,
              ),
            _ => EmptyContent(
                key: const ValueKey('sayyor-empty'),
                lang: state.lang,
                loading: !state.content.ready,
                offline: state.content.unreachable,
              ),
          },
      },
    );
  }
}

/// The two large sub-section buttons, pinned to the top of the section.
class _Hub extends StatelessWidget {
  const _Hub({
    super.key,
    required this.t,
    required this.onShaxsiy,
    required this.onSayyor,
  });

  final Tr t;
  final VoidCallback onShaxsiy;
  final VoidCallback onSayyor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final stacked = box.maxWidth < 1100;
        final width =
            stacked ? (box.maxWidth - 64).clamp(280.0, 760.0) : 560.0;
        final buttons = [
          _EnterIn(
            delayMs: 0,
            child: _SectionButton(
              icon: Icons.co_present_outlined,
              title: t.jadvalPersonal,
              subtitle: t.shaxsiyDesc,
              accent: _personalAccent,
              width: width,
              onTap: onShaxsiy,
            ),
          ),
          _EnterIn(
            delayMs: 130,
            child: _SectionButton(
              icon: Icons.tour_outlined,
              title: t.jadvalMobile,
              subtitle: t.chooseOrg,
              accent: _sayyorAccent,
              width: width,
              onTap: onSayyor,
            ),
          ),
        ];
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 18, 32, 32),
            child: stacked
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [buttons[0], const SizedBox(height: 26), buttons[1]],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [buttons[0], const SizedBox(width: 26), buttons[1]],
                  ),
          ),
        );
      },
    );
  }
}

/// The weekly in-person reception schedule of the governor and deputies —
/// an intro banner, the governor's card across the full width, and a card
/// grid of the deputies: name, position, weekly slot and phone.
///
/// The hall kiosks stand in portrait (1080 px wide, or 720–864 logical at
/// 125–150 % scaling), so the grid drops to two columns — one below 760 px —
/// and the governor's card lays out side by side down to 720 px.
class _ShaxsiyList extends StatelessWidget {
  const _ShaxsiyList({super.key, required this.t, required this.info});

  final Tr t;
  final OfficialsInfo info;

  @override
  Widget build(BuildContext context) {
    final lang = t.lang;
    // The governor has a single, dated reception — it gets its own row.
    final hokim = info.officials.indexWhere(isHokimOfficial);
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth > 1240 ? 3 : (box.maxWidth >= 760 ? 2 : 1);
        final gridWidth = (box.maxWidth - 64).clamp(280.0, 1500.0);
        final cardWidth = (gridWidth - 20 * (cols - 1)) / cols;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 6, 32, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: gridWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EnterIn(
                    delayMs: 0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F1FA),
                        border: Border.all(color: const Color(0xFFC4D6EC)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        info.intro[lang] ?? '',
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (hokim >= 0) ...[
                    _EnterIn(
                      delayMs: 40,
                      child: _HokimCard(
                        index: hokim + 1,
                        official: info.officials[hokim],
                        t: t,
                        width: gridWidth,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      for (var i = 0; i < info.officials.length; i++)
                        if (i != hokim)
                          _EnterIn(
                            delayMs: (i * 45).clamp(0, 400),
                            child: _OfficialCard(
                              index: i + 1,
                              official: info.officials[i],
                              lang: lang,
                              width: cardWidth,
                              // Evens out a row; a lone card needs no floor.
                              minHeight: cols > 1 ? 240 : 0,
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _EnterIn(
                    delayMs: 420,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F1FA),
                        border: Border.all(color: const Color(0xFFC4D6EC)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 26, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              info.note[lang] ?? '',
                              style: const TextStyle(
                                  fontSize: 20,
                                  height: 1.45,
                                  color: AppColors.body),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The governor: one reception, on one date, so the card is the section's
/// feature — full width, brand gradient, the date set large on a white slot.
///
/// Side by side from 720 px (a portrait 1080 px kiosk, and 864 px at 125 %
/// scaling); stacked below that.
class _HokimCard extends StatelessWidget {
  const _HokimCard({
    required this.index,
    required this.official,
    required this.t,
    required this.width,
  });

  final int index;
  final QabulOfficial official;
  final Tr t;
  final double width;

  @override
  Widget build(BuildContext context) {
    final wide = width >= 720;
    final info = _HokimInfo(index: index, official: official, lang: t.lang);
    final slot = _HokimSlot(official: official, t: t);
    return Container(
      width: width,
      padding: EdgeInsets.all(wide ? 24 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primaryDark, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: wide
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 11, child: info),
                  const SizedBox(width: 26),
                  Expanded(flex: 10, child: slot),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [info, const SizedBox(height: 20), slot],
            ),
    );
  }
}

/// Left side of the governor's card: who, and how to call — white on blue.
class _HokimInfo extends StatelessWidget {
  const _HokimInfo({
    required this.index,
    required this.official,
    required this.lang,
  });

  final int index;
  final QabulOfficial official;
  final Lang lang;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 1.4),
                  ),
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    official.name[lang]!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              official.position[lang]!,
              style: TextStyle(
                fontSize: 21,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.86),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(Icons.call_outlined,
                size: 24, color: Colors.white.withValues(alpha: 0.86)),
            const SizedBox(width: 10),
            Text(
              official.phone,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Right side of the governor's card: when. Three states — a set date, no
/// date ("not set"), or the weekly wording while the date is unknown.
class _HokimSlot extends StatelessWidget {
  const _HokimSlot({required this.official, required this.t});

  final QabulOfficial official;
  final Tr t;

  @override
  Widget build(BuildContext context) {
    final lang = t.lang;
    final scheduled = official.scheduled;
    final unset = scheduled == null && official.time.isEmpty;

    final List<Widget> body;
    if (scheduled != null) {
      body = [
        _label(Icons.event_available_outlined, t.nextReception,
            AppColors.primary),
        const SizedBox(height: 10),
        Text(
          AppData.receptionDay(scheduled.at, lang,
              withYear: scheduled.withYear),
          style: const TextStyle(
            fontSize: 42,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                _capitalised(AppData.weekdayName(scheduled.at, lang)),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.body,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _timePill(official.time),
          ],
        ),
      ];
    } else if (unset) {
      body = [
        _label(Icons.event_busy_outlined, t.nextReception, AppColors.muted),
        const SizedBox(height: 12),
        Text(
          official.day[lang]!,
          style: const TextStyle(
            fontSize: 28,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
      ];
    } else {
      body = [
        _label(Icons.schedule_outlined, t.receptionDayLabel, AppColors.primary),
        const SizedBox(height: 10),
        Text(
          official.day[lang]!,
          style: const TextStyle(
            fontSize: 27,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        if (official.time.isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _timePill(official.time),
          ),
        ],
      ];
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...body,
          if (official.location.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined,
                    size: 23, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    official.location,
                    style: const TextStyle(
                      fontSize: 19,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: AppColors.body,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget _label(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: color,
              ),
            ),
          ),
        ],
      );

  static Widget _timePill(String time) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      );

  static String _capitalised(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// One official: numbered, strictly typographic — no gradients, thin rules.
class _OfficialCard extends StatelessWidget {
  const _OfficialCard({
    required this.index,
    required this.official,
    required this.lang,
    required this.width,
    required this.minHeight,
  });

  final int index;
  final QabulOfficial official;
  final Lang lang;
  final double width;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x4D1E4B8F), width: 1.4),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  official.name[lang]!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            official.position[lang]!,
            style: const TextStyle(
              fontSize: 18.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_outlined,
                  size: 21, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  official.day[lang]!,
                  style: const TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.body),
                ),
              ),
              Text(
                official.time,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.call_outlined, size: 21, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                official.phone,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The organisations of the mobile-reception schedule, one button each.
class _SayyorList extends StatelessWidget {
  const _SayyorList({
    super.key,
    required this.t,
    required this.lang,
    required this.orgs,
  });

  final Tr t;
  final Lang lang;
  final List<SayyorOrg> orgs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth > 1240 ? 3 : 2;
        final gridWidth = (box.maxWidth - 64).clamp(280.0, 1500.0);
        final cardWidth = (gridWidth - 20 * (cols - 1)) / cols;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: gridWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.sayyorHint,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (var i = 0; i < orgs.length; i++)
                        _EnterIn(
                          delayMs: (i * 30).clamp(0, 400),
                          child: _OrgButton(
                            org: orgs[i],
                            t: t,
                            lang: lang,
                            width: cardWidth,
                            onTap: () => _showOrgDialog(
                                context, orgs[i], t, lang),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One organisation button: icon, name and visit count.
class _OrgButton extends StatelessWidget {
  const _OrgButton({
    required this.org,
    required this.t,
    required this.lang,
    required this.width,
    required this.onTap,
  });

  final SayyorOrg org;
  final Tr t;
  final Lang lang;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.96,
      child: SizedBox(
        width: width,
        child: InfoCard(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _sayyorAccent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _sayyorAccent.first.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(org.icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name[lang]!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      t.sayyorCount(org.visits.length),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: _sayyorAccent.first),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scale + fade modal with the organisation's full schedule.
Future<void> _showOrgDialog(
    BuildContext context, SayyorOrg org, Tr t, Lang lang) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
      return Opacity(
        opacity: anim.value,
        child: Transform.scale(
          scale: 0.88 + curved.value * 0.12,
          child: _OrgDialog(org: org, t: t, lang: lang),
        ),
      );
    },
  );
}

class _OrgDialog extends StatelessWidget {
  const _OrgDialog({required this.org, required this.t, required this.lang});

  final SayyorOrg org;
  final Tr t;
  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.80;
    // Coming stops first: by the quarter's last month most of a long list is
    // behind, and a visitor should not scroll past it to find next week.
    final today = tashkentNow(DateTime.now());
    final coming = [
      for (final v in org.visits)
        if (!MobileScheduleInfo.isPast(v, today)) v,
    ];
    final past = [
      for (final v in org.visits)
        if (MobileScheduleInfo.isPast(v, today)) v,
    ];
    final rows = <Widget>[
      if (coming.isEmpty) _DialogNote(text: t.noUpcomingVisits),
      for (final v in coming) _VisitRow(visit: v, lang: lang),
      if (past.isNotEmpty) _PastHeader(text: t.pastVisits),
      for (final v in past)
        Opacity(opacity: 0.55, child: _VisitRow(visit: v, lang: lang)),
    ];
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 780, maxHeight: maxH),
        child: Material(
          color: Colors.transparent,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Color(0x59062040), blurRadius: 60, offset: Offset(0, 24)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Teal header band: icon, name, visit count and close button.
                Container(
                  padding: const EdgeInsets.fromLTRB(26, 22, 18, 22),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _sayyorAccent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                        ),
                        child: Icon(org.icon, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              org.name[lang]!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.sayyorCount(org.visits.length),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Pressable(
                        onTap: () => Navigator.of(context).pop(),
                        pressedScale: 0.88,
                        child: Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                          ),
                          child: const Icon(Icons.close_rounded, size: 24, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => rows[i],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Past receptions" — the divider between coming and past stops.
class _PastHeader extends StatelessWidget {
  const _PastHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 22, color: AppColors.muted),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
        ],
      ),
    );
  }
}

/// A single line in the dialog when an organisation has nothing coming up.
class _DialogNote extends StatelessWidget {
  const _DialogNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3D9A4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy_outlined,
              size: 24, color: Color(0xFF9A6B12)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A5410),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One schedule entry: date block, divider, then district/city and MFY.
class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.lang});

  final SayyorVisit visit;
  final Lang lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 152),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  SayyorData.localizeDate(visit.date, lang),
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.cardBorder,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_city_outlined,
                        size: 19, color: AppColors.muted),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        visit.regionFor(lang),
                        style: const TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            height: 1.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 19, color: AppColors.primary),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        visit.placeFor(lang),
                        style: const TextStyle(
                            fontSize: 18, height: 1.3, color: AppColors.body),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered fade + rise entrance.
class _EnterIn extends StatelessWidget {
  const _EnterIn({required this.delayMs, required this.child});

  final int delayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 480 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 34 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.width,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> accent;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.965,
      child: SizedBox(
        width: width,
        child: InfoCard(
          padding: const EdgeInsets.fromLTRB(30, 34, 30, 34),
          child: Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: accent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.first.withValues(alpha: 0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, size: 44, color: Colors.white),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.first.withValues(alpha: 0.10),
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 26, color: accent.first),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
