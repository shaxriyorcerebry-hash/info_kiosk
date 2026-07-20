import 'package:flutter/material.dart';

import '../kiosk_state.dart';
import '../l10n.dart';
import '../masalalar_data.dart';
import '../theme.dart';
import '../widgets/info_card.dart';
import '../widgets/pressable.dart';

/// Section accent — a restrained bronze/gold drawn from the state emblem,
/// setting this section apart from the blue-led ones without leaving the
/// official palette.
const List<Color> _accent = [Color(0xFF7C5A12), Color(0xFFA9791C)];

/// Organisations and the issues raised at them. The section opens on a grid
/// of organisations; touching one shows its most-raised issues, each of which
/// expands to the legal basis and the answer that must be given.
///
/// The open organisation lives in [KioskState.masalaOrg], so the global back
/// button pops one level at a time.
class MasalalarScreen extends StatelessWidget {
  const MasalalarScreen({super.key, required this.state});

  final KioskState state;

  @override
  Widget build(BuildContext context) {
    final t = Tr(state.lang);
    final org = state.masalaOrg;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.03, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      ),
      child: org == null
          ? _OrgGrid(
              key: const ValueKey('grid'),
              t: t,
              onOpen: state.openMasalaOrg,
            )
          : _OrgDetail(
              key: ValueKey('org-$org'),
              t: t,
              org: MasalalarData.tashkilotlar[org],
            ),
    );
  }
}

/// The grid of organisations to choose from.
class _OrgGrid extends StatelessWidget {
  const _OrgGrid({super.key, required this.t, required this.onOpen});

  final Tr t;
  final ValueChanged<int> onOpen;

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
                    t.masalalarChooseOrg,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.masalalarIntro,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MasalalarData.period[t.lang]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C5A12),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (
                        var i = 0;
                        i < MasalalarData.tashkilotlar.length;
                        i++
                      )
                        _EnterIn(
                          delayMs: (i * 40).clamp(0, 400),
                          child: _OrgButton(
                            org: MasalalarData.tashkilotlar[i],
                            lang: t.lang,
                            width: cardWidth,
                            onTap: () => onOpen(i),
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

/// One appeal subject on the grid: icon and name.
class _OrgButton extends StatelessWidget {
  const _OrgButton({
    required this.org,
    required this.lang,
    required this.width,
    required this.onTap,
  });

  final Tashkilot org;
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
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
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
                    colors: _accent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.first.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(org.icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  org.name[lang]!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: _accent.first,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One organisation's issues, each expanding to its legal answer.
class _OrgDetail extends StatefulWidget {
  const _OrgDetail({
    super.key,
    required this.t,
    required this.org,
  });

  final Tr t;
  final Tashkilot org;

  @override
  State<_OrgDetail> createState() => _OrgDetailState();
}

class _OrgDetailState extends State<_OrgDetail> {
  /// Index of the expanded issue, or -1 when all are collapsed.
  int _open = -1;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final org = widget.org;
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - 64).clamp(280.0, 1240.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.masalalarTapHint,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < org.masalalar.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    _EnterIn(
                      delayMs: (i * 55).clamp(0, 400),
                      child: _MasalaTile(
                        index: i + 1,
                        masala: org.masalalar[i],
                        t: t,
                        open: _open == i,
                        onTap: () => setState(() => _open = _open == i ? -1 : i),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _EnterIn(delayMs: 400, child: _UmumiyIzoh(t: t)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One raised issue: numbered header with its appeal count, expanding to the
/// legal basis and the required answer.
class _MasalaTile extends StatelessWidget {
  const _MasalaTile({
    required this.index,
    required this.masala,
    required this.t,
    required this.open,
    required this.onTap,
  });

  final int index;
  final Masala masala;
  final Tr t;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: open ? const Color(0xFFDDC48A) : AppColors.cardBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0D3B73),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 78),
              color: open ? const Color(0xFFFBF6EA) : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _accent.first.withValues(alpha: open ? 1 : 0.10),
                    ),
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: open ? Colors.white : _accent.first,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      masala.title[t.lang]!,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 30,
                      color: _accent.first,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: open
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEFE3C8))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.gavel_outlined,
                        size: 20,
                        color: Color(0xFF7C5A12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.huquqiyJavob,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C5A12),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    masala.answer[t.lang]!,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.55,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// The closing legal notes that apply to every appeal.
class _UmumiyIzoh extends StatelessWidget {
  const _UmumiyIzoh({required this.t});

  final Tr t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F1FA),
        border: Border.all(color: const Color(0xFFC4D6EC)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                t.umumiyIzohTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final note in MasalalarData.umumiyIzoh[t.lang]!) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, right: 10),
                    child: SizedBox(
                      width: 6,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: AppColors.body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
