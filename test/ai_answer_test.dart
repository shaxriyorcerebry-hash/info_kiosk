import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/data.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/services/ai_api.dart';

/// Backend stub: records what it was asked and replies as instructed.
class _FakeApi extends AiApi {
  _FakeApi({this.answer, this.grounded = true, this.fail = false})
      : super(apiBase: 'https://example.invalid/api');

  final String? answer;
  final bool grounded;
  final bool fail;
  int calls = 0;
  Lang? lastLang;

  @override
  Future<AiAnswer> ask(String question, Lang lang) async {
    calls++;
    lastLang = lang;
    if (fail) throw Exception('network down');
    return AiAnswer(answer ?? 'backend javobi', grounded: grounded);
  }
}

/// A backend configured with an empty base — the fully offline kiosk.
class _OfflineApi extends AiApi {
  _OfflineApi() : super(apiBase: '');

  @override
  Future<AiAnswer> ask(String question, Lang lang) async =>
      fail('the offline kiosk must never call the backend');
}

void main() {
  test('a question the kiosk knows is answered locally, without the backend',
      () async {
    final api = _FakeApi();
    final s = KioskState(api: api);

    // Taken verbatim from the kiosk's own FAQ, so it must match locally.
    await s.ask(AppData.faq[Lang.uz]!.first[0]);

    expect(api.calls, 0, reason: 'local match must not spend a backend call');
    expect(s.chat.last.text, AppData.faq[Lang.uz]!.first[1]);
    s.dispose();
  });

  test('an unknown question goes to the backend when it is grounded', () async {
    const grounded = 'Mehnat kodeksining 78-moddasiga muvofiq ...';
    final api = _FakeApi(answer: grounded);
    final s = KioskState(api: api);
    s.setLang(Lang.ru);

    await s.ask('zzz qqq xyzzy');

    expect(api.calls, 1);
    expect(api.lastLang, Lang.ru);
    expect(s.chat.last.text, grounded);
    s.dispose();
  });

  test('an ungrounded backend reply falls back to the offline text', () async {
    final api = _FakeApi(answer: 'bilmayman', grounded: false);
    final s = KioskState(api: api);

    await s.ask('zzz qqq xyzzy');

    expect(api.calls, 1);
    expect(s.chat.last.text, Tr(Lang.uz).aiOffline);
    s.dispose();
  });

  test('a backend failure never surfaces as an error', () async {
    final api = _FakeApi(fail: true);
    final s = KioskState(api: api);

    await s.ask('zzz qqq xyzzy');

    expect(s.chat.last.text, Tr(Lang.uz).aiOffline);
    expect(s.aiLoading, isFalse);
    s.dispose();
  });

  test('with no backend configured the kiosk stays fully offline', () async {
    final s = KioskState(api: _OfflineApi());

    await s.ask('zzz qqq xyzzy');

    expect(s.chat.last.text, Tr(Lang.uz).aiOffline);
    s.dispose();
  });
}
