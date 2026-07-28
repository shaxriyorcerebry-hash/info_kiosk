import 'package:flutter/material.dart';

import '../content_models.dart';
import '../data.dart';
import '../kiosk_state.dart';
import '../l10n.dart';
import '../sayyor_data.dart';
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
        JadvalView.shaxsiy => switch (state.content.officials) {
            final o? when !o.isEmpty =>
              _ShaxsiyList(key: const ValueKey('shaxsiy'), t: t, info: o),
            _ => EmptyContent(
                key: const ValueKey('shaxsiy-empty'),
                lang: state.lang,
                loading: !state.content.ready,
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
/// an intro banner and a card grid: name, position, weekly slot and phone.
class _ShaxsiyList extends StatelessWidget {
  const _ShaxsiyList({super.key, required this.t, required this.info});

  final Tr t;
  final OfficialsInfo info;

  @override
  Widget build(BuildContext context) {
    final lang = t.lang;
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
                  _EnterIn(
                    delayMs: 0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F1FA),
                        border: Border.all(color: const Color(0xFFC4D6EC)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        info.intro[lang] ?? '',
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (var i = 0; i < info.officials.length; i++)
                        _EnterIn(
                          delayMs: (i * 45).clamp(0, 400),
                          child: _OfficialCard(
                            index: i + 1,
                            official: info.officials[i],
                            lang: lang,
                            width: cardWidth,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _EnterIn(
                    delayMs: 420,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
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

/// One official: numbered, strictly typographic — no gradients, thin rules.
class _OfficialCard extends StatelessWidget {
  const _OfficialCard({
    required this.index,
    required this.official,
    required this.lang,
    required this.width,
  });

  final int index;
  final QabulOfficial official;
  final Lang lang;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 264),
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
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
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 14),
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
                    itemCount: org.visits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _VisitRow(visit: org.visits[i], lang: lang),
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
