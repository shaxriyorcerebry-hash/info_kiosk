import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ai_responder.dart';
import 'l10n.dart';
import 'screen.dart';
import 'services/ai_api.dart';
import 'services/content_store.dart';
import 'services/speech_service.dart';
import 'services/voice_session.dart';

/// A single chat bubble in the AI advisor conversation.
class ChatMsg {
  const ChatMsg(this.isUser, this.text);
  final bool isUser;
  final String text;
}

/// Phase of the voice conversation on the AI advisor screen.
enum VoiceStatus { idle, connecting, listening, thinking, speaking }

/// Sub-page of the schedule section.
enum JadvalView { hub, shaxsiy, sayyor }

/// Central, observable kiosk state: current language, screen, FAQ expansion
/// and the voice-driven AI conversation. Screens listen to this and rebuild.
class KioskState extends ChangeNotifier {
  KioskState({AiApi? api, VoiceSession? live, ContentStore? content})
      : _api = api ?? AiApi(),
        live = live ?? VoiceSession(),
        content = content ?? ContentStore() {
    // The content store is a second source of change: when a background
    // refresh brings in a new schedule, the open screen has to redraw.
    this.content.addListener(notifyListeners);
  }

  /// Everything the kiosk displays, as delivered by the backend.
  final ContentStore content;

  Lang lang = Lang.uz;
  Screen screen = Screen.home;
  int faqOpen = -1;

  /// Sub-navigation inside sections, kept here so the single global back
  /// button can pop one level at a time.
  JadvalView jadvalView = JadvalView.hub;

  /// Open organisation on the issues screen, or null on its grid.
  int? masalaOrg;
  bool aiLoading = false;
  final List<ChatMsg> chat = [];

  VoiceStatus voice = VoiceStatus.idle;

  /// Briefly true after a listen attempt heard nothing, to show a hint.
  bool noSpeechNotice = false;

  /// True once a live session has failed to open — no microphone on the
  /// machine, permission refused, no network. Without it the screen falls
  /// straight back to "touch the microphone", so a visitor taps the orb over
  /// and over with nothing ever happening; with it they are told to use the
  /// quick questions instead.
  bool voiceFailed = false;

  final AiResponder _ai = const AiResponder();
  final AiApi _api;
  final SpeechService speech = SpeechService();

  /// The Gemini Live conversation. Only used when the backend is configured
  /// and WebView2 is present; otherwise the kiosk stays on [speech].
  final VoiceSession live;

  StreamSubscription<SpeechEvent>? _speechSub;
  StreamSubscription<VoiceEvent>? _liveSub;
  Timer? _listenGuard;
  Timer? _noticeTimer;

  /// True when a real spoken conversation is possible: the live session for a
  /// networked kiosk, or the offline SAPI recogniser for a standalone one.
  bool get canConverse => live.available || speech.recognitionAvailable;

  /// When the visitor last spoke or was spoken to.
  ///
  /// A voice conversation involves no touching, so the idle timer — which only
  /// sees pointer events — would otherwise reset the kiosk out from under
  /// someone in mid-sentence. Once they walk away the events stop and the
  /// ordinary idle timeout takes over again.
  DateTime lastVoiceActivity = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isHome => screen == Screen.home;
  bool get isDark => screen == Screen.ai;
  bool get voiceBusy => voice != VoiceStatus.idle;

  /// Spawn the offline speech bridge and start routing its events.
  Future<void> initSpeech() async {
    await speech.init();
    _speechSub ??= speech.events.listen(_onSpeechEvent);
    notifyListeners();
  }

  /// Prepare the live voice session. Safe to call on a kiosk with no network
  /// or no WebView2 — it simply stays unavailable and nothing else changes.
  Future<void> initLive() async {
    if (!_api.enabled) return;
    _liveSub ??= live.events.listen(_onLiveEvent);
    await live.init();
    notifyListeners();
  }

