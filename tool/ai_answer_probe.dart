// Asks the live backend a handful of real visitor questions through the very
// path the kiosk uses, and prints which source answered each one.
//
//   flutter test tool/ai_answer_probe.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/services/ai_api.dart';

void main() {
  test('the advisor answers real questions', () async {
    final api = AiApi();
    final state = KioskState(api: api);
    // The published FAQ and services first, exactly as on the kiosk.
    await state.content.refresh();
    stdout.writeln(
      'Bilim bazasi: ${state.content.faq?.items.length ?? 0} FAQ · '
      '${state.content.services.length} xizmat\n',
    );

    const questions = [
      'Qanday hujjatlar kerak?', // should match the published FAQ
      'Mehnat ta\'tili necha kun?',
      'Nikohdan ajrashish qanday amalga oshiriladi?',
      'Pensiya yoshi nechada?',
      'Fuqarolar murojaati qancha muddatda ko\'rib chiqiladi?',
    ];

    for (final q in questions) {
      final answer = await state.answerFor(q);
      final offline = answer == Tr(Lang.uz).aiOffline;
      stdout.writeln('${offline ? "JAVOB YO'Q" : "javob berdi"}  «$q»');
      stdout.writeln(
        '    ${answer.length > 150 ? '${answer.substring(0, 150)}…' : answer}\n',
      );
    }

    state.dispose();
  }, timeout: const Timeout(Duration(minutes: 5)));
}
