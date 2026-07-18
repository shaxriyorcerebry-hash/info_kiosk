import 'package:flutter/foundation.dart';

import 'ai_responder.dart';
import 'l10n.dart';
import 'screen.dart';

/// A single chat bubble in the AI advisor conversation.
class ChatMsg {
  const ChatMsg(this.isUser, this.text);
  final bool isUser;
  final String text;
}

/// Central, observable kiosk state: current language, screen, FAQ expansion
/// and the AI conversation. Screens listen to this and rebuild on change.
class KioskState extends ChangeNotifier {
  Lang lang = Lang.uz;
  Screen screen = Screen.home;
  int faqOpen = -1;
  bool aiLoading = false;
  final List<ChatMsg> chat = [];

  final AiResponder _ai = const AiResponder();

  bool get isHome => screen == Screen.home;
  bool get isDark => screen == Screen.ai;

  void setLang(Lang l) {
    if (l == lang) return;
    lang = l;
    notifyListeners();
  }

  void open(Screen s) {
    screen = s;
    faqOpen = -1;
    notifyListeners();
  }

  void goHome() {
    screen = Screen.home;
    faqOpen = -1;
    aiLoading = false;
    chat.clear();
    notifyListeners();
  }

  void toggleFaq(int i) {
    faqOpen = faqOpen == i ? -1 : i;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty || aiLoading) return;
    chat.add(ChatMsg(true, msg));
    aiLoading = true;
    notifyListeners();

    // Small, deliberate delay so the "thinking" state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    chat.add(ChatMsg(false, _ai.answer(msg, lang)));
    aiLoading = false;
    notifyListeners();
  }

  /// Return to the pristine landing state (invoked by the idle timer).
  void reset() {
    lang = Lang.uz;
    screen = Screen.home;
    faqOpen = -1;
    aiLoading = false;
    chat.clear();
    notifyListeners();
  }
}