  void _onLiveEvent(VoiceEvent e) {
    lastVoiceActivity = DateTime.now();
    switch (e.type) {
      case VoiceEventType.state:
        voice = switch (e.value) {
          'connecting' => VoiceStatus.connecting,
          'listening' => VoiceStatus.listening,
          'speaking' => VoiceStatus.speaking,
          _ => VoiceStatus.idle,
        };
        notifyListeners();
      case VoiceEventType.question:
        chat.add(ChatMsg(true, e.value));
        notifyListeners();
      case VoiceEventType.answer:
        chat.add(ChatMsg(false, e.value));
        notifyListeners();
      case VoiceEventType.error:
        // Drop back to the offline advisor rather than stranding the visitor.
        voice = VoiceStatus.idle;
        voiceFailed = true;
        notifyListeners();
    }
  }

  /// Opens a live conversation: from here the visitor just speaks, and Gemini's
  /// own voice-activity detection decides when each question ends.
  Future<void> _startLive() async {
    voice = VoiceStatus.connecting;
    // Every attempt gets a clean slate: a kiosk whose network came back, or
    // whose microphone was plugged in, must be able to recover on its own.
    voiceFailed = false;
    notifyListeners();
    try {
      debugPrint('live: requesting voice token');
      final token = await _api.voiceToken(lang);
      debugPrint('live: token ok, model=${token.model} '
          'voice=${token.voice} modality=${token.modality}');
      await live.start(token, greeting: Tr(lang).aiGreetingPrompt);
    } catch (e) {
      debugPrint('live session failed to start: $e');
      live.trace('start failed: $e');
      voice = VoiceStatus.idle;
      voiceFailed = true;
      notifyListeners();
    }
  }

  Future<void> _stopLive() async {
    if (live.running) await live.stop();
  }

  void _onSpeechEvent(SpeechEvent e) {
    switch (e.type) {
      case SpeechEventType.finalResult:
        if (voice != VoiceStatus.listening) return;
        _listenGuard?.cancel();
        _deliver(e.text);
      case SpeechEventType.noSpeech:
        if (voice != VoiceStatus.listening) return;
        _listenGuard?.cancel();
        voice = VoiceStatus.idle;
        _flashNoSpeech();
      case SpeechEventType.speakDone:
        if (voice == VoiceStatus.speaking) {
          voice = VoiceStatus.idle;
          notifyListeners();
        }
    }
  }

