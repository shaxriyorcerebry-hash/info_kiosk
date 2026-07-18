import 'package:flutter/material.dart';

import '../data.dart';
import '../kiosk_state.dart';
import '../l10n.dart';
import '../theme.dart';

/// Landing grid — one tappable card per section.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});

  final KioskState state;

  @override
  Widget build(BuildContext context) {
    final lang = state.lang;
    final t = Tr(lang);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        children: [
          const SizedBox(height: 18),
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
          const SizedBox(height: 34),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1560),
            child: Wrap(
              spacing: 26,
              runSpacing: 26,
              alignment: WrapAlignment.center,
              children: [
                for (final card in AppData.cards)
                  _HomeCard(
                    card: card,
                    lang: lang,
                    onTap: () => state.open(card.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatefulWidget {
  const _HomeCard({required this.card, required this.lang, required this.onTap});

  final CardDef card;
  final Lang lang;
  final VoidCallback onTap;

  @override
  State<_HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<_HomeCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hover ? -8 : 0, 0),
          width: 440,
          constraints: const BoxConstraints(minHeight: 212),
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 26),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E4B8F).withValues(alpha: _hover ? 0.16 : 0.10),
                blurRadius: _hover ? 56 : 40,
                offset: Offset(0, _hover ? 28 : 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFDBEAFE)],
                      ),
                      border: Border.all(color: const Color(0x2E2563EB)),
                    ),
                    child: Icon(widget.card.icon, size: 42, color: AppColors.primary),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.card.title[widget.lang]!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.card.desc[widget.lang]!,
                style: const TextStyle(
                  fontSize: 19,
                  color: Color(0xFF5B7699),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
