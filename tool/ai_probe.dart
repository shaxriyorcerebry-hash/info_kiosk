// Manual smoke test for the backend AI link — not part of `flutter test`.
//
//   dart run tool/ai_probe.dart "savolingiz"
//
// Prints whether the backend is reachable and what `/avatar/ask` returns, so a
// deployed kiosk can be checked without opening the UI.
import 'package:info_kiosk/src/config.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/services/ai_api.dart';

Future<void> main(List<String> args) async {
  final api = AiApi();
  print('apiBase : ${KioskConfig.apiBase}');
  print('health  : ${await api.health()}');

  final q = args.isEmpty ? 'Mehnat shartnomasi qanday bekor qilinadi?' : args.join(' ');
  print('savol   : $q');
  try {
    final a = await api.ask(q, Lang.uz);
    print('grounded: ${a.grounded}');
    print('sources : ${a.sources}');
    print('javob   : ${a.text}');
  } catch (e) {
    print('XATO    : $e');
  }
}
