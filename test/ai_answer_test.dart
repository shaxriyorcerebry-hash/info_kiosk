import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/services/ai_api.dart';

/// One published question and answer — the advisor's whole vocabulary in these
/// tests. It comes from the backend now, exactly as it does on a real kiosk.
const String kQuestion = 'Qanday hujjatlar kerak?';
const String kAnswer = 'Pasport yoki ID-karta va yozma murojaat matni kerak.';

const Map<String, dynamic> kFaqPayload = {
  'items': [
    {
      'question': {'uz': kQuestion, 'ru': 'Какие документы нужны?', 'en': ''},
      'answer': {'uz': kAnswer, 'ru': 'Паспорт и текст обращения.', 'en': ''},
    },
  ],
};

/// Backend stub: records what it was asked and replies as instructed.
class _FakeApi extends AiApi {
  _FakeApi({
    this.answer,
    this.grounded = true,
    this.fail = false,
    this.converseFails = false,
  }) : super(apiBase: 'https://example.invalid/api');

  final String? answer;
  final bool grounded;
  final bool fail;
  /// What the general advisor replies when the legal lookup comes up empty.
  static const String converseAnswer = 'suhbat javobi';
  final bool converseFails;

  int calls = 0;
  int converseCalls = 0;
  Lang? lastLang;
  List<({bool isUser, String text})> lastHistory = const [];

  @override
  Future<AiAnswer> ask(String question, Lang lang) async {
    calls++;
    lastLang = lang;
    if (fail) throw Exception('network down');
    return AiAnswer(answer ?? 'backend javobi', grounded: grounded);
  }

  @override
  Future<String> converse(
    String text,
    Lang lang, {
    List<({bool isUser, String text})> history = const [],
  }) async {
    converseCalls++;
    lastLang = lang;
    lastHistory = history;
    if (converseFails) throw Exception('converse down');
    return converseAnswer;
  }
}

/// A backend configured with an empty base — the fully offline kiosk.
class _OfflineApi extends AiApi {
  _OfflineApi() : super(apiBase: '');

  @override
  Future<AiAnswer> ask(String question, Lang lang) async =>
      fail('the offline kiosk must never call the backend');

  @override
  Future<String> converse(
    String text,
    Lang lang, {
    List<({bool isUser, String text})> history = const [],
  }) async =>
      fail('the offline kiosk must never call the backend');
}

void main() {
  test('a question the kiosk knows is answered locally, without the backend',
      () async {
    final api = _FakeApi();
    final s = KioskState(api: api);
    s.content.applyPayload('faq', kFaqPayload);

    // Taken verbatim from the published FAQ, so it must match locally.
    await s.ask(kQuestion);

    expect(api.calls, 0, reason: 'local match must not spend a backend call');
    expect(s.chat.last.text, kAnswer);
    s.dispose();
  });

  test('with an empty FAQ every question goes to the backend', () async {
    final api = _FakeApi(answer: 'backend javobi');
    final s = KioskState(api: api);

    // Nothing published yet: the advisor has no vocabulary of its own and must
    // not invent one from content compiled into the app.
    await s.ask(kQuestion);

    expect(api.calls, 1);
    expect(s.chat.last.text, 'backend javobi');
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

  test('an ungrounded legal answer is passed to the general advisor', () async {
    // What the live backend does today: the lex.uz index is empty, so `ask`
    // refuses every question. The visitor must still get an answer.
    final api = _FakeApi(answer: 'bilmayman', grounded: false);
    final s = KioskState(api: api);

    await s.ask('zzz qqq xyzzy');

    expect(api.calls, 1, reason: 'the grounded source is still tried first');
    expect(api.converseCalls, 1);
    expect(s.chat.last.text, 'suhbat javobi');
    expect(s.chat.last.text, isNot(Tr(Lang.uz).aiOffline));
    s.dispose();
  });

  test('a grounded legal answer wins over the general advisor', () async {
    const grounded = 'Mehnat kodeksining 78-moddasiga muvofiq ...';
    final api = _FakeApi(answer: grounded);
    final s = KioskState(api: api);

    await s.ask('zzz qqq xyzzy');

    // Citations beat generation: once the lex.uz index is filled, this path
    // takes over on its own and `converse` is never reached.
    expect(s.chat.last.text, grounded);
    expect(api.converseCalls, 0);
    s.dispose();
  });

  test('the advisor is given the conversation so far', () async {
    final api = _FakeApi(grounded: false);
    final s = KioskState(api: api);
    s.chat.add(const ChatMsg(true, 'Qabul qachon?'));
    s.chat.add(const ChatMsg(false, 'Dushanba–Juma 9:00–18:00.'));

    await s.ask('Va hujjatlar?');

    // A follow-up question is meaningless without what came before it.
    expect(api.lastHistory.map((m) => m.text), contains('Qabul qachon?'));
    expect(api.lastHistory.first.isUser, isTrue);
    s.dispose();
  });

  test('both backend sources failing still shows the offline text', () async {
    final api = _FakeApi(fail: true, converseFails: true);
    final s = KioskState(api: api);

    await s.ask('zzz qqq xyzzy');

    expect(s.chat.last.text, Tr(Lang.uz).aiOffline);
    expect(s.aiLoading, isFalse);
    s.dispose();
  });

  test('a failed legal lookup still reaches the general advisor', () async {
    final api = _FakeApi(fail: true);
    final s = KioskState(api: api);

    await s.ask('zzz qqq xyzzy');

    // One source being down is not a reason to leave the visitor unanswered.
    expect(s.chat.last.text, 'suhbat javobi');
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