  void _flashNoSpeech() {
    noSpeechNotice = true;
    notifyListeners();
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(seconds: 4), () {
      noSpeechNotice = false;
      notifyListeners();
    });
  }

  /// Orb tap.
  ///
  /// With the live session it toggles the whole conversation: the first tap
  /// opens it and the visitor then speaks freely, a second tap ends it. On an
  /// offline kiosk it falls back to capturing one question at a time.
  void tapMic() {
    if (live.available) {
      if (live.running) {
        _stopLive();
        voice = VoiceStatus.idle;
        notifyListeners();
      } else if (!aiLoading) {
        _startLive();
      }
      return;
    }
    if (!speech.recognitionAvailable || voiceBusy || aiLoading) return;
    voice = VoiceStatus.listening;
    noSpeechNotice = false;
    _noticeTimer?.cancel();
    speech.listen();
    // Safety net in case the helper never reports back.
    _listenGuard?.cancel();
    _listenGuard = Timer(const Duration(seconds: 14), () {
      if (voice == VoiceStatus.listening) {
        voice = VoiceStatus.idle;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Quick-question chip tap — ignored while a voice exchange is in flight.
  Future<void> ask(String text) async {
    if (voiceBusy || aiLoading) return;
    await _deliver(text);
  }

  Future<void> _deliver(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) {
      voice = VoiceStatus.idle;
      notifyListeners();
      return;
    }
    chat.add(ChatMsg(true, msg));
    aiLoading = true;
    voice = VoiceStatus.thinking;
    noSpeechNotice = false;
    notifyListeners();

    final answer = await answerFor(msg);
    chat.add(ChatMsg(false, answer));
    aiLoading = false;
    if (speech.ttsAvailable) {
      voice = VoiceStatus.speaking;
      speech.speak(answer, lang);
    } else {
      voice = VoiceStatus.idle;
    }
    notifyListeners();
  }

  /// Answers [msg], trying three sources in order of how much they can be
  /// trusted for a question asked at a government reception desk.
  ///
  /// 1. **The office's own published FAQ and services.** Instant, works with no
  ///    network, and says exactly what this office wants said.
  /// 2. **`/avatar/ask`** — grounded in the lex.uz index. Its answer carries
  ///    legal citations, so it outranks anything generated; it is used only
  ///    when the backend reports `grounded`, which today it never does because
  ///    the index is empty. That is deliberate: the moment the index is filled
  ///    this path starts working on its own, with no change here.
  /// 3. **`/avatar/converse`** — the general advisor the avatar kiosks use,
  ///    reasoning with search grounding. This is what actually answers today.
  ///
  /// Anything unanswered, and any failure along the way, ends at the localized
  /// "I could not find an answer" text: a visitor is never shown an error.
  Future<String> answerFor(String msg) async {
    final local = _ai.match(
      msg,
      lang,
      faq: content.faq,
      services: content.services,
    );
    if (local != null) {
      // Small, deliberate delay so the "thinking" state is visible.
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return local;
    }
    if (!_api.enabled) return Tr(lang).aiOffline;

    try {
      final remote = await _api.ask(msg, lang);
      if (remote.grounded) return remote.text;
      debugPrint('avatar/ask ungrounded, trying converse');
    } catch (e) {
      debugPrint('avatar/ask failed, trying converse: $e');
    }
    try {
      // Everything already said, so a follow-up question keeps its thread.
      return await _api.converse(
        msg,
        lang,
        history: [for (final m in chat) (isUser: m.isUser, text: m.text)],
      );
    } catch (e) {
      debugPrint('avatar/converse failed, falling back offline: $e');
    }
    return Tr(lang).aiOffline;
  }

  void setLang(Lang l) {
    if (l == lang) return;
    lang = l;
    notifyListeners();
  }

  void open(Screen s) {
    screen = s;
    _resetSections();
    notifyListeners();
  }

  void openJadval(JadvalView v) {
    jadvalView = v;
    notifyListeners();
  }

  void openMasalaOrg(int i) {
    masalaOrg = i;
    notifyListeners();
  }

  /// The single back button: pops one sub-level if a section has one open,
  /// otherwise returns to the home screen.
  void back() {
    if (screen == Screen.jadval && jadvalView != JadvalView.hub) {
      jadvalView = JadvalView.hub;
      notifyListeners();
    } else if (screen == Screen.masalalar && masalaOrg != null) {
      masalaOrg = null;
      notifyListeners();
    } else {
      goHome();
    }
  }

  void goHome() {
    screen = Screen.home;
    _resetSections();
    _clearConversation();
    notifyListeners();
  }

  void _resetSections() {
    faqOpen = -1;
    jadvalView = JadvalView.hub;
    masalaOrg = null;
  }

  void toggleFaq(int i) {
    faqOpen = faqOpen == i ? -1 : i;
    notifyListeners();
  }

  void _clearConversation() {
    // Leaving the AI screen ends any live conversation — the next visitor
    // must never inherit the previous one's session.
    _stopLive();
    aiLoading = false;
    voice = VoiceStatus.idle;
    noSpeechNotice = false;
    voiceFailed = false;
    _listenGuard?.cancel();
    _noticeTimer?.cancel();
    chat.clear();
  }

  /// Return to the pristine landing state (invoked by the idle timer).
  void reset() {
    lang = Lang.uz;
    screen = Screen.home;
    _resetSections();
    _clearConversation();
    notifyListeners();
  }

  @override
  void dispose() {
    _listenGuard?.cancel();
    _noticeTimer?.cancel();
    _speechSub?.cancel();
    _liveSub?.cancel();
    content.removeListener(notifyListeners);
    content.dispose();
    speech.dispose();
    live.dispose();
    super.dispose();
  }
}
