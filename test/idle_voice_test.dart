import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/services/voice_session.dart';

void main() {
  test('a spoken exchange counts as activity for the idle timer', () async {
    final live = VoiceSession();
    final s = KioskState(live: live);
    // Subscribes to the session's events; the WebView2 init inside fails
    // harmlessly in a test binding, leaving the session simply unavailable.
    await s.initLive();
    expect(s.lastVoiceActivity.year, 1970, reason: 'nobody has spoken yet');

    final before = DateTime.now();
    live.emit(const VoiceEvent(VoiceEventType.question, 'ish vaqti qanday?'));
    await Future<void>.delayed(Duration.zero); // let the stream deliver

    // The idle timer only sees pointer events, so without this a visitor who
    // is talking — and therefore touching nothing — would be reset mid-answer.
    expect(s.lastVoiceActivity.isBefore(before), isFalse);
    expect(s.chat.last.text, 'ish vaqti qanday?');
    s.dispose();
  });

  test('a server-side close clears running so the next tap reconnects',
      () async {
    final live = VoiceSession();
    final s = KioskState(live: live);
    // Subscribes to the session's events; the WebView2 init inside fails
    // harmlessly in a test binding, leaving the session simply unavailable.
    await s.initLive();
    live.running = true;

    live.emit(const VoiceEvent(VoiceEventType.state, 'closed'));
    await Future<void>.delayed(Duration.zero);

    expect(live.running, isFalse);
    expect(s.voice, VoiceStatus.idle);
    s.dispose();
  });
}
