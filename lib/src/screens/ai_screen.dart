import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../kiosk_state.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/pressable.dart';

/// AI advisor — a voice-only assistant answering from the kiosk knowledge
/// base. The whole screen is built around one element: a large, living,
/// translucent "slime" orb in the centre. Touch it, speak, and the advisor
/// replies aloud; the spoken exchange is echoed as floating text below.
class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.state});

  final KioskState state;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with SingleTickerProviderStateMixin {
  // Master clock for the slime, ripples, sparks and wave bars. All animated
  // frequencies are whole cycles of this loop so the wrap is seamless.
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  KioskState get state => widget.state;

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  String _status(Tr t) {
    if (state.speech.initialized && !state.canConverse) {
      return t.aiMicUnavailable;
    }
    return switch (state.voice) {
      VoiceStatus.connecting => t.aiConnecting,
      VoiceStatus.listening => t.aiListening,
      VoiceStatus.thinking => t.aiThinking,
      VoiceStatus.speaking => t.aiSpeaking,
      VoiceStatus.idle when state.noSpeechNotice => t.aiNoSpeech,
      VoiceStatus.idle => t.aiTapToSpeak,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Tr(state.lang);
    // The quick questions are the guaranteed path to an answer: they work
    // offline, from the kiosk's own knowledge base. Show them whenever the
    // visitor cannot simply speak — that includes a kiosk with no local
    // recogniser even when a live session is *available*, because the live
    // session may still fail to open. They only step aside while a live
    // conversation is actually running.
    final showQuickQuestions = state.speech.initialized &&
        !state.speech.recognitionAvailable &&
        !state.live.running;

    return LayoutBuilder(
      builder: (context, box) {
        final orbSize =
            (math.min(box.maxWidth, box.maxHeight) * 0.56).clamp(280.0, 560.0);
        return Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _SlimeOrb(
                clock: _clock,
                status: state.voice,
                size: orbSize,
                onTap: state.tapMic,
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 38,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: state.voice == VoiceStatus.listening
                      ? _WaveBars(clock: _clock)
                      : const SizedBox(width: double.infinity),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _status(t),
                  key: ValueKey(_status(t)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCFE0F5)),
                ),
              ),
              const SizedBox(height: 28),
              Flexible(
                flex: 5,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 940),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: SingleChildScrollView(
                      key: ValueKey('${state.chat.length}-${state.aiLoading}'),
                      child: _ExchangeText(state: state, intro: t.aiIntro),
                    ),
                  ),
                ),
              ),
              if (showQuickQuestions) ...[
                const SizedBox(height: 18),
                _QuickQuestions(state: state, title: t.aiQuickTitle),
              ],
              const Spacer(flex: 1),
            ],
          ),
        );
      },
    );
  }
}

/// The floating transcript of the current exchange — no panel, no bubbles:
/// the recognised question in quiet blue, the spoken answer in large light
/// text. Shows the invitation text before the first question.
class _ExchangeText extends StatelessWidget {
  const _ExchangeText({required this.state, required this.intro});

  final KioskState state;
  final String intro;

  @override
  Widget build(BuildContext context) {
    if (state.chat.isEmpty) {
      return Text(
        intro,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 22, height: 1.55, color: Color(0xFF9FBEE3)),
      );
    }

    String? question;
    for (final m in state.chat.reversed) {
      if (m.isUser) {
        question = m.text;
        break;
      }
    }
    final last = state.chat.last;
    final answer = last.isUser ? null : last.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (question != null)
          Text(
            '“$question”',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 21,
                fontStyle: FontStyle.italic,
                color: Color(0xFF8FB0D8)),
          ),
        const SizedBox(height: 16),
        if (state.aiLoading)
          _TypingDots()
        else if (answer != null)
          Text(
            answer,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 26, height: 1.55, color: Color(0xFFEAF2FB)),
          ),
      ],
    );
  }
}

