import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// The TLS trust the kiosk uses for every call it makes.
///
/// On Windows, Dart takes its root certificates from the **system** store, and
/// a kiosk is exactly the machine where that store cannot be relied on: a fresh
/// or locked-down Windows image, with automatic root updates switched off, has
/// never heard of the Let's Encrypt root the backend's certificate chains up
/// to. Every request then dies with
///
/// ```
/// HandshakeException: CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate
/// ```
///
/// which is what happened on the first installed kiosk (2026-07-29): the same
/// URL answered fine from PowerShell — schannel fetches missing roots on demand
/// — while the app could not reach the server at all.
///
/// So the roots the backend needs travel with the app ([assets/certs/roots.pem])
/// and are added *on top of* the system ones. Nothing is trusted that a browser
/// would not trust; the kiosk simply stops depending on how well its Windows
/// installation is maintained.
class KioskTls {
  const KioskTls._();

  static const String _asset = 'assets/certs/roots.pem';

  static SecurityContext? _context;
  static bool _tried = false;

  /// The shared context, or null when the bundled roots could not be loaded —
  /// in which case callers fall back to the system store, exactly as before.
  ///
  /// Built once: a [SecurityContext] parses and holds its trust store, and
  /// rebuilding it per request would be paid for on every screen.
  static Future<SecurityContext?> context() async {
    if (_tried) return _context;
    _tried = true;
    try {
      final pem = await rootBundle.load(_asset);
      _context = SecurityContext(withTrustedRoots: true)
        ..setTrustedCertificatesBytes(pem.buffer.asUint8List());
    } catch (e) {
      // A missing or malformed bundle must not take the kiosk offline: on a
      // well-maintained Windows the system roots are enough on their own.
      debugPrint('tls: bundled roots unavailable, using system store ($e)');
      _context = null;
    }
    return _context;
  }

  /// An HTTP client that trusts both the system roots and the bundled ones.
  static Future<HttpClient> client({Duration? connectionTimeout}) async {
    final ctx = await context();
    final client = HttpClient(context: ctx);
    if (connectionTimeout != null) client.connectionTimeout = connectionTimeout;
    return client;
  }

  /// Forgets the cached context so a test can build it again.
  @visibleForTesting
  static void reset() {
    _context = null;
    _tried = false;
  }
}
