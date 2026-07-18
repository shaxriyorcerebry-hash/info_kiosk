import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'config.dart';
import 'data.dart';
import 'kiosk_state.dart';
import 'l10n.dart';
import 'screen.dart';
import 'theme.dart';
import 'screens/ai_screen.dart';
import 'screens/bolimlar_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jadval_screen.dart';
import 'screens/qabul_screen.dart';
import 'screens/xizmatlar_screen.dart';
import 'widgets/footer_bar.dart';
import 'widgets/header_bar.dart';
import 'widgets/kiosk_background.dart';
import 'widgets/section_nav.dart';

/// The root kiosk shell: owns state, the live clock and the idle-reset timer,
/// and lays out background + header + section + content + footer + exit.
class KioskRoot extends StatefulWidget {
  const KioskRoot({super.key});

  @override
  State<KioskRoot> createState() => _KioskRootState();
}

class _KioskRootState extends State<KioskRoot> with WindowListener {
  final KioskState _state = KioskState();
  final ValueNotifier<DateTime> _clock = ValueNotifier(DateTime.now());
  Timer? _ticker;
  DateTime _lastActivity = DateTime.now();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _clock.dispose();
    _state.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _tick() {
    _clock.value = DateTime.now();
    final idle = DateTime.now().difference(_lastActivity).inSeconds;
    final dirty = _state.screen != Screen.home ||
        _state.lang != Lang.uz ||
        _state.faqOpen != -1 ||
        _state.chat.isNotEmpty;
    if (idle > KioskConfig.idleSeconds && dirty) {
      _lastActivity = DateTime.now();
      _state.reset();
    }
  }

  void _markActive() => _lastActivity = DateTime.now();

  // Window close (Alt+F4) is blocked while prevent-close is on.
  @override
  void onWindowClose() async {
    if (await windowManager.isPreventClose()) return;
    await windowManager.destroy();
  }

  Future<void> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Kiosk rejimidan chiqmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Yo\'q')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ha, chiqish')),
        ],
      ),
    );
    if (ok == true) {
      await WakelockPlus.disable();
      await windowManager.setPreventClose(false);
      await windowManager.setFullScreen(false);
      await windowManager.destroy();
    }
  }

  String _screenTitle(Lang lang) {
    for (final c in AppData.cards) {
      if (c.id == _state.screen) return c.title[lang]!;
    }
    return '';
  }

  Widget _body() {
    return switch (_state.screen) {
      Screen.home => HomeScreen(state: _state),
      Screen.qabul => QabulScreen(lang: _state.lang),
      Screen.jadval => JadvalScreen(lang: _state.lang),
      Screen.bolimlar => BolimlarScreen(lang: _state.lang),
      Screen.xizmatlar => XizmatlarScreen(lang: _state.lang),
      Screen.faq => FaqScreen(state: _state),
      Screen.contact => ContactScreen(lang: _state.lang),
      Screen.ai => AiScreen(state: _state),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _markActive(),
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          final palette = _state.isDark ? Palette.aiDark : Palette.light;
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(child: KioskBackground(dark: _state.isDark)),
                Positioned.fill(
                  child: Column(
                    children: [
                      HeaderBar(state: _state, palette: palette, clock: _clock),
                      if (!_state.isHome)
                        SectionNav(
                          title: _screenTitle(_state.lang),
                          palette: palette,
                          lang: _state.lang,
                          onGoHome: _state.goHome,
                        ),
                      Expanded(child: _body()),
                      FooterBar(
                        palette: palette,
                        lang: _state.lang,
                        onExit: _confirmExit,
                      ),
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
