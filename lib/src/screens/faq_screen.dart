import 'package:flutter/material.dart';

import '../data.dart';
import '../kiosk_state.dart';
import '../theme.dart';

/// Accordion of frequently-asked questions.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key, required this.state});

  final KioskState state;

  @override
  Widget build(BuildContext context) {
    final items = AppData.faq[state.lang]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _FaqTile(
                  question: items[i][0],
                  answer: items[i][1],
                  open: state.faqOpen == i,
                  onTap: () => state.toggleFaq(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.open,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0F0D3B73), blurRadius: 16, offset: Offset(0, 6)),
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
              constraints: const BoxConstraints(minHeight: 70),
              color: open ? AppColors.panelBg : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(question,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.3)),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 30, color: Color(0xFF1B5FAF)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEAF1F9))),
              ),
              child: Text(answer,
                  style: const TextStyle(fontSize: 21, height: 1.5, color: AppColors.body)),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