/// The living heart of the screen: layered translucent blobs whose outlines
/// wobble organically like soft slime. Amplitude and tempo follow the voice
/// state — calm breathing at rest, eager wobble while listening, quick
/// simmer while thinking, strong pulse while speaking.
class _SlimeOrb extends StatelessWidget {
  const _SlimeOrb({
    required this.clock,
    required this.status,
    required this.size,
    required this.onTap,
  });

  final Animation<double> clock;
  final VoiceStatus status;
  final double size;
  final VoidCallback onTap;

  IconData get _icon => switch (status) {
        VoiceStatus.idle => Icons.mic_none_rounded,
        VoiceStatus.connecting => Icons.wifi_tethering_rounded,
        VoiceStatus.listening => Icons.mic_rounded,
        VoiceStatus.thinking => Icons.auto_awesome_rounded,
        VoiceStatus.speaking => Icons.graphic_eq_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedBuilder(
        animation: clock,
        builder: (context, _) {
          final t = clock.value;
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _SlimePainter(t: t, status: status),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child)),
                  child: Icon(
                    _icon,
                    key: ValueKey(_icon),
                    color: Colors.white.withValues(alpha: 0.92),
                    size: size * 0.19,
                    shadows: const [
                      Shadow(color: Color(0x662563EB), blurRadius: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SlimePainter extends CustomPainter {
  _SlimePainter({required this.t, required this.status});

  final double t;
  final VoiceStatus status;

  // Whole-cycle tempo per state keeps the 6s loop seamless.
  int get _tempo => switch (status) {
        VoiceStatus.idle => 1,
        VoiceStatus.connecting => 3,
        VoiceStatus.listening => 2,
        VoiceStatus.thinking => 3,
        VoiceStatus.speaking => 4,
      };

  double get _amp => switch (status) {
        VoiceStatus.idle => 0.062,
        VoiceStatus.connecting => 0.070,
        VoiceStatus.listening => 0.095,
        VoiceStatus.thinking => 0.075,
        VoiceStatus.speaking => 0.115,
      };

  /// A closed organic outline: a circle whose radius is modulated by three
  /// travelling sine harmonics — the classic soft-body "slime" silhouette.
  Path _blob(Offset c, double r, double amp, double phase) {
    final tt = t * _tempo;
    final path = Path();
    const n = 140;
    for (var i = 0; i <= n; i++) {
      final th = i / n * 2 * math.pi;
      final w1 = math.sin(3 * th + 2 * math.pi * tt + phase);
      final w2 = math.sin(5 * th - 2 * math.pi * 2 * tt + phase * 1.7);
      final w3 = math.sin(2 * th + 2 * math.pi * tt + phase * 2.3);
      final rr = r * (1 + amp * (0.55 * w1 + 0.28 * w2 + 0.35 * w3));
      final p = c + Offset(math.cos(th), math.sin(th)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.30;
    final active = status != VoiceStatus.idle;

    // Sonar ripples while listening.
    if (status == VoiceStatus.listening) {
      for (var i = 0; i < 3; i++) {
        final p = (t * 2 + i / 3) % 1.0;
        canvas.drawCircle(
          c,
          r * (1.15 + p * 0.55),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..color = const Color(0xFF7FB2E8).withValues(alpha: (1 - p) * 0.36),
        );
      }
    }

    final front = _blob(c, r, _amp, 0);

    // Soft ambient glow beneath everything.
    canvas.drawPath(
      front,
      Paint()
        ..color = AppColors.primary.withValues(alpha: active ? 0.50 : 0.34)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.28),
    );

    // Back and middle layers, out of phase — the translucent depth.
    canvas.drawPath(
      _blob(c, r * 1.12, _amp * 1.25, math.pi / 2),
      Paint()..color = const Color(0xFF7FB2E8).withValues(alpha: 0.16),
    );
    canvas.drawPath(
      _blob(c, r * 1.05, _amp * 1.1, math.pi),
      Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.20),
    );

    // Front body: a see-through gel of official blues.
    canvas.drawPath(
      front,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.38),
          colors: [
            const Color(0xFF9DC6F5).withValues(alpha: 0.72),
            AppColors.primary.withValues(alpha: 0.46),
            const Color(0xFF16346E).withValues(alpha: 0.58),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.25)),
    );

    // Glassy rim.
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.40),
    );

    // Wandering specular highlights — the "wet" look.
    final hi = c +
        Offset(
          -r * 0.34 + math.sin(2 * math.pi * t) * r * 0.06,
          -r * 0.40 + math.cos(2 * math.pi * t) * r * 0.05,
        );
    canvas.drawCircle(
      hi,
      r * 0.30,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.16),
    );
    canvas.drawCircle(
      hi + Offset(r * 0.10, r * 0.06),
      r * 0.10,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
    );

    // Three slow sparks orbiting the body — a quiet nod to the state emblem
    // gold among the blues.
    const sparks = [
      (rf: 1.30, speed: 1, phase: 0.0, size: 4.5, color: Color(0xFFB4D2F5)),
      (rf: 1.22, speed: -1, phase: 2.1, size: 3.5, color: Color(0xFF9CC8F0)),
      (rf: 1.38, speed: 1, phase: 4.2, size: 3.0, color: Color(0xFFE8D5A2)),
    ];
    for (final s in sparks) {
      final ang = 2 * math.pi * t * s.speed * _tempo + s.phase;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * r * s.rf;
      canvas.drawCircle(
          p, s.size + 2.5, Paint()..color = s.color.withValues(alpha: 0.30));
      canvas.drawCircle(p, s.size, Paint()..color = s.color);
    }
  }

