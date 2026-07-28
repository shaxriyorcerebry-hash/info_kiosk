import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/ai_responder.dart';
import 'package:info_kiosk/src/content_models.dart';
import 'package:info_kiosk/src/l10n.dart';

/// A published FAQ, in the shape the backend delivers it.
final FaqInfo _faq = FaqInfo.parse(const {
  'items': [
    {
      'question': {
        'uz': 'Qanday hujjatlar kerak?',
        'ru': 'Какие документы нужны?',
        'en': 'What documents are required?',
      },
      'answer': {
        'uz': 'Pasport yoki ID-karta va yozma murojaat matni kerak.',
        'ru': 'Нужен паспорт или ID-карта и текст обращения.',
        'en': 'A passport or ID card and the written appeal text.',
      },
    },
  ],
});

void main() {
  test('offline AI answers a known FAQ from the published content', () {
    const ai = AiResponder();
    final reply = ai.answer('Qanday hujjatlar kerak?', Lang.uz, faq: _faq);
    expect(reply, _faq.items.first.answer[Lang.uz]);
  });

  test('offline AI falls back for an unrelated question', () {
    const ai = AiResponder();
    final reply = ai.answer('zzz qwerty', Lang.uz, faq: _faq);
    expect(reply, Tr(Lang.uz).aiOffline);
  });

  test('offline AI has nothing to say before any content is published', () {
    const ai = AiResponder();
    // The kiosk carries no built-in answers any more: with an empty FAQ the
    // advisor must admit it does not know rather than answer from the app.
    expect(ai.match('Qanday hujjatlar kerak?', Lang.uz), isNull);
    expect(ai.answer('Qanday hujjatlar kerak?', Lang.uz), Tr(Lang.uz).aiOffline);
  });

  test('a language falls back to Uzbek when a translation is missing', () {
    final faq = FaqInfo.parse(const {
      'items': [
        {
          'question': {'uz': 'Ish vaqti qanday?'},
          'answer': {'uz': 'Dushanba–Juma 9:00–18:00.'},
        },
      ],
    });
    // The office publishes Uzbek first and translates later; a Russian visitor
    // must still be shown something rather than an empty card.
    expect(faq.items.first.answer[Lang.ru], 'Dushanba–Juma 9:00–18:00.');
    expect(faq.items.first.answer[Lang.en], 'Dushanba–Juma 9:00–18:00.');
  });
}
