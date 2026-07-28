import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import 'config.dart';
import 'kiosk_state.dart';
import 'l10n.dart';
import 'screen.dart';
import 'theme.dart';
import 'windows_shell.dart';
import 'screens/ai_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jadval_screen.dart';
import 'screens/masalalar_screen.dart';
import 'screens/qabul_screen.dart';
import 'widgets/exit_password_dialog.dart';
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

  /// True while the exit password prompt is on screen, so the idle timer
  /// knows to dismiss it.
  bool _exitPrompt = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    // Content first: the screen has nothing to show until it arrives, and the
    // cached copy is on screen before the network is even tried.
    _state.content.start();
    _state.initSpeech();
    _state.initLive();
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
    // Speaking counts as being here, even though it touches nothing.
    final active = _state.lastVoiceActivity.isAfter(_lastActivity)
        ? _state.lastVoiceActivity
        : _lastActivity;
    final idle = DateTime.now().difference(active).inSeconds;
    final dirty = _state.screen != Screen.home ||
        _state.lang != Lang.uz ||
        _state.faqOpen != -1 ||
        _state.chat.isNotEmpty ||
        _state.voiceBusy ||
        // An abandoned password prompt must not sit open on a public screen.
        _exitPrompt;
    // The office sets its own reset delay; the built-in value is only what a
    // kiosk uses before it has ever reached the backend.
    final limit =
        _state.content.office?.idleSeconds ?? KioskConfig.idleSeconds;
    if (idle > limit && dirty) {
      _lastActivity = DateTime.now();
      // Close any open dialog (e.g. the mobile-reception modal) before
      // returning to the pristine home screen.
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
      }
      _state.reset();
    }
  }

  void _markActive() => _lastActivity = DateTime.now();

  /// Grant the microphone to the voice page. There is nobody at an unattended
  /// kiosk to answer a permission prompt, and the page is our own local file
  /// whose only outbound connection is the Gemini live session.
  Future<WebviewPermissionDecision> _grantMicrophone(
          String url, WebviewPermissionKind kind, bool isUserInitiated) async =>
      kind == WebviewPermissionKind.microphone
          ? WebviewPermissionDecision.allow
          : WebviewPermissionDecision.deny;

  // Window close (Alt+F4) is blocked while prevent-close is on.
  @override
  void onWindowClose() async {
    if (await windowManager.isPreventClose()) return;
    await windowManager.destroy();
  }

  Future<void> _confirmExit() async {
    // Leaving kiosk mode is staff-only: it takes the exit password.
    _exitPrompt = true;
    final ok = await askExitPassword(context);
    _exitPrompt = false;
    if (ok) {
      await WakelockPlus.disable();
      await windowManager.setPreventClose(false);
      // Drop fullscreen first: a fullscreen window sits over the task bar, so
      // the shell has to be uncovered before it can be brought back.
      await windowManager.setFullScreen(false);
      await windowManager.hide();
      await restoreWindowsShell();
      await windowManager.destroy();
    }
  }

  /// The section-nav title, drilling into open sub-pages so the single bar
  /// always names what is on screen.
  String _screenTitle(Lang lang) {
    final t = Tr(lang);
    if (_state.screen == Screen.jadval) {
      switch (_state.jadvalView) {
        case JadvalView.shaxsiy:
          return t.jadvalPersonal;
        case JadvalView.sayyor:
          return t.jadvalMobile;
        case JadvalView.hub:
          break;
      }
    }
    final orgs = _state.content.topics?.orgs ?? const [];
    final open = _state.masalaOrg;
    if (_state.screen == Screen.masalalar && open != null && open < orgs.length) {
      return orgs[open].name[lang] ?? '';
    }
    for (final c in _state.content.cards) {
      if (c.id == _state.screen) return c.title[lang] ?? '';
    }
    return '';
  }

  Widget _body() {
    return switch (_state.screen) {
      Screen.home => HomeScreen(state: _state),
      Screen.qabul => QabulScreen(state: _state),
      Screen.jadval => JadvalScreen(state: _state),
      Screen.masalalar => MasalalarScreen(state: _state),
      Screen.faq => FaqScreen(state: _state),
      Screen.contact => ContactScreen(state: _state),
      Screen.ai => AiScreen(state: _state),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Only a press counts as being here, never a pointer crossing the glass: a
    // touch overlay that reports itself as a mouse emits move events from stray
    // reflections and passing sleeves, and letting those reset the idle timer
    // would keep an abandoned session open indefinitely.
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
                // The live voice session's WebView2. It carries no visuals —
                // only the microphone and the speaker — but it must stay in
                // the tree and be laid out for the engine to run, so it sits
                // here as a single transparent pixel behind the UI. Kept at
                // the root (not on the AI screen) so the engine is warm before
                // the first visitor touches the orb.
                if (_state.live.available)
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 1,
                    height: 1,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0,
                        child: Webview(
                          _state.live.controller,
                          permissionRequested: _grantMicrophone,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Column(
                    children: [
                      HeaderBar(state: _state, palette: palette, clock: _clock),
                      if (!_state.isHome)
                        SectionNav(
                          title: _screenTitle(_state.lang),
                          palette: palette,
                          lang: _state.lang,
                          onBack: _state.back,
                          onGoHome: _state.goHome,
                        ),
                      Expanded(child: _body()),
                      FooterBar(
                        palette: palette,
                        lang: _state.lang,
                        onExit: _confirmExit,
                        orgName: _state.content.office
                                ?.shortName[_state.lang] ??
                            '',
                        phone: _state.content.office?.phone ?? '',
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
