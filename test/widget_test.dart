import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/ai_responder.dart';
import 'package:info_kiosk/src/data.dart';
import 'package:info_kiosk/src/l10n.dart';

void main() {
  test('every card has all three translations', () {
    for (final card in AppData.cards) {
      for (final lang in Lang.values) {
        expect(card.title[lang], isNotNull);
        expect(card.desc[lang], isNotNull);
      }
    }
  });

  test('offline AI answers a known FAQ from the knowledge base', () {
    const ai = AiResponder();
    final reply = ai.answer('Qanday hujjatlar kerak?', Lang.uz);
    expect(reply.toLowerCase(), contains('hujjat'));
  });

  test('offline AI falls back for an unrelated question', () {
    const ai = AiResponder();
    final reply = ai.answer('zzz qwerty', Lang.uz);
    expect(reply, Tr(Lang.uz).aiOffline);
  });
}
