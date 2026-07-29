import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../content_models.dart';
import '../data.dart';
import 'kiosk_content_api.dart';

/// Everything the kiosk shows, as delivered by the backend.
///
/// The office no longer edits this app to change what a visitor reads: the
/// governor's reception day, the quarter's mobile-reception schedule, the legal
/// answers — all of it is entered in the admin panel and picked up here. The
/// content compiled into the app is not a fallback any more; it survives only
/// as the seed the backend was filled from ([AppData] and friends are still
/// used for date names and UI vocabulary).
///
/// Two rules shape everything below:
///
/// * **The backend is the truth.** When a section comes back empty, the screen
///   says so ("no data entered yet") instead of showing something older or
///   invented. An empty section is a content problem someone must fix, and
///   hiding it behind stale text is how it stays unfixed.
/// * **A dropped network is not an empty section.** Every successful payload is
///   written to disk, so a kiosk that loses its connection — or starts up
///   before the network does — keeps showing what it last knew. Only a
///   deliberate `data: null` from the server clears it.
class ContentStore extends ChangeNotifier {
  ContentStore({
    KioskContentApi? api,
    Directory? cacheDir,
    this.refreshEvery = const Duration(minutes: 15),
  }) : _api = api ?? KioskContentApi(),
       _cacheOverride = cacheDir;

  final KioskContentApi _api;
  final Duration refreshEvery;

  /// Where tests point the cache; production resolves [_dir] instead.
  final Directory? _cacheOverride;
  Directory? _resolvedDir;
  Timer? _timer;
  bool _disposed = false;

  /// True once the cache has been read and the first fetch has been attempted,
  /// so screens can tell "still starting up" from "the section is empty".
  bool ready = false;

  /// When the backend was last reached successfully, or null if never.
  DateTime? lastSync;

  /// Why the last fetch failed, or null when the last one worked.
  ///
  /// A kiosk has no console and nobody watching it: without this, a machine
  /// that cannot resolve the host, sits behind a proxy, or has a clock so far
  /// out that TLS refuses the certificate looks exactly like a backend nobody
  /// has filled in. The screens use [unreachable] to say which it is, and
  /// [logPath] keeps the underlying error for whoever comes to fix it.
  String? lastError;

  /// True when this kiosk has never once reached the server. Distinguishes a
  /// networking fault from a genuinely empty section.
  bool get unreachable => lastSync == null && lastError != null;

  // ---- the content itself -------------------------------------------------

  OfficeInfo? office;
  List<CardDef> cards = const [];
  ReceptionInfo? reception;
  OfficialsInfo? officials;
  TopicsInfo? topics;
  MobileScheduleInfo? mobileSchedule;
  FaqInfo? faq;
  List<ServiceInfo> services = const [];

  /// `ETag` per section, so a refresh that changes nothing costs one `304`.
  final Map<String, String> _etags = {};

  // ---- lifecycle ----------------------------------------------------------

  /// Reads the cache, then refreshes from the backend and keeps refreshing.
  ///
  /// Returns as soon as the cache is on screen — the network is never allowed
  /// to hold up the first frame of a kiosk.
  Future<void> start() async {
    await _readCache();
    ready = true;
    _notify();
    unawaited(refresh());
    _timer ??= Timer.periodic(refreshEvery, (_) => refresh());
  }

  /// Fetches every section once. Never throws.
  Future<void> refresh() async {
    if (!_api.enabled || _disposed) return;
    var changed = false;
    var reached = false;
    final wasUnreachable = unreachable;
    String? failure;
    for (final section in KioskContentApi.sections) {
      try {
        final res = await _api.fetch(section, etag: _etags[section]);
        reached = true;
        if (res.notModified) continue;
        if (res.etag != null && res.etag!.isNotEmpty) {
          _etags[section] = res.etag!;
        }
        if (_apply(section, res.data)) changed = true;
        await _writeCache(section, res.data, res.etag);
      } catch (e) {
        // A section that cannot be reached keeps whatever it already had; the
        // kiosk stays on the last good copy rather than blanking a screen.
        debugPrint('content: $section failed, keeping cache ($e)');
        failure ??= '$section: $e';
      }
    }
    if (reached) {
      lastSync = DateTime.now();
      lastError = null;
    } else if (failure != null) {
      lastError = failure;
      _log(failure);
    }
    if (changed || wasUnreachable != unreachable) _notify();
  }

