import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config.dart';
import '../l10n.dart';

/// One answer from the qabulhona backend's legal advisor.
///
/// [grounded] is false when the RAG search found no matching article — the
/// backend deliberately says "I don't know" rather than inventing law, so the
/// kiosk can fall back to its own offline knowledge base in that case.
class AiAnswer {
  const AiAnswer(this.text, {this.grounded = false, this.sources = const []});
  final String text;
  final bool grounded;
  final List<String> sources;
}

/// An ephemeral Gemini Live credential plus the session settings that come
/// with it. [modality] is the field the client must obey rather than hard-code:
/// `AUDIO` means Gemini speaks for itself, `TEXT` means it writes and the
/// backend's `/tts` voice reads the words out.
class VoiceToken {
  const VoiceToken({
    required this.token,
    required this.model,
    required this.voice,
    required this.language,
    required this.modality,
  });

  factory VoiceToken.fromJson(Map<String, dynamic> j) => VoiceToken(
        token: j['token']?.toString() ?? '',
        model: j['model']?.toString() ?? '',
        voice: j['voice']?.toString() ?? 'Aoede',
        language: j['language']?.toString() ?? 'auto',
        modality: (j['modality']?.toString() ?? 'AUDIO').toUpperCase(),
      );

  final String token;
  final String model;
  final String voice;
  final String language;
  final String modality;

  /// True when Gemini itself produces the audio, so no `/tts` call is needed.
  bool get speaksItself => modality == 'AUDIO';
}

/// Thin HTTP client for the qabulhona backend's **info kiosk** AI endpoints.
///
/// Contract (Projects-FinTech vault — `02 - API/07 - AI suhbat va AI-ariza`):
///
/// ```
/// POST {apiBase}/avatar/ask     { "question": "...", "language": "uz" }
///      -> { answer, grounded, sources[] }
///
/// GET  {apiBase}/tts/status
///      -> { enabled, gemini_modality: "TEXT"|"AUDIO", max_chars, ... }
/// ```
///
/// The info kiosk uses the **unlocked** avatar endpoints — the `device_id`
/// lock (`/avatar/kiosk/*`, 409 when busy) belongs to the two avatar kiosks
/// only, so this kiosk never competes with them.
///
/// Every call is short-timeout and throws on any failure; the caller falls
/// back to the offline responder so the kiosk keeps working without network.
/// Uses `dart:io` directly — no extra package dependency.
class AiApi {
  AiApi({String? apiBase, this.timeout = const Duration(seconds: 20)})
      : apiBase = apiBase ?? KioskConfig.apiBase;

  /// Full API base, e.g. `https://qabulxona.gennis.uz/api`. Empty => disabled.
  final String apiBase;
  final Duration timeout;

  bool get enabled => apiBase.trim().isNotEmpty;

  Uri _u(String path) => Uri.parse('$apiBase$path');

  /// Backend language code for [lang] (`uz` / `ru` / `en`).
  static String langCode(Lang lang) => switch (lang) {
        Lang.uz => 'uz',
        Lang.ru => 'ru',
        Lang.en => 'en',
      };

  /// Asks the lex.uz-grounded advisor. Throws on network / shape errors.
  Future<AiAnswer> ask(String question, Lang lang) async {
    final data = await _postJson(_u('/avatar/ask'), {
      'question': question,
      'language': langCode(lang),
    });
    if (data is! Map) throw const FormatException('avatar/ask: not an object');
    final answer = (data['answer'] as String?)?.trim() ?? '';
    if (answer.isEmpty) throw const FormatException('avatar/ask: empty answer');
    final srcs = data['sources'];
    return AiAnswer(
      answer,
      grounded: data['grounded'] == true,
      sources: srcs is List ? srcs.map((s) => '$s').toList() : const [],
    );
  }

  /// Requests an ephemeral Gemini Live credential.
  ///
  /// The info kiosk deliberately uses the **unlocked** `/avatar/voice-token`:
  /// the `device_id` lock behind `/avatar/kiosk/voice-token` (409 when busy)
  /// exists so the two avatar kiosks never talk over each other, and this
  /// kiosk must not compete for it.
  /// [KioskConfig.aiVoice] is sent deliberately: the backend otherwise bakes
  /// `voice: "auto"` into the token and the live server refuses it.
  Future<VoiceToken> voiceToken(Lang lang) async {
    final data = await _postJson(_u('/avatar/voice-token'), {
      'voice': KioskConfig.aiVoice,
      'language': langCode(lang),
    });
    if (data is! Map) {
      throw const FormatException('avatar/voice-token: not an object');
    }
    final t = VoiceToken.fromJson(data.cast<String, dynamic>());
    if (t.token.isEmpty || t.model.isEmpty) {
      throw const FormatException('avatar/voice-token: missing token/model');
    }
    return t;
  }

  /// Whether the backend is reachable at all. Never throws.
  Future<bool> health() async {
    if (!enabled) return false;
    try {
      final data = await _getJson(_u('/health'),
          timeout: const Duration(seconds: 4));
      return data is Map && data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  // ---- low-level helpers ---------------------------------------------------

  Future<dynamic> _getJson(Uri uri, {Duration? timeout}) async {
    final t = timeout ?? this.timeout;
    final client = HttpClient()..connectionTimeout = t;
    try {
      final req = await client.getUrl(uri).timeout(t);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close().timeout(t);
      final body = await res.transform(utf8.decoder).join().timeout(t);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('GET ${uri.path} -> ${res.statusCode}');
      }
      return body.isEmpty ? null : jsonDecode(body);
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> _postJson(Uri uri, Map<String, dynamic> payload) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.postUrl(uri).timeout(timeout);
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close().timeout(timeout);
      final body = await res.transform(utf8.decoder).join().timeout(timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('POST ${uri.path} -> ${res.statusCode}: $body');
      }
      return body.isEmpty ? null : jsonDecode(body);
    } finally {
      client.close(force: true);
    }
  }
}
