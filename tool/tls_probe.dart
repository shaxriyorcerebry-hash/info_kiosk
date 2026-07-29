// Proves the roots shipped with the app are enough on their own.
//
// The first installed kiosk failed with
//   HandshakeException: CERTIFICATE_VERIFY_FAILED: unable to get local issuer
// because Dart reads its root certificates from the Windows store, and that
// machine's store had never heard of Let's Encrypt. This probe switches the
// system store OFF and trusts nothing but `assets/certs/roots.pem` — if the
// request succeeds, the app no longer depends on how well a given Windows
// installation is maintained.
//
//   flutter test tool/tls_probe.dart
//
// The PEM is read from disk rather than through `rootBundle` on purpose:
// initialising the widgets binding would install flutter_test's HTTP mock,
// which answers every request with 400 and would prove nothing at all.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/config.dart';

Future<int> _get(SecurityContext? ctx) async {
  final client = HttpClient(context: ctx)
    ..connectionTimeout = const Duration(seconds: 20);
  try {
    final uri = Uri.parse('${KioskConfig.apiBase}/kiosk/info/sections?lang=all');
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final res = await req.close();
    await res.drain<void>();
    return res.statusCode;
  } finally {
    client.close(force: true);
  }
}

void main() {
  test('the bundled roots alone can reach the backend', () async {
    final pem = File('assets/certs/roots.pem').readAsBytesSync();

    stdout.writeln('Backend: ${KioskConfig.apiBase}');

    final systemOnly = await _get(null);
    stdout.writeln('  tizim do\'koni bilan          : HTTP $systemOnly');

    final bundledOnly = await _get(
      SecurityContext(withTrustedRoots: false)
        ..setTrustedCertificatesBytes(pem),
    );
    stdout.writeln('  FAQAT ilova sertifikatlari   : HTTP $bundledOnly');

    // This is the assertion that matters: a kiosk whose Windows knows nothing
    // about Let's Encrypt still completes the handshake and gets its content.
    expect(bundledOnly, 200,
        reason: 'the app must not depend on the Windows certificate store');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
