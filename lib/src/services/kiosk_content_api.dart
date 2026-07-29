import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config.dart';
import 'tls.dart';

/// One section as it came back from the backend.
///
/// [data] is the section's payload — `null` when the backend has the section
/// but nobody has filled it in yet, which the kiosk shows as "no data entered"
/// rather than inventing content of its own.
class ContentResponse {
  const ContentResponse({
    required this.section,
    required this.data,
    this.version = 0,
    this.etag,
    this.notModified = false,
  });

  /// Nothing changed since the caller's `ETag` — keep using the cache.
  const ContentResponse.notModified(this.section)
    : data = null,
      version = 0,
      etag = null,
      notModified = true;

  final String section;
  final Map<String, dynamic>? data;
  final int version;
  final String? etag;
  final bool notModified;
}

/// Reads the kiosk's content sections from the qabulhona backend.
///
/// Contract: [[02 - API/20 - Info Kiosk kontent]] in the docs vault. Every
/// section is public (no auth), asked for with `?lang=all` so one response
/// carries all three languages and switching language never needs the network.
///
/// Responses arrive wrapped: `{"section":…,"version":…,"data":{…}}`. Some
/// sections were specified with the payload at the top level instead, so both
/// shapes are accepted — the kiosk must not break over an envelope.
///
/// Uses `dart:io` directly, like [AiApi], so the kiosk keeps its two-package
/// dependency list.
class KioskContentApi {
  KioskContentApi({String? apiBase, this.timeout = const Duration(seconds: 20)})
    : apiBase = apiBase ?? KioskConfig.apiBase;

  /// Every section the kiosk reads, in the order it is worth fetching them:
  /// what the visitor sees first comes first.
  static const List<String> sections = [
    'sections',
    'config',
    'reception',
    'reception-schedule',
    'faq',
    'topics',
    'mobile-schedule',
    'services',
  ];

  /// Sections that live outside the `/kiosk/info/` prefix.
  ///
  /// The officials list is shared with the standalone in-person reception
  /// kiosk, so it stays where that kiosk already reads it from.
  static const Map<String, String> _paths = {
    'reception-schedule': '/kiosk/reception-schedule',
  };

  final String apiBase;
  final Duration timeout;

  bool get enabled => apiBase.trim().isNotEmpty;

  String _pathFor(String section) => _paths[section] ?? '/kiosk/info/$section';

  /// Fetches one section. Pass [etag] to be told `304` instead of being sent
  /// bytes that have not changed. Throws on any network or shape failure; the
  /// caller falls back to its cache.
  Future<ContentResponse> fetch(String section, {String? etag}) async {
    if (!enabled) throw const SocketException('backend not configured');
    final uri = Uri.parse('$apiBase${_pathFor(section)}?lang=all');

    final client = await KioskTls.client(connectionTimeout: timeout);
    try {
      final req = await client.getUrl(uri).timeout(timeout);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (etag != null && etag.isNotEmpty) {
        req.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final res = await req.close().timeout(timeout);

      if (res.statusCode == HttpStatus.notModified) {
        await res.drain<void>();
        return ContentResponse.notModified(section);
      }
      final body = await res.transform(utf8.decoder).join().timeout(timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('GET ${uri.path} -> ${res.statusCode}');
      }
      if (body.isEmpty) return ContentResponse(section: section, data: null);

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw FormatException('$section: response is not an object');
      }
      final map = decoded.cast<String, dynamic>();
      return ContentResponse(
        section: section,
        data: payloadOf(map),
        version: map['version'] is int ? map['version'] as int : 0,
        etag: res.headers.value(HttpHeaders.etagHeader),
      );
    } finally {
      client.close(force: true);
    }
  }

  /// The section payload inside a response.
  ///
  /// `{"section":…,"data":{…}}` is what the server actually sends; the written
  /// contract put the fields at the top level. Accept both, and treat an
  /// explicit `data: null` as "not filled in yet".
  static Map<String, dynamic>? payloadOf(Map<String, dynamic> body) {
    if (body.containsKey('data')) {
      final d = body['data'];
      return d is Map ? d.cast<String, dynamic>() : null;
    }
    // Top-level shape: drop the envelope keys and keep the rest.
    final rest = Map<String, dynamic>.from(body)
      ..remove('section')
      ..remove('version')
      ..remove('updated_at');
    return rest.isEmpty ? null : rest;
  }
}