  /// Appends a line to `<cache dir>\log.txt`.
  ///
  /// The one place an engineer standing at a broken kiosk can look. Only
  /// failures are written, and only the first of each round, so the file stays
  /// short enough to read at a glance.
  void _log(String line) {
    try {
      final file = File('${_dir.path}/log.txt');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        '${DateTime.now().toIso8601String()}  $line\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Diagnostics are never worth a crash.
    }
  }

  /// Where [_log] writes, so it can be quoted to whoever has to fix the kiosk.
  String get logPath => '${_dir.path}\\log.txt';

  /// Feeds a payload in as though it had just arrived from the backend, so a
  /// test can stand a screen up without a server behind it.
  @visibleForTesting
  void applyPayload(String section, Map<String, dynamic>? data) {
    ready = true;
    if (_apply(section, data)) _notify();
  }

  /// Puts the store in the state of a kiosk that has never reached the server.
  @visibleForTesting
  void markUnreachable(String error) {
    ready = true;
    lastSync = null;
    lastError = error;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ---- applying a payload -------------------------------------------------

  /// Puts [data] into the right field. A null payload empties the section on
  /// purpose: the backend is saying nobody has entered this yet.
  ///
  /// Returns whether anything changed.
  bool _apply(String section, Map<String, dynamic>? data) {
    try {
      switch (section) {
        case 'sections':
          cards = data == null ? const [] : parseCards(data);
        case 'config':
          office = data == null ? null : OfficeInfo.parse(data);
        case 'reception':
          reception = data == null ? null : ReceptionInfo.parse(data);
        case 'reception-schedule':
          officials = data == null ? null : OfficialsInfo.parse(data);
        case 'topics':
          topics = data == null ? null : TopicsInfo.parse(data);
        case 'mobile-schedule':
          mobileSchedule = data == null ? null : MobileScheduleInfo.parse(data);
        case 'faq':
          faq = data == null ? null : FaqInfo.parse(data);
        case 'services':
          services = data == null ? const [] : ServiceInfo.parseList(data);
        default:
          return false;
      }
      return true;
    } catch (e) {
      // One badly-shaped section must not cost the kiosk the other seven.
      debugPrint('content: $section could not be parsed ($e)');
      return false;
    }
  }

  // ---- disk cache ---------------------------------------------------------

  /// `%LOCALAPPDATA%\info_kiosk\content`, or the system temp directory on a
  /// machine that has no such variable (tests, other platforms).
  Directory get _dir {
    if (_cacheOverride != null) return _cacheOverride;
    final local = Platform.environment['LOCALAPPDATA'];
    return _resolvedDir ??= Directory(
      local == null || local.isEmpty
          ? '${Directory.systemTemp.path}/info_kiosk/content'
          : '$local\\info_kiosk\\content',
    );
  }

  File _cacheFile(String section) => File('${_dir.path}/$section.json');

  /// Loads whatever the last successful refresh left behind.
  ///
  /// A cache file holds the payload together with the `ETag` it came with, so
  /// after a restart the kiosk can still ask "anything new?" and be told `304`.
  Future<void> _readCache() async {
    for (final section in KioskContentApi.sections) {
      try {
        final file = _cacheFile(section);
        if (!file.existsSync()) continue;
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is! Map) continue;
        final etag = decoded['etag'];
        if (etag is String && etag.isNotEmpty) _etags[section] = etag;
        final data = decoded['data'];
        _apply(section, data is Map ? data.cast<String, dynamic>() : null);
      } catch (e) {
        debugPrint('content: cached $section unreadable ($e)');
      }
    }
  }

  Future<void> _writeCache(
    String section,
    Map<String, dynamic>? data,
    String? etag,
  ) async {
    try {
      final file = _cacheFile(section);
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({'etag': etag, 'data': data}),
        flush: true,
      );
    } catch (e) {
      // A read-only profile costs the kiosk its offline copy, nothing more.
      debugPrint('content: could not cache $section ($e)');
    }
  }
}