  @override
  bool shouldRepaint(_SlimePainter old) => old.t != t || old.status != status;
}

/// Slim animated equaliser shown under the orb while listening.
class _WaveBars extends StatelessWidget {
  const _WaveBars({required this.clock});

  final Animation<double> clock;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clock,
      builder: (context, _) {
        final t = clock.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < 27; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _bar(i, t),
            ],
          ],
        );
      },
    );
  }

  Widget _bar(int i, double t) {
    // Deterministic per-bar character: distinct amplitude, speed and phase.
    final u = (math.sin(i * 12.9898) * 43758.5453).abs() % 1.0;
    final amp = 0.35 + 0.65 * u;
    final cycles = 6 + (u * 5).round();
    final h = 5 + 23 * amp * math.sin(2 * math.pi * (t * cycles + i * 0.13)).abs();
    return Container(
      width: 4,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Color.lerp(
            const Color(0xFF3E6EA8), const Color(0xFFB4D2F5), amp)!,
      ),
    );
  }
}

/// Three softly bouncing dots shown while the answer is being prepared.
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _dot(i),
          ],
        ],
      ),
    );
  }

  Widget _dot(int i) {
    final phase = (_c.value - i * 0.18) % 1.0;
    final lift = math.sin((phase.clamp(0.0, 0.6) / 0.6) * math.pi);
    return Transform.translate(
      offset: Offset(0, -7 * lift),
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
              const Color(0xFF7FB2E8), const Color(0xFFDCE8F7), lift)!,
        ),
      ),
    );
  }
}

/// Fallback when no speech recogniser is installed on the device: the four
/// quick questions become the only way to converse, shown compactly at the
/// bottom (answers are still spoken aloud).
class _QuickQuestions extends StatelessWidget {
  const _QuickQuestions({required this.state, required this.title});

  final KioskState state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final chips = AppData.chips[state.lang]!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: Color(0xFF8FB0D8))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final c in chips)
              Pressable(
                onTap: () => state.ask(c),
                pressedScale: 0.94,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0x7396BEEB)),
                  ),
                  child: Text(c,
                      style: const TextStyle(
                          fontSize: 19, color: Color(0xFFDCE8F7))),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
