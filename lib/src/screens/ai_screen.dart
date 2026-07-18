import 'package:flutter/material.dart';

import '../data.dart';
import '../kiosk_state.dart';
import '../l10n.dart';
import '../theme.dart';

/// AI advisor — a fully offline assistant answering from the kiosk knowledge
/// base. Dark themed to match the source design.
class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.state});

  final KioskState state;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with SingleTickerProviderStateMixin {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  KioskState get state => widget.state;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    await state.send(text);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = state.lang;
    final t = Tr(lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
      child: Column(
        children: [
          const SizedBox(height: 6),
          _Orb(pulse: _pulse, active: state.aiLoading),
          const SizedBox(height: 12),
          Text(
            state.aiLoading ? t.aiThinking : t.aiReady,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFCFE0F5)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _Conversation(
                  state: state,
                  scroll: _scroll,
                  intro: t.aiIntro,
                  onChip: _send,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _InputBar(controller: _input, hint: t.aiPlaceholder, onSend: _send),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.pulse, required this.active});
  final Animation<double> pulse;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final s = 1 + pulse.value * (active ? 0.10 : 0.05);
        return Transform.scale(
          scale: s,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [Color(0xFF7FB2E8), AppColors.primary, AppColors.primaryDark],
                stops: [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 40),
          ),
        );
      },
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.state,
    required this.scroll,
    required this.intro,
    required this.onChip,
  });

  final KioskState state;
  final ScrollController scroll;
  final String intro;
  final void Function(String) onChip;

  @override
  Widget build(BuildContext context) {
    final chips = AppData.chips[state.lang]!;
    return ListView(
      controller: scroll,
      children: [
        _Bubble(text: intro, isUser: false),
        if (state.chat.isEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in chips)
                _ChipButton(label: c, onTap: () => onChip(c)),
            ],
          ),
        ],
        for (final m in state.chat) _Bubble(text: m.text, isUser: m.isUser),
        if (state.aiLoading) const _Bubble(text: '•••', isUser: false),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 21,
            height: 1.45,
            color: isUser ? Colors.white : const Color(0xFFEAF2FB),
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x5996BEEB)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 19, color: Color(0xFFDCE8F7))),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.hint, required this.onSend});
  final TextEditingController controller;
  final String hint;
  final void Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x3D96BEEB)),
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              style: const TextStyle(fontSize: 21, color: Color(0xFFEAF2FB)),
              cursorColor: const Color(0xFF7FB2E8),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 20, color: Color(0xFF8FB0D8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onSend(controller.text),
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }
}
