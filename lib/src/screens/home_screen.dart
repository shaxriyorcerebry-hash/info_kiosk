import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../data.dart';
import '../kiosk_state.dart';
import '../l10n.dart';
import '../screen.dart';
import '../theme.dart';
import '../widgets/empty_content.dart';
import '../widgets/pressable.dart';

/// Per-card accent gradient — a restrained, official palette drawn from the
/// state emblem colours (blues, teal, gold, green), blue-led throughout.
const Map<Screen, List<Color>> _accents = {
  Screen.qabul: [Color(0xFF1E4B8F), Color(0xFF2563EB)],
  Screen.jadval: [Color(0xFF0E7490), Color(0xFF0891B2)],
  Screen.masalalar: [Color(0xFF7C5A12), Color(0xFFA9791C)],
  Screen.faq: [Color(0xFF0369A1), Color(0xFF0284C7)],
  Screen.ai: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
  Screen.contact: [Color(0xFF047857), Color(0xFF059669)],
};

/// Landing grid — one tappable card per section, entering with a soft
/// staggered rise the first time the home screen appears.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});

  final KioskState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Built in initState, not lazily on first use: when the backend has not
  // delivered the cards yet the screen returns early and never reads this, and
  // a `late final` would then try to *create* the controller inside dispose(),
  // where looking up the ticker's ancestor is no longer legal.
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Animation<double> _slot(int i) {
    final start = (0.06 * i).clamp(0.0, 0.6);
    return CurvedAnimation(
      parent: _enter,
      curve: Interval(
        start,
        (start + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.lang;
    final t = Tr(lang);
    return LayoutBuilder(
      builder: (context, box) {
        // The kiosk is a large portrait touch panel: two columns, with the
        // card height derived from the viewport and the rows the published
        // cards actually need, up to the height a card is drawn for. The
        // block is centred, so six cards (three rows) do not leave the lower
        // half of a 1080x1920 screen empty; a twelve-card set still fits.
        // On landscape (development) windows, fall back to the fixed-width
        // wrap with natural heights.
        final cards = widget.state.content.cards;
        final portrait = box.maxHeight > box.maxWidth;
        final gridWidth = portrait
            ? box.maxWidth - 64
            : math.min(box.maxWidth - 64, 1560.0);
        final cardWidth = portrait ? (gridWidth - 26) / 2 : 440.0;
        final rows = math.max(1, (cards.length / 2).ceil());
        // ~175px of chrome above the grid (paddings + title block), 32px of
        // padding below it and a 26px gap between rows. Leaving the bottom
        // padding out overflowed a shorter portrait screen into a scrollbar
        // once the rows filled it.
        final cardHeight = portrait
            ? ((box.maxHeight - 215 - (rows - 1) * 26) / rows)
                .clamp(190.0, 320.0)
            : null;
        if (cards.isEmpty) {
          return EmptyContent(
            lang: lang,
            loading: !widget.state.content.ready,
            offline: widget.state.content.unreachable,
          );
        }
        return _buildScroll(t, lang, cards, gridWidth, cardWidth, cardHeight,
            centreIn: portrait ? box.maxHeight : null);
      },
    );
  }

  Widget _buildScroll(
    Tr t,
    Lang lang,
    List<CardDef> cards,
    double gridWidth,
    double cardWidth,
    double? cardHeight, {
    double? centreIn,
  }) {
    const padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
    return SingleChildScrollView(
      padding: padding,
      child: ConstrainedBox(
        // Fills the viewport so a short grid sits in the middle of it.
        constraints: BoxConstraints(
          minHeight: centreIn == null ? 0 : centreIn - padding.vertical,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            FadeTransition(
              opacity: _slot(0),
              child: Column(
                children: [
                  Text(
                    t.homeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 76,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF7FB2E8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: gridWidth),
              child: Wrap(
                spacing: 26,
                runSpacing: 26,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    _RisingIn(
                      animation: _slot(i + 1),
                      child: _HomeCard(
                        card: cards[i],
                        lang: lang,
                        width: cardWidth,
                        height: cardHeight,
                        onTap: () => widget.state.open(cards[i].id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fade + rise entrance used for the staggered card cascade.
class _RisingIn extends StatelessWidget {
  const _RisingIn({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, c) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 36 * (1 - animation.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

/// One home-screen section card.
///
/// The card used to lift and light up on mouse hover. Nothing hovers over a
/// kiosk — a visitor's finger is either on the glass or off it — so that state
/// is gone and the same emphasis now happens *while the card is pressed*,
/// where a visitor can actually see it: the card settles into its shadow and
/// the arrow fills with the section colour, confirming the touch landed.
class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.card,
    required this.lang,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final CardDef card;
  final Lang lang;
  final double width;

  /// Fixed height in the portrait 2x6 grid; null lets the card size itself.
  final double? height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accents[card.id] ?? _accents[Screen.qabul]!;
    // Compact metrics when the fixed row height gets tight.
    final compact = height != null && height! < 230;
    final iconSize = compact ? 72.0 : 88.0;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.965,
      builder: (context, pressed) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.first.withValues(alpha: pressed ? 0.26 : 0.12),
                blurRadius: pressed ? 30 : 40,
                offset: Offset(0, pressed ? 10 : 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: width,
                height: height,
                constraints: height == null
                    ? const BoxConstraints(minHeight: 212)
                    : null,
                padding: EdgeInsets.fromLTRB(
                  compact ? 24 : 30,
                  compact ? 20 : 30,
                  compact ? 24 : 30,
                  compact ? 18 : 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              compact ? 20 : 26,
                            ),
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
                          child: Icon(
                            card.icon,
                            size: compact ? 34 : 42,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            card.title[lang]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 23 : 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 10 : 16),
                    _BottomRow(
                      expand: height != null,
                      children: [
                        Expanded(
                          child: Text(
                            card.desc[lang]!,
                            maxLines: compact ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 17 : 19,
                              color: const Color(0xFF5B7699),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pressed
                                ? accent.first
                                : accent.first.withValues(alpha: 0.10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 24,
                            color: pressed ? Colors.white : accent.first,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom row of a home card. In the fixed-height portrait grid it expands
/// so the description and arrow sit pinned to the card's bottom edge; in the
/// natural-height layout it is a plain row.
class _BottomRow extends StatelessWidget {
  const _BottomRow({required this.expand, required this.children});

  final bool expand;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
    if (!expand) return row;
    return Expanded(
      child: Align(alignment: Alignment.bottomLeft, child: row),
    );
  }
}
